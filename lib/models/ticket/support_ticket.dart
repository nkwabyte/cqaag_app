import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_ticket.freezed.dart';
part 'support_ticket.g.dart';

enum TicketCategory {
  @JsonValue('mistake_correction')
  mistakeCorrection,
  @JsonValue('system_malfunction')
  systemMalfunction,
  @JsonValue('report_error')
  reportError,
  @JsonValue('billing')
  billing,
  @JsonValue('other')
  other;

  String get label {
    switch (this) {
      case TicketCategory.mistakeCorrection:
        return 'Data / Mistake Correction';
      case TicketCategory.systemMalfunction:
        return 'System Malfunction';
      case TicketCategory.reportError:
        return 'Inspection Report Issue';
      case TicketCategory.billing:
        return 'Billing / Payment Issue';
      case TicketCategory.other:
        return 'Other Assistance';
    }
  }
}

enum TicketStatus {
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed;

  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }
}

enum TicketPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent;

  String get label {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }
}

@freezed
abstract class SupportTicket with _$SupportTicket {
  const SupportTicket._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SupportTicket({
    required String id,
    required String ticketCode, // e.g. TCK-2026-0012
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    @Default(TicketCategory.mistakeCorrection) TicketCategory category,
    @Default(TicketPriority.medium) TicketPriority priority,
    @Default(TicketStatus.open) TicketStatus status,
    required String title,
    required String description,
    String? relatedInspectionId,
    String? relatedBatchId,
    @Default([]) List<String> attachmentUrls,
    String? resolutionNotes,
    String? resolvedBy,
    DateTime? resolvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SupportTicket;

  factory SupportTicket.fromJson(Map<String, dynamic> json) => _$SupportTicketFromJson(json);
}
