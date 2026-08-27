// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupportTicket _$SupportTicketFromJson(Map<String, dynamic> json) =>
    _SupportTicket(
      id: json['id'] as String,
      ticketCode: json['ticket_code'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userEmail: json['user_email'] as String,
      userPhone: json['user_phone'] as String?,
      category:
          $enumDecodeNullable(_$TicketCategoryEnumMap, json['category']) ??
          TicketCategory.mistakeCorrection,
      priority:
          $enumDecodeNullable(_$TicketPriorityEnumMap, json['priority']) ??
          TicketPriority.medium,
      status:
          $enumDecodeNullable(_$TicketStatusEnumMap, json['status']) ??
          TicketStatus.open,
      title: json['title'] as String,
      description: json['description'] as String,
      relatedInspectionId: json['related_inspection_id'] as String?,
      relatedBatchId: json['related_batch_id'] as String?,
      attachmentUrls:
          (json['attachment_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      resolutionNotes: json['resolution_notes'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SupportTicketToJson(_SupportTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_code': instance.ticketCode,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'user_email': instance.userEmail,
      'user_phone': instance.userPhone,
      'category': _$TicketCategoryEnumMap[instance.category]!,
      'priority': _$TicketPriorityEnumMap[instance.priority]!,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'title': instance.title,
      'description': instance.description,
      'related_inspection_id': instance.relatedInspectionId,
      'related_batch_id': instance.relatedBatchId,
      'attachment_urls': instance.attachmentUrls,
      'resolution_notes': instance.resolutionNotes,
      'resolved_by': instance.resolvedBy,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$TicketCategoryEnumMap = {
  TicketCategory.mistakeCorrection: 'mistake_correction',
  TicketCategory.systemMalfunction: 'system_malfunction',
  TicketCategory.reportError: 'report_error',
  TicketCategory.billing: 'billing',
  TicketCategory.other: 'other',
};

const _$TicketPriorityEnumMap = {
  TicketPriority.low: 'low',
  TicketPriority.medium: 'medium',
  TicketPriority.high: 'high',
  TicketPriority.urgent: 'urgent',
};

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'open',
  TicketStatus.inProgress: 'in_progress',
  TicketStatus.resolved: 'resolved',
  TicketStatus.closed: 'closed',
};
