import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

/// Export certificates waiting at the CQAAG approval desk, oldest first.
final pendingExportApprovalsProvider = StreamProvider<List<Inspection>>((ref) {
  return ref.watch(inspectionServiceProvider).streamPendingExportApprovals();
});

final exportSealUrlProvider = StreamProvider<String?>((ref) {
  return ref.watch(inspectionServiceProvider).streamExportSealUrl();
});

/// The CQAAG APPROVAL desk: admins review each Export certificate — its
/// figures and cutting pictures — and approve or decline it. Approval stamps
/// the official seal and the date and time on the certificate.
class ExportApprovalsTab extends ConsumerStatefulWidget {
  const ExportApprovalsTab({super.key});

  @override
  ConsumerState<ExportApprovalsTab> createState() => _ExportApprovalsTabState();
}

class _ExportApprovalsTabState extends ConsumerState<ExportApprovalsTab> {
  final Set<String> _busy = {};

  String get _adminName {
    final user = ref.read(currentUserProfileProvider).value;
    return user == null ? 'CQAAG Secretariat' : '${user.firstName} ${user.lastName}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingExportApprovalsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingExportApprovalsProvider),
      child: ListView(
        padding: EdgeInsets.all(12.r),
        children: [
          _buildSealCard(),
          Gap(16.h),
          pending.when(
            loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => CustomText('Could not load the approval lineup: $e'),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  child: Column(
                    children: [
                      Icon(Icons.verified_outlined, size: 48.r, color: Colors.green),
                      Gap(10.h),
                      const CustomText("No export certificates are waiting for approval."),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "${list.length} waiting • oldest first",
                    variant: TextVariant.bodySmall,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  Gap(8.h),
                  for (final inspection in list) ...[_buildRequestCard(inspection), Gap(12.h)],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSealCard() {
    final sealUrl = ref.watch(exportSealUrlProvider).value;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Colors.grey.shade100),
            child: sealUrl != null
                ? CachedNetworkImage(imageUrl: sealUrl, fit: BoxFit.contain)
                : Image.asset(Assets.imagesCqaagLogo, fit: BoxFit.contain),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText("Official approval seal", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
                Gap(2.h),
                CustomText(
                  sealUrl != null
                      ? "Copied onto each Export certificate at the moment it is approved."
                      : "No signed seal on file. Approved certificates use the association logo and do not claim the President's signature.",
                  variant: TextVariant.bodySmall,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Upload signed seal',
            icon: const Icon(Icons.upload_outlined),
            onPressed: _uploadSeal,
          ),
        ],
      ),
    );
  }

  Future<void> _uploadSeal() async {
    final file = await ImageSourcePicker.pick(context, cameraLabel: 'Photograph the signed seal');
    if (file == null || !mounted) return;
    AppDialogs.showLoadingDialog(context, message: 'Uploading seal...');
    try {
      final url = await ref.read(cloudinaryServiceProvider).uploadApprovalSeal(file);
      if (url == null) throw Exception('The upload did not return an image address.');
      final admin = ref.read(authServiceProvider).currentUser;
      await ref.read(inspectionServiceProvider).setExportSealUrl(url: url, adminUid: admin?.uid ?? '');
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      CustomSnackBar.success(context, message: 'Signed seal saved. New approvals will carry it.');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      CustomSnackBar.error(context, message: 'The seal could not be saved: $e');
    }
  }

  Widget _buildRequestCard(Inspection i) {
    final colorScheme = Theme.of(context).colorScheme;
    final requested = i.approvalRequestedAtTime ?? i.createdAt;
    final busy = _busy.contains(i.id);
    final photos = i.allPhotoUrls;

    Widget meta(String label, String value) => Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 95.w, child: CustomText(label, variant: TextVariant.bodySmall, color: colorScheme.secondary)),
          Expanded(child: CustomText(value.isEmpty ? '-' : value, variant: TextVariant.bodySmall, fontWeight: FontWeight.w600)),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(i.inspectionId ?? i.id, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              ),
              CustomText(
                requested == null ? '' : 'Requested ${AgreementPdfService.formatSignedAt(requested)}',
                variant: TextVariant.bodySmall,
                color: Colors.amber.shade900,
              ),
            ],
          ),
          Gap(8.h),
          meta('Analyst', '${i.inspectorName ?? ''} ${i.qcCode == null ? '' : '(${i.qcCode})'}'.trim()),
          meta('B/L', i.blNumber ?? ''),
          meta('Shipper', i.shipperDetails ?? ''),
          meta('Destination', i.destinationCountry ?? ''),
          meta('KOR', '${i.kor.toStringAsFixed(2)} lbs'),
          meta('Certificate fee', i.hasReportFee ? '${i.reportFeeCurrency} ${i.reportFeeAmount.toStringAsFixed(2)} • ${i.reportFeePayment.label}' : 'None'),
          Gap(8.h),
          if (photos.isEmpty)
            CustomText('No cutting pictures attached.', variant: TextVariant.bodySmall, color: colorScheme.error)
          else
            SizedBox(
              height: 72.r,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, _) => Gap(8.w),
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () => _showPhoto(photos, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(imageUrl: photos[index], width: 72.r, height: 72.r, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          if (i.hasReportFee && i.reportFeeEvidenceUrl.startsWith('http')) ...[
            Gap(8.h),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showPhoto([i.reportFeeEvidenceUrl], 0),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16),
                  label: const Text('Fee evidence'),
                ),
                const Spacer(),
                if (i.reportFeePayment == PaymentStatus.pendingVerification) ...[
                  TextButton(onPressed: busy ? null : () => _setFee(i, PaymentStatus.rejected), child: const Text('Reject fee')),
                  TextButton(onPressed: busy ? null : () => _setFee(i, PaymentStatus.verified), child: const Text('Verify fee')),
                ],
              ],
            ),
          ],
          Gap(8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pushNamed(QualityResultScreen.id, extra: i),
                  child: const Text('Open'),
                ),
              ),
              Gap(8.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _decline(i),
                  style: OutlinedButton.styleFrom(foregroundColor: colorScheme.error, side: BorderSide(color: colorScheme.error)),
                  child: const Text('Decline'),
                ),
              ),
              Gap(8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : () => _approve(i),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, foregroundColor: Colors.white),
                  child: busy
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPhoto(List<String> urls, int index) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.all(12.r),
        child: Stack(
          children: [
            PageView(
              controller: PageController(initialPage: index),
              children: [
                for (final url in urls)
                  InteractiveViewer(child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)),
              ],
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(Inspection i) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve export certificate?'),
        content: Text(
          'Certificate ${i.inspectionId ?? i.id} becomes valid and carries the association seal with today\'s date and time.'
          '${i.hasReportFee && i.reportFeePayment != PaymentStatus.verified ? '\n\nThe certificate fee has not been verified yet.' : ''}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;

    await _decide(i, 'approved', () async {
      final service = ref.read(inspectionServiceProvider);
      await service.approveExport(
        inspection: i,
        adminUid: ref.read(authServiceProvider).currentUser!.uid,
        adminName: _adminName,
        sealUrl: await service.getExportSealUrl(),
      );
    });
  }

  Future<void> _decline(Inspection i) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Decline export certificate'),
        content: TextField(
          controller: controller,
          maxLength: 500,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Reason (sent to the analyst)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    if (reason.isEmpty) {
      if (mounted) CustomSnackBar.warning(context, message: 'Write a short reason before declining.');
      return;
    }

    await _decide(i, 'declined', () {
      return ref.read(inspectionServiceProvider).declineExport(
        inspection: i,
        adminUid: ref.read(authServiceProvider).currentUser!.uid,
        adminName: _adminName,
        reason: reason,
      );
    });
  }

  /// Saves the decision, then emails the analyst through the website.
  Future<void> _decide(Inspection i, String decision, Future<void> Function() save) async {
    setState(() => _busy.add(i.id));
    try {
      await save();
      final mailed = await ref.read(websiteApiServiceProvider).sendExportDecision(inspectionId: i.id, decision: decision);
      if (!mounted) return;
      final mailNote = mailed.success ? '' : ' The analyst email could not be sent; the decision is saved.';
      CustomSnackBar.success(
        context,
        message: decision == 'approved'
            ? 'Certificate ${i.inspectionId ?? i.id} is now valid.$mailNote'
            : 'Certificate ${i.inspectionId ?? i.id} was declined.$mailNote',
      );
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, message: 'The decision could not be saved: $e');
    } finally {
      if (mounted) setState(() => _busy.remove(i.id));
    }
  }

  Future<void> _setFee(Inspection i, PaymentStatus status) async {
    setState(() => _busy.add(i.id));
    try {
      await ref.read(inspectionServiceProvider).setReportFeeStatus(
        inspectionId: i.id,
        status: status,
        adminUid: ref.read(authServiceProvider).currentUser!.uid,
      );
      if (mounted) CustomSnackBar.success(context, message: 'Certificate fee ${status.label.toLowerCase()}.');
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, message: 'Could not update the fee: $e');
    } finally {
      if (mounted) setState(() => _busy.remove(i.id));
    }
  }
}
