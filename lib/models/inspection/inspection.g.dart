// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inspection _$InspectionFromJson(Map<String, dynamic> json) => _Inspection(
  id: json['id'] as String,
  inspectionId: json['inspection_id'] as String?,
  inspectorId: json['inspector_id'] as String,
  batchId: json['batch_id'] as String?,
  farmerName: json['farmer_name'] as String?,
  location: json['location'] as String?,
  capturedLocation: json['captured_location'] == null
      ? null
      : CapturedLocation.fromJson(
          json['captured_location'] as Map<String, dynamic>,
        ),
  town: json['town'] as String?,
  chapter: json['chapter'] as String?,
  exactLocation: json['exact_location'] as String?,
  truckNumber: json['truck_number'] as String?,
  company: json['company'] as String?,
  buyerName: json['buyer_name'] as String?,
  waybillNumber: json['waybill_number'] as String?,
  analysisType: json['analysis_type'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
  quantityBags: (json['quantity_bags'] as num?)?.toInt() ?? 0,
  cutTests:
      (json['cut_tests'] as List<dynamic>?)
          ?.map((e) => CutTest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CutTest>[],
  moistureContent: (json['moisture_content'] as num?)?.toDouble() ?? 0.0,
  nutCount: (json['nut_count'] as num?)?.toInt() ?? 0,
  kor: (json['kor'] as num?)?.toDouble() ?? 0.0,
  goodKernels: (json['good_kernels'] as num?)?.toDouble() ?? 0.0,
  spottedKernels: (json['spotted_kernels'] as num?)?.toDouble() ?? 0.0,
  immatureKernels: (json['immature_kernels'] as num?)?.toDouble() ?? 0.0,
  oilyKernels: (json['oily_kernels'] as num?)?.toDouble() ?? 0.0,
  voidKernels: (json['void_kernels'] as num?)?.toDouble() ?? 0.0,
  fullyDamagedKernels:
      (json['fully_damaged_kernels'] as num?)?.toDouble() ?? 0.0,
  emptyShells: (json['empty_shells'] as num?)?.toDouble() ?? 0.0,
  totalDefective: (json['total_defective'] as num?)?.toDouble() ?? 0.0,
  totalSpotted: (json['total_spotted'] as num?)?.toDouble() ?? 0.0,
  imageUrls:
      (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(
        _$InspectionStatusEnumMap,
        json['status'],
        unknownValue: InspectionStatus.pending,
      ) ??
      InspectionStatus.pending,
  notes: json['notes'] as String?,
  qcCode: json['qc_code'] as String?,
  blNumber: json['bl_number'] as String?,
  shipperDetails: json['shipper_details'] as String?,
  consigneeDetails: json['consignee_details'] as String?,
  originCountry: json['origin_country'] as String? ?? 'GHANA',
  destinationCountry: json['destination_country'] as String?,
  transportDescription: json['transport_description'] as String?,
  pod: json['pod'] as String?,
  pol: json['pol'] as String?,
  containerCountAndSizes: json['container_count_and_sizes'] as String?,
  grossWeight: (json['gross_weight'] as num?)?.toDouble(),
  netWeight: (json['net_weight'] as num?)?.toDouble(),
  packageDescription: json['package_description'] as String?,
  samplePlaceAndDate: json['sample_place_and_date'] as String?,
  cuttingTestPlaceAndDate: json['cutting_test_place_and_date'] as String?,
  isAuthorized: json['is_authorized'] as bool? ?? false,
  authorizedSignature: json['authorized_signature'] as String?,
  authorizedBy: json['authorized_by'] as String?,
  cuttingImageUrls:
      (json['cutting_image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  inspectorName: json['inspector_name'] as String?,
  inspectorEmail: json['inspector_email'] as String?,
  reportFeeAmount: (json['report_fee_amount'] as num?)?.toDouble() ?? 0.0,
  reportFeeCurrency: json['report_fee_currency'] as String? ?? 'GHS',
  reportFeeStatus: json['report_fee_status'] as String? ?? 'not_required',
  reportFeeEvidenceUrl: json['report_fee_evidence_url'] as String? ?? '',
  reportFeeReference: json['report_fee_reference'] as String? ?? '',
  reportFeeMomoNetwork: json['report_fee_momo_network'] as String? ?? '',
  reportFeeMomoNumber: json['report_fee_momo_number'] as String? ?? '',
  reportFeeMomoAccountName:
      json['report_fee_momo_account_name'] as String? ?? '',
  reportFeePaidAt: json['report_fee_paid_at'] as String? ?? '',
  reportFeeVerifiedAt: json['report_fee_verified_at'] as String? ?? '',
  reportFeeVerifiedBy: json['report_fee_verified_by'] as String? ?? '',
  approvalStatus: json['approval_status'] as String? ?? 'not_required',
  approvalRequestedAt: json['approval_requested_at'] as String? ?? '',
  approvedAt: json['approved_at'] as String? ?? '',
  approvedByUid: json['approved_by_uid'] as String? ?? '',
  approvedByName: json['approved_by_name'] as String? ?? '',
  approvalSealUrl: json['approval_seal_url'] as String? ?? '',
  approvalSealIncludesSignature:
      json['approval_seal_includes_signature'] as bool? ?? false,
  declinedAt: json['declined_at'] as String? ?? '',
  declineReason: json['decline_reason'] as String? ?? '',
  declinedByUid: json['declined_by_uid'] as String? ?? '',
  declinedByName: json['declined_by_name'] as String? ?? '',
  reportPhotos:
      (json['report_photos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$InspectionToJson(
  _Inspection instance,
) => <String, dynamic>{
  'id': instance.id,
  'inspection_id': instance.inspectionId,
  'inspector_id': instance.inspectorId,
  'batch_id': instance.batchId,
  'farmer_name': instance.farmerName,
  'location': instance.location,
  'captured_location': instance.capturedLocation?.toJson(),
  'town': instance.town,
  'chapter': instance.chapter,
  'exact_location': instance.exactLocation,
  'truck_number': instance.truckNumber,
  'company': instance.company,
  'buyer_name': instance.buyerName,
  'waybill_number': instance.waybillNumber,
  'analysis_type': instance.analysisType,
  'quantity': instance.quantity,
  'quantity_bags': instance.quantityBags,
  'cut_tests': instance.cutTests.map((e) => e.toJson()).toList(),
  'moisture_content': instance.moistureContent,
  'nut_count': instance.nutCount,
  'kor': instance.kor,
  'good_kernels': instance.goodKernels,
  'spotted_kernels': instance.spottedKernels,
  'immature_kernels': instance.immatureKernels,
  'oily_kernels': instance.oilyKernels,
  'void_kernels': instance.voidKernels,
  'fully_damaged_kernels': instance.fullyDamagedKernels,
  'empty_shells': instance.emptyShells,
  'total_defective': instance.totalDefective,
  'total_spotted': instance.totalSpotted,
  'image_urls': instance.imageUrls,
  'status': _$InspectionStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'qc_code': instance.qcCode,
  'bl_number': instance.blNumber,
  'shipper_details': instance.shipperDetails,
  'consignee_details': instance.consigneeDetails,
  'origin_country': instance.originCountry,
  'destination_country': instance.destinationCountry,
  'transport_description': instance.transportDescription,
  'pod': instance.pod,
  'pol': instance.pol,
  'container_count_and_sizes': instance.containerCountAndSizes,
  'gross_weight': instance.grossWeight,
  'net_weight': instance.netWeight,
  'package_description': instance.packageDescription,
  'sample_place_and_date': instance.samplePlaceAndDate,
  'cutting_test_place_and_date': instance.cuttingTestPlaceAndDate,
  'is_authorized': instance.isAuthorized,
  'authorized_signature': instance.authorizedSignature,
  'authorized_by': instance.authorizedBy,
  'cutting_image_urls': instance.cuttingImageUrls,
  'inspector_name': instance.inspectorName,
  'inspector_email': instance.inspectorEmail,
  'report_fee_amount': instance.reportFeeAmount,
  'report_fee_currency': instance.reportFeeCurrency,
  'report_fee_status': instance.reportFeeStatus,
  'report_fee_evidence_url': instance.reportFeeEvidenceUrl,
  'report_fee_reference': instance.reportFeeReference,
  'report_fee_momo_network': instance.reportFeeMomoNetwork,
  'report_fee_momo_number': instance.reportFeeMomoNumber,
  'report_fee_momo_account_name': instance.reportFeeMomoAccountName,
  'report_fee_paid_at': instance.reportFeePaidAt,
  'report_fee_verified_at': instance.reportFeeVerifiedAt,
  'report_fee_verified_by': instance.reportFeeVerifiedBy,
  'approval_status': instance.approvalStatus,
  'approval_requested_at': instance.approvalRequestedAt,
  'approved_at': instance.approvedAt,
  'approved_by_uid': instance.approvedByUid,
  'approved_by_name': instance.approvedByName,
  'approval_seal_url': instance.approvalSealUrl,
  'approval_seal_includes_signature': instance.approvalSealIncludesSignature,
  'declined_at': instance.declinedAt,
  'decline_reason': instance.declineReason,
  'declined_by_uid': instance.declinedByUid,
  'declined_by_name': instance.declinedByName,
  'report_photos': instance.reportPhotos,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
};

const _$InspectionStatusEnumMap = {
  InspectionStatus.pending: 'pending',
  InspectionStatus.inProgress: 'in_progress',
  InspectionStatus.completed: 'completed',
  InspectionStatus.rejected: 'rejected',
  InspectionStatus.pendingSync: 'pending_sync',
  InspectionStatus.pendingApproval: 'pending_approval',
  InspectionStatus.approvalDeclined: 'approval_declined',
};
