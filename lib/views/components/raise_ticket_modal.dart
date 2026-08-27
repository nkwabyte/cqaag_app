import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/index.dart';

class RaiseTicketModal extends ConsumerStatefulWidget {
  final String? prefilledInspectionId;
  final String? prefilledBatchId;

  const RaiseTicketModal({
    super.key,
    this.prefilledInspectionId,
    this.prefilledBatchId,
  });

  static Future<bool?> show(
    BuildContext context, {
    String? prefilledInspectionId,
    String? prefilledBatchId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RaiseTicketModal(
          prefilledInspectionId: prefilledInspectionId,
          prefilledBatchId: prefilledBatchId,
        ),
      ),
    );
  }

  @override
  ConsumerState<RaiseTicketModal> createState() => _RaiseTicketModalState();
}

class _RaiseTicketModalState extends ConsumerState<RaiseTicketModal> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  Future<void> _submitTicket() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final values = _formKey.currentState!.value;
    final user = ref.read(currentUserProfileProvider).value;

    if (user == null) {
      CustomSnackBar.error(context, message: 'Please log in to submit a ticket.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final ticketId = IdUtils.generateDocId();
      final ticketCode = IdUtils.generateTicketCode();

      final categoryStr = values['category'] as String? ?? 'mistake_correction';
      final category = TicketCategory.values.firstWhere(
        (c) => c.name == categoryStr || c.toString().split('.').last == categoryStr,
        orElse: () => TicketCategory.mistakeCorrection,
      );

      final priorityStr = values['priority'] as String? ?? 'medium';
      final priority = TicketPriority.values.firstWhere(
        (p) => p.name == priorityStr || p.toString().split('.').last == priorityStr,
        orElse: () => TicketPriority.medium,
      );

      final ticket = SupportTicket(
        id: ticketId,
        ticketCode: ticketCode,
        userId: user.id,
        userName: '${user.firstName} ${user.lastName}'.trim(),
        userEmail: user.email,
        userPhone: user.phoneNumber,
        category: category,
        priority: priority,
        status: TicketStatus.open,
        title: (values['title'] as String).trim(),
        description: (values['description'] as String).trim(),
        relatedInspectionId: values['inspection_id'] as String?,
        relatedBatchId: values['batch_id'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(ticketServiceProvider).createTicket(ticket);

      if (!mounted) return;

      Navigator.pop(context, true);
      CustomSnackBar.success(
        context,
        message: 'Ticket $ticketCode submitted successfully! IT / Managers have been notified.',
        title: 'Ticket Raised',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, message: 'Failed to submit ticket: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'category': 'mistake_correction',
            'priority': 'medium',
            if (widget.prefilledInspectionId != null) 'inspection_id': widget.prefilledInspectionId,
            if (widget.prefilledBatchId != null) 'batch_id': widget.prefilledBatchId,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(16.h),

              // Title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.support_agent_outlined, color: AppColors.darkRed, size: 24.r),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "Raise Correction / Issue Ticket",
                          variant: TextVariant.headlineMedium,
                          fontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          "Notify IT team or Managers to correct mistakes or report system issues",
                          variant: TextVariant.bodySmall,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(20.h),
              const Divider(),
              Gap(16.h),

              // Category Selector
              CustomText("Issue Type / Category", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              Gap(8.h),
              FormBuilderDropdown<String>(
                name: 'category',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                items: TicketCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat.name,
                    child: Text(cat.label),
                  );
                }).toList(),
              ),
              Gap(16.h),

              // Priority Selector
              CustomText("Priority", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              Gap(8.h),
              FormBuilderDropdown<String>(
                name: 'priority',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                items: TicketPriority.values.map((p) {
                  return DropdownMenuItem(
                    value: p.name,
                    child: Text(p.label),
                  );
                }).toList(),
              ),
              Gap(16.h),

              // Inspection ID (optional / pre-filled)
              CustomTextField(
                name: 'inspection_id',
                label: "Related Inspection ID (Optional)",
                hint: "e.g. INS-20260114-XXXX",
                prefixIcon: Icons.receipt_long_outlined,
              ),
              Gap(16.h),

              // Title
              CustomTextField(
                name: 'title',
                label: "Subject / Summary",
                hint: "e.g., Wrong Moisture Entry on Truck GR-1234",
                prefixIcon: Icons.title_outlined,
                validator: FormBuilderValidators.required(errorText: "Please enter a subject"),
              ),
              Gap(16.h),

              // Description
              CustomText("Detailed Description of Mistake or Malfunction", variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold),
              Gap(8.h),
              FormBuilderTextField(
                name: 'description',
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Explain exactly what mistake happened, what needs correction, or how the system malfunctioned...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: FormBuilderValidators.required(errorText: "Please describe the issue"),
              ),
              Gap(24.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      variant: ButtonVariant.outlined,
                      borderColor: colorScheme.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: CustomButton(
                      text: "Submit Ticket",
                      isLoading: _isSubmitting,
                      onPressed: _submitTicket,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
