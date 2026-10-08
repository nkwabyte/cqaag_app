import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/utils/website_launcher.dart';

part 'website_api_service.g.dart';

/// Outcome of a call to the website's AJAX API.
class WebsiteApiResult {
  const WebsiteApiResult({required this.success, this.data = const {}, this.message, this.code});

  factory WebsiteApiResult.failure(String message, {String? code}) {
    return WebsiteApiResult(success: false, message: message, code: code);
  }

  final bool success;
  final Map<String, dynamic> data;

  /// Human readable message from the server, when it sent one.
  final String? message;

  /// Machine-readable error code, e.g. `credential_too_old`.
  final String? code;

  /// The `status` field most success responses carry, e.g. `emailed`.
  String? get status => data['status']?.toString();
}

/// Talks to the CQAAG website, which holds the association's server side:
/// the SMTP mailer, the generated-password issuer and the agreements database.
///
/// The app and the website share one Firebase project, so every call carries
/// the signed-in user's Firebase ID token and the website checks it, exactly as
/// it does for its own pages. WordPress also requires its public AJAX nonce,
/// which every page of the site publishes; it is read from the home page and
/// refreshed whenever the site rejects it.
class WebsiteApiService {
  WebsiteApiService({http.Client? client, FirebaseAuth? auth})
    : _client = client ?? http.Client(),
      _auth = auth ?? FirebaseAuth.instance;

  final http.Client _client;
  final FirebaseAuth _auth;

  /// Where the site publishes `cqaagData = {"ajaxurl": …, "nonce": …}`.
  static const String _noncePage = WebsiteLauncher.home;

  /// Fallback endpoint (a Bedrock install serves WordPress from `/wp`).
  static const String _defaultAjaxUrl = '${WebsiteLauncher.baseUrl}/wp/wp-admin/admin-ajax.php';

  /// WordPress nonces last 12–24 hours; refresh well inside that.
  static const Duration _nonceLifetime = Duration(hours: 6);

  String? _nonce;
  String _ajaxUrl = _defaultAjaxUrl;
  DateTime? _nonceFetchedAt;

  Future<void> _refreshNonce() async {
    final response = await _client.get(Uri.parse(_noncePage)).timeout(const Duration(seconds: 20));
    final body = response.body;
    final nonce = RegExp(r'"nonce"\s*:\s*"([A-Za-z0-9]+)"').firstMatch(body)?.group(1);
    final ajaxUrl = RegExp(r'"ajaxurl"\s*:\s*"([^"]+)"').firstMatch(body)?.group(1);
    if (nonce == null) {
      throw Exception('The CQAAG website did not publish its request token.');
    }
    _nonce = nonce;
    if (ajaxUrl != null) _ajaxUrl = ajaxUrl.replaceAll(r'\/', '/');
    _nonceFetchedAt = DateTime.now();
  }

  Future<void> _ensureNonce() async {
    final fetchedAt = _nonceFetchedAt;
    if (_nonce == null || fetchedAt == null || DateTime.now().difference(fetchedAt) > _nonceLifetime) {
      await _refreshNonce();
    }
  }

  /// Posts [action] with the signed-in user's ID token.
  Future<WebsiteApiResult> post(String action, Map<String, String> fields) async {
    final user = _auth.currentUser;
    if (user == null) {
      return WebsiteApiResult.failure('Sign in is required.');
    }

    try {
      await _ensureNonce();
      var response = await _send(action, fields, await user.getIdToken());

      // "-1" with 403 is WordPress rejecting a stale nonce. Fetch a fresh one
      // and try once more before giving up.
      if (response.statusCode == 403 && response.body.trim() == '-1') {
        await _refreshNonce();
        response = await _send(action, fields, await user.getIdToken(true));
      }

      return _parse(response);
    } catch (e) {
      debugPrint('WebsiteApiService.$action failed: $e');
      return WebsiteApiResult.failure('The CQAAG website did not respond. Check your connection and try again.');
    }
  }

  Future<http.Response> _send(String action, Map<String, String> fields, String? idToken) {
    return _client
        .post(
          Uri.parse(_ajaxUrl),
          body: {
            'action': action,
            'nonce': _nonce ?? '',
            'id_token': idToken ?? '',
            ...fields,
          },
        )
        .timeout(const Duration(seconds: 60));
  }

  WebsiteApiResult _parse(http.Response response) {
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      return WebsiteApiResult.failure('The CQAAG website returned an unexpected response.');
    }
    if (decoded is! Map) {
      return WebsiteApiResult.failure('The CQAAG website returned an unexpected response.');
    }

    final success = decoded['success'] == true;
    final rawData = decoded['data'];
    final data = rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{};
    return WebsiteApiResult(
      success: success,
      data: data,
      message: data['message']?.toString(),
      code: data['code']?.toString(),
    );
  }

  // --- Membership ---------------------------------------------------------

  /// Files the five accepted documents in the agreements database.
  ///
  /// Must succeed before the application is written, as on the website.
  Future<WebsiteApiResult> storeAgreements({
    required String memberId,
    required List<Map<String, String>> documents,
    String? fullName,
  }) {
    return post('cqaag_store_agreements', {
      'member_id': memberId,
      'documents': jsonEncode(documents),
      if (fullName != null && fullName.trim().isNotEmpty) 'full_name': fullName.trim(),
    });
  }

  /// Fetches a filed agreement PDF (admins only), as base64.
  Future<WebsiteApiResult> downloadAgreement({required String memberId, required String documentSlug}) {
    return post('cqaag_download_agreement', {'member_id': memberId, 'document_slug': documentSlug});
  }

  /// Emails the applicant the approval (with the payment link) or the
  /// rejection (with the re-apply link). Admins only, after the status is saved.
  Future<WebsiteApiResult> sendMembershipDecision({required String memberId, required String decision}) {
    return post('cqaag_membership_decision', {'member_id': memberId, 'decision': decision});
  }

  Future<WebsiteApiResult> issueCredentials(String memberId) {
    return post('cqaag_membership_issue_credentials', {'member_id': memberId});
  }

  Future<WebsiteApiResult> confirmCredentials({required String memberId, required String linkToken}) {
    return post('cqaag_membership_confirm_credentials', {'member_id': memberId, 'link_token': linkToken});
  }

  // --- Export approval ----------------------------------------------------

  /// Emails the secretariat that an Export certificate is waiting for approval.
  Future<WebsiteApiResult> requestExportApproval(String inspectionId) {
    return post('cqaag_export_approval_request', {'inspection_id': inspectionId});
  }

  /// Emails the analyst the approval decision. [decision] is `approved` or
  /// `declined`, and must already be saved on the inspection.
  Future<WebsiteApiResult> sendExportDecision({required String inspectionId, required String decision}) {
    return post('cqaag_export_approval_decision', {'inspection_id': inspectionId, 'decision': decision});
  }
}

@Riverpod(keepAlive: true)
WebsiteApiService websiteApiService(Ref ref) => WebsiteApiService();
