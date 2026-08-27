import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'mtn_momo_service.g.dart';

class MtnMomoPaymentResult {
  final bool success;
  final String? referenceId;
  final String status; // PENDING, SUCCESSFUL, FAILED
  final String? message;
  final String? transactionId;

  const MtnMomoPaymentResult({
    required this.success,
    this.referenceId,
    required this.status,
    this.message,
    this.transactionId,
  });
}

class MtnMomoService {
  final String baseUrl;
  final String subscriptionKey;
  final String targetEnvironment; // 'sandbox' or 'mtnghana' / 'live'
  final String? apiUser;
  final String? apiKey;

  MtnMomoService({
    this.baseUrl = 'https://sandbox.momodeveloper.mtn.com',
    this.subscriptionKey = '',
    this.targetEnvironment = 'sandbox',
    this.apiUser,
    this.apiKey,
  });

  /// Generate a Bearer access token from MoMo Collections API
  Future<String?> _getAccessToken() async {
    if (apiUser == null || apiKey == null || apiUser!.isEmpty || apiKey!.isEmpty) {
      return null;
    }

    try {
      final credentials = base64Encode(utf8.encode('$apiUser:$apiKey'));
      final response = await http.post(
        Uri.parse('$baseUrl/collection/token/'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Ocp-Apim-Subscription-Key': subscriptionKey,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['access_token'] as String?;
      } else {
        debugPrint('MoMo Token Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('MoMo Token Request Exception: $e');
      return null;
    }
  }

  /// Request To Pay (Push USSD prompt to customer phone)
  Future<MtnMomoPaymentResult> requestToPay({
    required String phoneNumber,
    required double amount,
    required String currency,
    required String referenceId,
    String payerMessage = 'CQAAG Membership Registration',
    String payeeNote = 'Cashew Quality Analysts Association Ghana',
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = cleanPhone.startsWith('0')
        ? '233${cleanPhone.substring(1)}'
        : (cleanPhone.startsWith('233') ? cleanPhone : '233$cleanPhone');

    final xReferenceId = referenceId.isNotEmpty ? referenceId : const Uuid().v4();

    try {
      final token = await _getAccessToken();

      final headers = {
        'Content-Type': 'application/json',
        'X-Reference-Id': xReferenceId,
        'X-Target-Environment': targetEnvironment,
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'amount': amount.toStringAsFixed(2),
        'currency': currency,
        'externalId': xReferenceId,
        'payer': {
          'partyIdType': 'MSISDN',
          'partyId': formattedPhone,
        },
        'payerMessage': payerMessage,
        'payeeNote': payeeNote,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/collection/v1_0/requesttopay'),
        headers: headers,
        body: body,
      );

      // MoMo Collections returns 202 Accepted on successful RequestToPay creation
      if (response.statusCode == 202 || response.statusCode == 200 || response.statusCode == 201) {
        return MtnMomoPaymentResult(
          success: true,
          referenceId: xReferenceId,
          status: 'PENDING',
          message: 'Payment prompt sent to $formattedPhone. Please approve on your phone.',
        );
      } else {
        return MtnMomoPaymentResult(
          success: false,
          referenceId: xReferenceId,
          status: 'FAILED',
          message: 'MoMo Payment Request failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('MTN MoMo Error: $e');
      return MtnMomoPaymentResult(
        success: false,
        referenceId: xReferenceId,
        status: 'FAILED',
        message: 'Network error connecting to MTN MoMo: ${e.toString()}',
      );
    }
  }

  /// Check payment status by Reference ID
  Future<MtnMomoPaymentResult> checkPaymentStatus(String referenceId) async {
    try {
      final token = await _getAccessToken();

      final headers = {
        'X-Target-Environment': targetEnvironment,
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/collection/v1_0/requesttopay/$referenceId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = (data['status'] as String? ?? 'PENDING').toUpperCase();
        final financialTransactionId = data['financialTransactionId'] as String?;

        return MtnMomoPaymentResult(
          success: status == 'SUCCESSFUL',
          referenceId: referenceId,
          status: status,
          transactionId: financialTransactionId,
          message: status == 'SUCCESSFUL'
              ? 'Payment confirmed successfully!'
              : (status == 'FAILED' ? 'Payment was cancelled or failed.' : 'Payment pending approval.'),
        );
      } else {
        return MtnMomoPaymentResult(
          success: false,
          referenceId: referenceId,
          status: 'PENDING',
          message: 'Could not fetch status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return MtnMomoPaymentResult(
        success: false,
        referenceId: referenceId,
        status: 'ERROR',
        message: 'Error verifying status: $e',
      );
    }
  }
}

@riverpod
MtnMomoService mtnMomoService(Ref ref) {
  return MtnMomoService(
    baseUrl: 'https://sandbox.momodeveloper.mtn.com',
    targetEnvironment: 'sandbox',
    subscriptionKey: '',
  );
}
