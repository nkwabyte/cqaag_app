// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Inspection {

 String get id;// Firebase auto-generated document ID
 String? get inspectionId;// Custom inspection ID (e.g., INS-20260114-4X9P)
 String get inspectorId;// Batch and Farmer Info
 String? get batchId; String? get farmerName;// Acts as Supplier/Farmer Name
 String? get location;// Text-based location (e.g., "Wenchi District, Bono Region")
 CapturedLocation? get capturedLocation;// GPS-captured location with coordinates
 String? get town; String? get chapter; String? get exactLocation;// Basic Info
 String? get truckNumber; String? get company; String? get buyerName; String? get waybillNumber; String? get analysisType; double get quantity; int get quantityBags;/// The individual cut tests behind this inspection, in order.
///
/// The report shows each one in its own column and the mean in AVERAGE.
/// The flat quality fields below hold that mean, so existing records and
/// the website continue to read the same values as before.
 List<CutTest> get cutTests;// Quality Metrics (averages across [cutTests])
 double get moistureContent; int get nutCount;// Raw Nut Count
 double get kor;// Defect Metrics
 double get goodKernels; double get spottedKernels; double get immatureKernels; double get oilyKernels; double get voidKernels; double get fullyDamagedKernels; double get emptyShells; double get totalDefective; double get totalSpotted; List<String> get imageUrls;@JsonKey(unknownEnumValue: InspectionStatus.pending) InspectionStatus get status; String? get notes;// Persistent QC-Code for this inspection
 String? get qcCode;// Export Specific RCN Quality Report Fields
 String? get blNumber; String? get shipperDetails; String? get consigneeDetails; String get originCountry; String? get destinationCountry; String? get transportDescription; String? get pod;// Port of Destination
 String? get pol;// Port of Loading
 String? get containerCountAndSizes; double? get grossWeight; double? get netWeight; String? get packageDescription; String? get samplePlaceAndDate; String? get cuttingTestPlaceAndDate; bool get isAuthorized; String? get authorizedSignature; String? get authorizedBy; List<String> get cuttingImageUrls;// Analyst identity, denormalised so the approval desk and the decision
// email do not have to look the analyst up.
 String? get inspectorName; String? get inspectorEmail;// Certificate fee — paid before a Moisture Control, Dispatch, Export or
// Arbitration certificate can be submitted. Field names match the website.
 double get reportFeeAmount; String get reportFeeCurrency;/// `not_required`, `pending_verification`, `verified` or `rejected`.
 String get reportFeeStatus; String get reportFeeEvidenceUrl; String get reportFeeReference; String get reportFeeMomoNetwork; String get reportFeeMomoNumber; String get reportFeeMomoAccountName; String get reportFeePaidAt; String get reportFeeVerifiedAt; String get reportFeeVerifiedBy;// CQAAG approval — Export certificates are not valid until approved.
//
// Dates are ISO strings, left empty until set: the shared Firestore rules
// reject an Export certificate created with anything but an empty
// `approved_at` and `approval_seal_url`.
 String get approvalStatus; String get approvalRequestedAt; String get approvedAt; String get approvedByUid; String get approvedByName;/// Image of the association seal, with the president's signature embedded
/// when an admin has uploaded the signed seal, copied on at approval time.
 String get approvalSealUrl; bool get approvalSealIncludesSignature; String get declinedAt; String get declineReason; String get declinedByUid; String get declinedByName;/// Export cutting pictures uploaded from the website.
 List<String> get reportPhotos;// Timestamps
 DateTime? get createdAt; DateTime? get updatedAt; DateTime? get completedAt;
/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionCopyWith<Inspection> get copyWith => _$InspectionCopyWithImpl<Inspection>(this as Inspection, _$identity);

  /// Serializes this Inspection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.farmerName, farmerName) || other.farmerName == farmerName)&&(identical(other.location, location) || other.location == location)&&(identical(other.capturedLocation, capturedLocation) || other.capturedLocation == capturedLocation)&&(identical(other.town, town) || other.town == town)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.exactLocation, exactLocation) || other.exactLocation == exactLocation)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.company, company) || other.company == company)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.waybillNumber, waybillNumber) || other.waybillNumber == waybillNumber)&&(identical(other.analysisType, analysisType) || other.analysisType == analysisType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityBags, quantityBags) || other.quantityBags == quantityBags)&&const DeepCollectionEquality().equals(other.cutTests, cutTests)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.kor, kor) || other.kor == kor)&&(identical(other.goodKernels, goodKernels) || other.goodKernels == goodKernels)&&(identical(other.spottedKernels, spottedKernels) || other.spottedKernels == spottedKernels)&&(identical(other.immatureKernels, immatureKernels) || other.immatureKernels == immatureKernels)&&(identical(other.oilyKernels, oilyKernels) || other.oilyKernels == oilyKernels)&&(identical(other.voidKernels, voidKernels) || other.voidKernels == voidKernels)&&(identical(other.fullyDamagedKernels, fullyDamagedKernels) || other.fullyDamagedKernels == fullyDamagedKernels)&&(identical(other.emptyShells, emptyShells) || other.emptyShells == emptyShells)&&(identical(other.totalDefective, totalDefective) || other.totalDefective == totalDefective)&&(identical(other.totalSpotted, totalSpotted) || other.totalSpotted == totalSpotted)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.qcCode, qcCode) || other.qcCode == qcCode)&&(identical(other.blNumber, blNumber) || other.blNumber == blNumber)&&(identical(other.shipperDetails, shipperDetails) || other.shipperDetails == shipperDetails)&&(identical(other.consigneeDetails, consigneeDetails) || other.consigneeDetails == consigneeDetails)&&(identical(other.originCountry, originCountry) || other.originCountry == originCountry)&&(identical(other.destinationCountry, destinationCountry) || other.destinationCountry == destinationCountry)&&(identical(other.transportDescription, transportDescription) || other.transportDescription == transportDescription)&&(identical(other.pod, pod) || other.pod == pod)&&(identical(other.pol, pol) || other.pol == pol)&&(identical(other.containerCountAndSizes, containerCountAndSizes) || other.containerCountAndSizes == containerCountAndSizes)&&(identical(other.grossWeight, grossWeight) || other.grossWeight == grossWeight)&&(identical(other.netWeight, netWeight) || other.netWeight == netWeight)&&(identical(other.packageDescription, packageDescription) || other.packageDescription == packageDescription)&&(identical(other.samplePlaceAndDate, samplePlaceAndDate) || other.samplePlaceAndDate == samplePlaceAndDate)&&(identical(other.cuttingTestPlaceAndDate, cuttingTestPlaceAndDate) || other.cuttingTestPlaceAndDate == cuttingTestPlaceAndDate)&&(identical(other.isAuthorized, isAuthorized) || other.isAuthorized == isAuthorized)&&(identical(other.authorizedSignature, authorizedSignature) || other.authorizedSignature == authorizedSignature)&&(identical(other.authorizedBy, authorizedBy) || other.authorizedBy == authorizedBy)&&const DeepCollectionEquality().equals(other.cuttingImageUrls, cuttingImageUrls)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.inspectorEmail, inspectorEmail) || other.inspectorEmail == inspectorEmail)&&(identical(other.reportFeeAmount, reportFeeAmount) || other.reportFeeAmount == reportFeeAmount)&&(identical(other.reportFeeCurrency, reportFeeCurrency) || other.reportFeeCurrency == reportFeeCurrency)&&(identical(other.reportFeeStatus, reportFeeStatus) || other.reportFeeStatus == reportFeeStatus)&&(identical(other.reportFeeEvidenceUrl, reportFeeEvidenceUrl) || other.reportFeeEvidenceUrl == reportFeeEvidenceUrl)&&(identical(other.reportFeeReference, reportFeeReference) || other.reportFeeReference == reportFeeReference)&&(identical(other.reportFeeMomoNetwork, reportFeeMomoNetwork) || other.reportFeeMomoNetwork == reportFeeMomoNetwork)&&(identical(other.reportFeeMomoNumber, reportFeeMomoNumber) || other.reportFeeMomoNumber == reportFeeMomoNumber)&&(identical(other.reportFeeMomoAccountName, reportFeeMomoAccountName) || other.reportFeeMomoAccountName == reportFeeMomoAccountName)&&(identical(other.reportFeePaidAt, reportFeePaidAt) || other.reportFeePaidAt == reportFeePaidAt)&&(identical(other.reportFeeVerifiedAt, reportFeeVerifiedAt) || other.reportFeeVerifiedAt == reportFeeVerifiedAt)&&(identical(other.reportFeeVerifiedBy, reportFeeVerifiedBy) || other.reportFeeVerifiedBy == reportFeeVerifiedBy)&&(identical(other.approvalStatus, approvalStatus) || other.approvalStatus == approvalStatus)&&(identical(other.approvalRequestedAt, approvalRequestedAt) || other.approvalRequestedAt == approvalRequestedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedByUid, approvedByUid) || other.approvedByUid == approvedByUid)&&(identical(other.approvedByName, approvedByName) || other.approvedByName == approvedByName)&&(identical(other.approvalSealUrl, approvalSealUrl) || other.approvalSealUrl == approvalSealUrl)&&(identical(other.approvalSealIncludesSignature, approvalSealIncludesSignature) || other.approvalSealIncludesSignature == approvalSealIncludesSignature)&&(identical(other.declinedAt, declinedAt) || other.declinedAt == declinedAt)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.declinedByUid, declinedByUid) || other.declinedByUid == declinedByUid)&&(identical(other.declinedByName, declinedByName) || other.declinedByName == declinedByName)&&const DeepCollectionEquality().equals(other.reportPhotos, reportPhotos)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,inspectionId,inspectorId,batchId,farmerName,location,capturedLocation,town,chapter,exactLocation,truckNumber,company,buyerName,waybillNumber,analysisType,quantity,quantityBags,const DeepCollectionEquality().hash(cutTests),moistureContent,nutCount,kor,goodKernels,spottedKernels,immatureKernels,oilyKernels,voidKernels,fullyDamagedKernels,emptyShells,totalDefective,totalSpotted,const DeepCollectionEquality().hash(imageUrls),status,notes,qcCode,blNumber,shipperDetails,consigneeDetails,originCountry,destinationCountry,transportDescription,pod,pol,containerCountAndSizes,grossWeight,netWeight,packageDescription,samplePlaceAndDate,cuttingTestPlaceAndDate,isAuthorized,authorizedSignature,authorizedBy,const DeepCollectionEquality().hash(cuttingImageUrls),inspectorName,inspectorEmail,reportFeeAmount,reportFeeCurrency,reportFeeStatus,reportFeeEvidenceUrl,reportFeeReference,reportFeeMomoNetwork,reportFeeMomoNumber,reportFeeMomoAccountName,reportFeePaidAt,reportFeeVerifiedAt,reportFeeVerifiedBy,approvalStatus,approvalRequestedAt,approvedAt,approvedByUid,approvedByName,approvalSealUrl,approvalSealIncludesSignature,declinedAt,declineReason,declinedByUid,declinedByName,const DeepCollectionEquality().hash(reportPhotos),createdAt,updatedAt,completedAt]);

@override
String toString() {
  return 'Inspection(id: $id, inspectionId: $inspectionId, inspectorId: $inspectorId, batchId: $batchId, farmerName: $farmerName, location: $location, capturedLocation: $capturedLocation, town: $town, chapter: $chapter, exactLocation: $exactLocation, truckNumber: $truckNumber, company: $company, buyerName: $buyerName, waybillNumber: $waybillNumber, analysisType: $analysisType, quantity: $quantity, quantityBags: $quantityBags, cutTests: $cutTests, moistureContent: $moistureContent, nutCount: $nutCount, kor: $kor, goodKernels: $goodKernels, spottedKernels: $spottedKernels, immatureKernels: $immatureKernels, oilyKernels: $oilyKernels, voidKernels: $voidKernels, fullyDamagedKernels: $fullyDamagedKernels, emptyShells: $emptyShells, totalDefective: $totalDefective, totalSpotted: $totalSpotted, imageUrls: $imageUrls, status: $status, notes: $notes, qcCode: $qcCode, blNumber: $blNumber, shipperDetails: $shipperDetails, consigneeDetails: $consigneeDetails, originCountry: $originCountry, destinationCountry: $destinationCountry, transportDescription: $transportDescription, pod: $pod, pol: $pol, containerCountAndSizes: $containerCountAndSizes, grossWeight: $grossWeight, netWeight: $netWeight, packageDescription: $packageDescription, samplePlaceAndDate: $samplePlaceAndDate, cuttingTestPlaceAndDate: $cuttingTestPlaceAndDate, isAuthorized: $isAuthorized, authorizedSignature: $authorizedSignature, authorizedBy: $authorizedBy, cuttingImageUrls: $cuttingImageUrls, inspectorName: $inspectorName, inspectorEmail: $inspectorEmail, reportFeeAmount: $reportFeeAmount, reportFeeCurrency: $reportFeeCurrency, reportFeeStatus: $reportFeeStatus, reportFeeEvidenceUrl: $reportFeeEvidenceUrl, reportFeeReference: $reportFeeReference, reportFeeMomoNetwork: $reportFeeMomoNetwork, reportFeeMomoNumber: $reportFeeMomoNumber, reportFeeMomoAccountName: $reportFeeMomoAccountName, reportFeePaidAt: $reportFeePaidAt, reportFeeVerifiedAt: $reportFeeVerifiedAt, reportFeeVerifiedBy: $reportFeeVerifiedBy, approvalStatus: $approvalStatus, approvalRequestedAt: $approvalRequestedAt, approvedAt: $approvedAt, approvedByUid: $approvedByUid, approvedByName: $approvedByName, approvalSealUrl: $approvalSealUrl, approvalSealIncludesSignature: $approvalSealIncludesSignature, declinedAt: $declinedAt, declineReason: $declineReason, declinedByUid: $declinedByUid, declinedByName: $declinedByName, reportPhotos: $reportPhotos, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $InspectionCopyWith<$Res>  {
  factory $InspectionCopyWith(Inspection value, $Res Function(Inspection) _then) = _$InspectionCopyWithImpl;
@useResult
$Res call({
 String id, String? inspectionId, String inspectorId, String? batchId, String? farmerName, String? location, CapturedLocation? capturedLocation, String? town, String? chapter, String? exactLocation, String? truckNumber, String? company, String? buyerName, String? waybillNumber, String? analysisType, double quantity, int quantityBags, List<CutTest> cutTests, double moistureContent, int nutCount, double kor, double goodKernels, double spottedKernels, double immatureKernels, double oilyKernels, double voidKernels, double fullyDamagedKernels, double emptyShells, double totalDefective, double totalSpotted, List<String> imageUrls,@JsonKey(unknownEnumValue: InspectionStatus.pending) InspectionStatus status, String? notes, String? qcCode, String? blNumber, String? shipperDetails, String? consigneeDetails, String originCountry, String? destinationCountry, String? transportDescription, String? pod, String? pol, String? containerCountAndSizes, double? grossWeight, double? netWeight, String? packageDescription, String? samplePlaceAndDate, String? cuttingTestPlaceAndDate, bool isAuthorized, String? authorizedSignature, String? authorizedBy, List<String> cuttingImageUrls, String? inspectorName, String? inspectorEmail, double reportFeeAmount, String reportFeeCurrency, String reportFeeStatus, String reportFeeEvidenceUrl, String reportFeeReference, String reportFeeMomoNetwork, String reportFeeMomoNumber, String reportFeeMomoAccountName, String reportFeePaidAt, String reportFeeVerifiedAt, String reportFeeVerifiedBy, String approvalStatus, String approvalRequestedAt, String approvedAt, String approvedByUid, String approvedByName, String approvalSealUrl, bool approvalSealIncludesSignature, String declinedAt, String declineReason, String declinedByUid, String declinedByName, List<String> reportPhotos, DateTime? createdAt, DateTime? updatedAt, DateTime? completedAt
});


$CapturedLocationCopyWith<$Res>? get capturedLocation;

}
/// @nodoc
class _$InspectionCopyWithImpl<$Res>
    implements $InspectionCopyWith<$Res> {
  _$InspectionCopyWithImpl(this._self, this._then);

  final Inspection _self;
  final $Res Function(Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectionId = freezed,Object? inspectorId = null,Object? batchId = freezed,Object? farmerName = freezed,Object? location = freezed,Object? capturedLocation = freezed,Object? town = freezed,Object? chapter = freezed,Object? exactLocation = freezed,Object? truckNumber = freezed,Object? company = freezed,Object? buyerName = freezed,Object? waybillNumber = freezed,Object? analysisType = freezed,Object? quantity = null,Object? quantityBags = null,Object? cutTests = null,Object? moistureContent = null,Object? nutCount = null,Object? kor = null,Object? goodKernels = null,Object? spottedKernels = null,Object? immatureKernels = null,Object? oilyKernels = null,Object? voidKernels = null,Object? fullyDamagedKernels = null,Object? emptyShells = null,Object? totalDefective = null,Object? totalSpotted = null,Object? imageUrls = null,Object? status = null,Object? notes = freezed,Object? qcCode = freezed,Object? blNumber = freezed,Object? shipperDetails = freezed,Object? consigneeDetails = freezed,Object? originCountry = null,Object? destinationCountry = freezed,Object? transportDescription = freezed,Object? pod = freezed,Object? pol = freezed,Object? containerCountAndSizes = freezed,Object? grossWeight = freezed,Object? netWeight = freezed,Object? packageDescription = freezed,Object? samplePlaceAndDate = freezed,Object? cuttingTestPlaceAndDate = freezed,Object? isAuthorized = null,Object? authorizedSignature = freezed,Object? authorizedBy = freezed,Object? cuttingImageUrls = null,Object? inspectorName = freezed,Object? inspectorEmail = freezed,Object? reportFeeAmount = null,Object? reportFeeCurrency = null,Object? reportFeeStatus = null,Object? reportFeeEvidenceUrl = null,Object? reportFeeReference = null,Object? reportFeeMomoNetwork = null,Object? reportFeeMomoNumber = null,Object? reportFeeMomoAccountName = null,Object? reportFeePaidAt = null,Object? reportFeeVerifiedAt = null,Object? reportFeeVerifiedBy = null,Object? approvalStatus = null,Object? approvalRequestedAt = null,Object? approvedAt = null,Object? approvedByUid = null,Object? approvedByName = null,Object? approvalSealUrl = null,Object? approvalSealIncludesSignature = null,Object? declinedAt = null,Object? declineReason = null,Object? declinedByUid = null,Object? declinedByName = null,Object? reportPhotos = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: freezed == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String?,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String?,farmerName: freezed == farmerName ? _self.farmerName : farmerName // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,capturedLocation: freezed == capturedLocation ? _self.capturedLocation : capturedLocation // ignore: cast_nullable_to_non_nullable
as CapturedLocation?,town: freezed == town ? _self.town : town // ignore: cast_nullable_to_non_nullable
as String?,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as String?,exactLocation: freezed == exactLocation ? _self.exactLocation : exactLocation // ignore: cast_nullable_to_non_nullable
as String?,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,buyerName: freezed == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String?,waybillNumber: freezed == waybillNumber ? _self.waybillNumber : waybillNumber // ignore: cast_nullable_to_non_nullable
as String?,analysisType: freezed == analysisType ? _self.analysisType : analysisType // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,quantityBags: null == quantityBags ? _self.quantityBags : quantityBags // ignore: cast_nullable_to_non_nullable
as int,cutTests: null == cutTests ? _self.cutTests : cutTests // ignore: cast_nullable_to_non_nullable
as List<CutTest>,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,kor: null == kor ? _self.kor : kor // ignore: cast_nullable_to_non_nullable
as double,goodKernels: null == goodKernels ? _self.goodKernels : goodKernels // ignore: cast_nullable_to_non_nullable
as double,spottedKernels: null == spottedKernels ? _self.spottedKernels : spottedKernels // ignore: cast_nullable_to_non_nullable
as double,immatureKernels: null == immatureKernels ? _self.immatureKernels : immatureKernels // ignore: cast_nullable_to_non_nullable
as double,oilyKernels: null == oilyKernels ? _self.oilyKernels : oilyKernels // ignore: cast_nullable_to_non_nullable
as double,voidKernels: null == voidKernels ? _self.voidKernels : voidKernels // ignore: cast_nullable_to_non_nullable
as double,fullyDamagedKernels: null == fullyDamagedKernels ? _self.fullyDamagedKernels : fullyDamagedKernels // ignore: cast_nullable_to_non_nullable
as double,emptyShells: null == emptyShells ? _self.emptyShells : emptyShells // ignore: cast_nullable_to_non_nullable
as double,totalDefective: null == totalDefective ? _self.totalDefective : totalDefective // ignore: cast_nullable_to_non_nullable
as double,totalSpotted: null == totalSpotted ? _self.totalSpotted : totalSpotted // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,qcCode: freezed == qcCode ? _self.qcCode : qcCode // ignore: cast_nullable_to_non_nullable
as String?,blNumber: freezed == blNumber ? _self.blNumber : blNumber // ignore: cast_nullable_to_non_nullable
as String?,shipperDetails: freezed == shipperDetails ? _self.shipperDetails : shipperDetails // ignore: cast_nullable_to_non_nullable
as String?,consigneeDetails: freezed == consigneeDetails ? _self.consigneeDetails : consigneeDetails // ignore: cast_nullable_to_non_nullable
as String?,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as String,destinationCountry: freezed == destinationCountry ? _self.destinationCountry : destinationCountry // ignore: cast_nullable_to_non_nullable
as String?,transportDescription: freezed == transportDescription ? _self.transportDescription : transportDescription // ignore: cast_nullable_to_non_nullable
as String?,pod: freezed == pod ? _self.pod : pod // ignore: cast_nullable_to_non_nullable
as String?,pol: freezed == pol ? _self.pol : pol // ignore: cast_nullable_to_non_nullable
as String?,containerCountAndSizes: freezed == containerCountAndSizes ? _self.containerCountAndSizes : containerCountAndSizes // ignore: cast_nullable_to_non_nullable
as String?,grossWeight: freezed == grossWeight ? _self.grossWeight : grossWeight // ignore: cast_nullable_to_non_nullable
as double?,netWeight: freezed == netWeight ? _self.netWeight : netWeight // ignore: cast_nullable_to_non_nullable
as double?,packageDescription: freezed == packageDescription ? _self.packageDescription : packageDescription // ignore: cast_nullable_to_non_nullable
as String?,samplePlaceAndDate: freezed == samplePlaceAndDate ? _self.samplePlaceAndDate : samplePlaceAndDate // ignore: cast_nullable_to_non_nullable
as String?,cuttingTestPlaceAndDate: freezed == cuttingTestPlaceAndDate ? _self.cuttingTestPlaceAndDate : cuttingTestPlaceAndDate // ignore: cast_nullable_to_non_nullable
as String?,isAuthorized: null == isAuthorized ? _self.isAuthorized : isAuthorized // ignore: cast_nullable_to_non_nullable
as bool,authorizedSignature: freezed == authorizedSignature ? _self.authorizedSignature : authorizedSignature // ignore: cast_nullable_to_non_nullable
as String?,authorizedBy: freezed == authorizedBy ? _self.authorizedBy : authorizedBy // ignore: cast_nullable_to_non_nullable
as String?,cuttingImageUrls: null == cuttingImageUrls ? _self.cuttingImageUrls : cuttingImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,inspectorName: freezed == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String?,inspectorEmail: freezed == inspectorEmail ? _self.inspectorEmail : inspectorEmail // ignore: cast_nullable_to_non_nullable
as String?,reportFeeAmount: null == reportFeeAmount ? _self.reportFeeAmount : reportFeeAmount // ignore: cast_nullable_to_non_nullable
as double,reportFeeCurrency: null == reportFeeCurrency ? _self.reportFeeCurrency : reportFeeCurrency // ignore: cast_nullable_to_non_nullable
as String,reportFeeStatus: null == reportFeeStatus ? _self.reportFeeStatus : reportFeeStatus // ignore: cast_nullable_to_non_nullable
as String,reportFeeEvidenceUrl: null == reportFeeEvidenceUrl ? _self.reportFeeEvidenceUrl : reportFeeEvidenceUrl // ignore: cast_nullable_to_non_nullable
as String,reportFeeReference: null == reportFeeReference ? _self.reportFeeReference : reportFeeReference // ignore: cast_nullable_to_non_nullable
as String,reportFeeMomoNetwork: null == reportFeeMomoNetwork ? _self.reportFeeMomoNetwork : reportFeeMomoNetwork // ignore: cast_nullable_to_non_nullable
as String,reportFeeMomoNumber: null == reportFeeMomoNumber ? _self.reportFeeMomoNumber : reportFeeMomoNumber // ignore: cast_nullable_to_non_nullable
as String,reportFeeMomoAccountName: null == reportFeeMomoAccountName ? _self.reportFeeMomoAccountName : reportFeeMomoAccountName // ignore: cast_nullable_to_non_nullable
as String,reportFeePaidAt: null == reportFeePaidAt ? _self.reportFeePaidAt : reportFeePaidAt // ignore: cast_nullable_to_non_nullable
as String,reportFeeVerifiedAt: null == reportFeeVerifiedAt ? _self.reportFeeVerifiedAt : reportFeeVerifiedAt // ignore: cast_nullable_to_non_nullable
as String,reportFeeVerifiedBy: null == reportFeeVerifiedBy ? _self.reportFeeVerifiedBy : reportFeeVerifiedBy // ignore: cast_nullable_to_non_nullable
as String,approvalStatus: null == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as String,approvalRequestedAt: null == approvalRequestedAt ? _self.approvalRequestedAt : approvalRequestedAt // ignore: cast_nullable_to_non_nullable
as String,approvedAt: null == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String,approvedByUid: null == approvedByUid ? _self.approvedByUid : approvedByUid // ignore: cast_nullable_to_non_nullable
as String,approvedByName: null == approvedByName ? _self.approvedByName : approvedByName // ignore: cast_nullable_to_non_nullable
as String,approvalSealUrl: null == approvalSealUrl ? _self.approvalSealUrl : approvalSealUrl // ignore: cast_nullable_to_non_nullable
as String,approvalSealIncludesSignature: null == approvalSealIncludesSignature ? _self.approvalSealIncludesSignature : approvalSealIncludesSignature // ignore: cast_nullable_to_non_nullable
as bool,declinedAt: null == declinedAt ? _self.declinedAt : declinedAt // ignore: cast_nullable_to_non_nullable
as String,declineReason: null == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String,declinedByUid: null == declinedByUid ? _self.declinedByUid : declinedByUid // ignore: cast_nullable_to_non_nullable
as String,declinedByName: null == declinedByName ? _self.declinedByName : declinedByName // ignore: cast_nullable_to_non_nullable
as String,reportPhotos: null == reportPhotos ? _self.reportPhotos : reportPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedLocationCopyWith<$Res>? get capturedLocation {
    if (_self.capturedLocation == null) {
    return null;
  }

  return $CapturedLocationCopyWith<$Res>(_self.capturedLocation!, (value) {
    return _then(_self.copyWith(capturedLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [Inspection].
extension InspectionPatterns on Inspection {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inspection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inspection value)  $default,){
final _that = this;
switch (_that) {
case _Inspection():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inspection value)?  $default,){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? inspectionId,  String inspectorId,  String? batchId,  String? farmerName,  String? location,  CapturedLocation? capturedLocation,  String? town,  String? chapter,  String? exactLocation,  String? truckNumber,  String? company,  String? buyerName,  String? waybillNumber,  String? analysisType,  double quantity,  int quantityBags,  List<CutTest> cutTests,  double moistureContent,  int nutCount,  double kor,  double goodKernels,  double spottedKernels,  double immatureKernels,  double oilyKernels,  double voidKernels,  double fullyDamagedKernels,  double emptyShells,  double totalDefective,  double totalSpotted,  List<String> imageUrls, @JsonKey(unknownEnumValue: InspectionStatus.pending)  InspectionStatus status,  String? notes,  String? qcCode,  String? blNumber,  String? shipperDetails,  String? consigneeDetails,  String originCountry,  String? destinationCountry,  String? transportDescription,  String? pod,  String? pol,  String? containerCountAndSizes,  double? grossWeight,  double? netWeight,  String? packageDescription,  String? samplePlaceAndDate,  String? cuttingTestPlaceAndDate,  bool isAuthorized,  String? authorizedSignature,  String? authorizedBy,  List<String> cuttingImageUrls,  String? inspectorName,  String? inspectorEmail,  double reportFeeAmount,  String reportFeeCurrency,  String reportFeeStatus,  String reportFeeEvidenceUrl,  String reportFeeReference,  String reportFeeMomoNetwork,  String reportFeeMomoNumber,  String reportFeeMomoAccountName,  String reportFeePaidAt,  String reportFeeVerifiedAt,  String reportFeeVerifiedBy,  String approvalStatus,  String approvalRequestedAt,  String approvedAt,  String approvedByUid,  String approvedByName,  String approvalSealUrl,  bool approvalSealIncludesSignature,  String declinedAt,  String declineReason,  String declinedByUid,  String declinedByName,  List<String> reportPhotos,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectorId,_that.batchId,_that.farmerName,_that.location,_that.capturedLocation,_that.town,_that.chapter,_that.exactLocation,_that.truckNumber,_that.company,_that.buyerName,_that.waybillNumber,_that.analysisType,_that.quantity,_that.quantityBags,_that.cutTests,_that.moistureContent,_that.nutCount,_that.kor,_that.goodKernels,_that.spottedKernels,_that.immatureKernels,_that.oilyKernels,_that.voidKernels,_that.fullyDamagedKernels,_that.emptyShells,_that.totalDefective,_that.totalSpotted,_that.imageUrls,_that.status,_that.notes,_that.qcCode,_that.blNumber,_that.shipperDetails,_that.consigneeDetails,_that.originCountry,_that.destinationCountry,_that.transportDescription,_that.pod,_that.pol,_that.containerCountAndSizes,_that.grossWeight,_that.netWeight,_that.packageDescription,_that.samplePlaceAndDate,_that.cuttingTestPlaceAndDate,_that.isAuthorized,_that.authorizedSignature,_that.authorizedBy,_that.cuttingImageUrls,_that.inspectorName,_that.inspectorEmail,_that.reportFeeAmount,_that.reportFeeCurrency,_that.reportFeeStatus,_that.reportFeeEvidenceUrl,_that.reportFeeReference,_that.reportFeeMomoNetwork,_that.reportFeeMomoNumber,_that.reportFeeMomoAccountName,_that.reportFeePaidAt,_that.reportFeeVerifiedAt,_that.reportFeeVerifiedBy,_that.approvalStatus,_that.approvalRequestedAt,_that.approvedAt,_that.approvedByUid,_that.approvedByName,_that.approvalSealUrl,_that.approvalSealIncludesSignature,_that.declinedAt,_that.declineReason,_that.declinedByUid,_that.declinedByName,_that.reportPhotos,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? inspectionId,  String inspectorId,  String? batchId,  String? farmerName,  String? location,  CapturedLocation? capturedLocation,  String? town,  String? chapter,  String? exactLocation,  String? truckNumber,  String? company,  String? buyerName,  String? waybillNumber,  String? analysisType,  double quantity,  int quantityBags,  List<CutTest> cutTests,  double moistureContent,  int nutCount,  double kor,  double goodKernels,  double spottedKernels,  double immatureKernels,  double oilyKernels,  double voidKernels,  double fullyDamagedKernels,  double emptyShells,  double totalDefective,  double totalSpotted,  List<String> imageUrls, @JsonKey(unknownEnumValue: InspectionStatus.pending)  InspectionStatus status,  String? notes,  String? qcCode,  String? blNumber,  String? shipperDetails,  String? consigneeDetails,  String originCountry,  String? destinationCountry,  String? transportDescription,  String? pod,  String? pol,  String? containerCountAndSizes,  double? grossWeight,  double? netWeight,  String? packageDescription,  String? samplePlaceAndDate,  String? cuttingTestPlaceAndDate,  bool isAuthorized,  String? authorizedSignature,  String? authorizedBy,  List<String> cuttingImageUrls,  String? inspectorName,  String? inspectorEmail,  double reportFeeAmount,  String reportFeeCurrency,  String reportFeeStatus,  String reportFeeEvidenceUrl,  String reportFeeReference,  String reportFeeMomoNetwork,  String reportFeeMomoNumber,  String reportFeeMomoAccountName,  String reportFeePaidAt,  String reportFeeVerifiedAt,  String reportFeeVerifiedBy,  String approvalStatus,  String approvalRequestedAt,  String approvedAt,  String approvedByUid,  String approvedByName,  String approvalSealUrl,  bool approvalSealIncludesSignature,  String declinedAt,  String declineReason,  String declinedByUid,  String declinedByName,  List<String> reportPhotos,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Inspection():
return $default(_that.id,_that.inspectionId,_that.inspectorId,_that.batchId,_that.farmerName,_that.location,_that.capturedLocation,_that.town,_that.chapter,_that.exactLocation,_that.truckNumber,_that.company,_that.buyerName,_that.waybillNumber,_that.analysisType,_that.quantity,_that.quantityBags,_that.cutTests,_that.moistureContent,_that.nutCount,_that.kor,_that.goodKernels,_that.spottedKernels,_that.immatureKernels,_that.oilyKernels,_that.voidKernels,_that.fullyDamagedKernels,_that.emptyShells,_that.totalDefective,_that.totalSpotted,_that.imageUrls,_that.status,_that.notes,_that.qcCode,_that.blNumber,_that.shipperDetails,_that.consigneeDetails,_that.originCountry,_that.destinationCountry,_that.transportDescription,_that.pod,_that.pol,_that.containerCountAndSizes,_that.grossWeight,_that.netWeight,_that.packageDescription,_that.samplePlaceAndDate,_that.cuttingTestPlaceAndDate,_that.isAuthorized,_that.authorizedSignature,_that.authorizedBy,_that.cuttingImageUrls,_that.inspectorName,_that.inspectorEmail,_that.reportFeeAmount,_that.reportFeeCurrency,_that.reportFeeStatus,_that.reportFeeEvidenceUrl,_that.reportFeeReference,_that.reportFeeMomoNetwork,_that.reportFeeMomoNumber,_that.reportFeeMomoAccountName,_that.reportFeePaidAt,_that.reportFeeVerifiedAt,_that.reportFeeVerifiedBy,_that.approvalStatus,_that.approvalRequestedAt,_that.approvedAt,_that.approvedByUid,_that.approvedByName,_that.approvalSealUrl,_that.approvalSealIncludesSignature,_that.declinedAt,_that.declineReason,_that.declinedByUid,_that.declinedByName,_that.reportPhotos,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? inspectionId,  String inspectorId,  String? batchId,  String? farmerName,  String? location,  CapturedLocation? capturedLocation,  String? town,  String? chapter,  String? exactLocation,  String? truckNumber,  String? company,  String? buyerName,  String? waybillNumber,  String? analysisType,  double quantity,  int quantityBags,  List<CutTest> cutTests,  double moistureContent,  int nutCount,  double kor,  double goodKernels,  double spottedKernels,  double immatureKernels,  double oilyKernels,  double voidKernels,  double fullyDamagedKernels,  double emptyShells,  double totalDefective,  double totalSpotted,  List<String> imageUrls, @JsonKey(unknownEnumValue: InspectionStatus.pending)  InspectionStatus status,  String? notes,  String? qcCode,  String? blNumber,  String? shipperDetails,  String? consigneeDetails,  String originCountry,  String? destinationCountry,  String? transportDescription,  String? pod,  String? pol,  String? containerCountAndSizes,  double? grossWeight,  double? netWeight,  String? packageDescription,  String? samplePlaceAndDate,  String? cuttingTestPlaceAndDate,  bool isAuthorized,  String? authorizedSignature,  String? authorizedBy,  List<String> cuttingImageUrls,  String? inspectorName,  String? inspectorEmail,  double reportFeeAmount,  String reportFeeCurrency,  String reportFeeStatus,  String reportFeeEvidenceUrl,  String reportFeeReference,  String reportFeeMomoNetwork,  String reportFeeMomoNumber,  String reportFeeMomoAccountName,  String reportFeePaidAt,  String reportFeeVerifiedAt,  String reportFeeVerifiedBy,  String approvalStatus,  String approvalRequestedAt,  String approvedAt,  String approvedByUid,  String approvedByName,  String approvalSealUrl,  bool approvalSealIncludesSignature,  String declinedAt,  String declineReason,  String declinedByUid,  String declinedByName,  List<String> reportPhotos,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectorId,_that.batchId,_that.farmerName,_that.location,_that.capturedLocation,_that.town,_that.chapter,_that.exactLocation,_that.truckNumber,_that.company,_that.buyerName,_that.waybillNumber,_that.analysisType,_that.quantity,_that.quantityBags,_that.cutTests,_that.moistureContent,_that.nutCount,_that.kor,_that.goodKernels,_that.spottedKernels,_that.immatureKernels,_that.oilyKernels,_that.voidKernels,_that.fullyDamagedKernels,_that.emptyShells,_that.totalDefective,_that.totalSpotted,_that.imageUrls,_that.status,_that.notes,_that.qcCode,_that.blNumber,_that.shipperDetails,_that.consigneeDetails,_that.originCountry,_that.destinationCountry,_that.transportDescription,_that.pod,_that.pol,_that.containerCountAndSizes,_that.grossWeight,_that.netWeight,_that.packageDescription,_that.samplePlaceAndDate,_that.cuttingTestPlaceAndDate,_that.isAuthorized,_that.authorizedSignature,_that.authorizedBy,_that.cuttingImageUrls,_that.inspectorName,_that.inspectorEmail,_that.reportFeeAmount,_that.reportFeeCurrency,_that.reportFeeStatus,_that.reportFeeEvidenceUrl,_that.reportFeeReference,_that.reportFeeMomoNetwork,_that.reportFeeMomoNumber,_that.reportFeeMomoAccountName,_that.reportFeePaidAt,_that.reportFeeVerifiedAt,_that.reportFeeVerifiedBy,_that.approvalStatus,_that.approvalRequestedAt,_that.approvedAt,_that.approvedByUid,_that.approvedByName,_that.approvalSealUrl,_that.approvalSealIncludesSignature,_that.declinedAt,_that.declineReason,_that.declinedByUid,_that.declinedByName,_that.reportPhotos,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Inspection extends Inspection {
  const _Inspection({required this.id, this.inspectionId, required this.inspectorId, this.batchId, this.farmerName, this.location, this.capturedLocation, this.town, this.chapter, this.exactLocation, this.truckNumber, this.company, this.buyerName, this.waybillNumber, this.analysisType, this.quantity = 0.0, this.quantityBags = 0, final  List<CutTest> cutTests = const <CutTest>[], this.moistureContent = 0.0, this.nutCount = 0, this.kor = 0.0, this.goodKernels = 0.0, this.spottedKernels = 0.0, this.immatureKernels = 0.0, this.oilyKernels = 0.0, this.voidKernels = 0.0, this.fullyDamagedKernels = 0.0, this.emptyShells = 0.0, this.totalDefective = 0.0, this.totalSpotted = 0.0, final  List<String> imageUrls = const [], @JsonKey(unknownEnumValue: InspectionStatus.pending) this.status = InspectionStatus.pending, this.notes, this.qcCode, this.blNumber, this.shipperDetails, this.consigneeDetails, this.originCountry = 'GHANA', this.destinationCountry, this.transportDescription, this.pod, this.pol, this.containerCountAndSizes, this.grossWeight, this.netWeight, this.packageDescription, this.samplePlaceAndDate, this.cuttingTestPlaceAndDate, this.isAuthorized = false, this.authorizedSignature, this.authorizedBy, final  List<String> cuttingImageUrls = const [], this.inspectorName, this.inspectorEmail, this.reportFeeAmount = 0.0, this.reportFeeCurrency = 'GHS', this.reportFeeStatus = 'not_required', this.reportFeeEvidenceUrl = '', this.reportFeeReference = '', this.reportFeeMomoNetwork = '', this.reportFeeMomoNumber = '', this.reportFeeMomoAccountName = '', this.reportFeePaidAt = '', this.reportFeeVerifiedAt = '', this.reportFeeVerifiedBy = '', this.approvalStatus = 'not_required', this.approvalRequestedAt = '', this.approvedAt = '', this.approvedByUid = '', this.approvedByName = '', this.approvalSealUrl = '', this.approvalSealIncludesSignature = false, this.declinedAt = '', this.declineReason = '', this.declinedByUid = '', this.declinedByName = '', final  List<String> reportPhotos = const [], this.createdAt, this.updatedAt, this.completedAt}): _cutTests = cutTests,_imageUrls = imageUrls,_cuttingImageUrls = cuttingImageUrls,_reportPhotos = reportPhotos,super._();
  factory _Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);

@override final  String id;
// Firebase auto-generated document ID
@override final  String? inspectionId;
// Custom inspection ID (e.g., INS-20260114-4X9P)
@override final  String inspectorId;
// Batch and Farmer Info
@override final  String? batchId;
@override final  String? farmerName;
// Acts as Supplier/Farmer Name
@override final  String? location;
// Text-based location (e.g., "Wenchi District, Bono Region")
@override final  CapturedLocation? capturedLocation;
// GPS-captured location with coordinates
@override final  String? town;
@override final  String? chapter;
@override final  String? exactLocation;
// Basic Info
@override final  String? truckNumber;
@override final  String? company;
@override final  String? buyerName;
@override final  String? waybillNumber;
@override final  String? analysisType;
@override@JsonKey() final  double quantity;
@override@JsonKey() final  int quantityBags;
/// The individual cut tests behind this inspection, in order.
///
/// The report shows each one in its own column and the mean in AVERAGE.
/// The flat quality fields below hold that mean, so existing records and
/// the website continue to read the same values as before.
 final  List<CutTest> _cutTests;
/// The individual cut tests behind this inspection, in order.
///
/// The report shows each one in its own column and the mean in AVERAGE.
/// The flat quality fields below hold that mean, so existing records and
/// the website continue to read the same values as before.
@override@JsonKey() List<CutTest> get cutTests {
  if (_cutTests is EqualUnmodifiableListView) return _cutTests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cutTests);
}

// Quality Metrics (averages across [cutTests])
@override@JsonKey() final  double moistureContent;
@override@JsonKey() final  int nutCount;
// Raw Nut Count
@override@JsonKey() final  double kor;
// Defect Metrics
@override@JsonKey() final  double goodKernels;
@override@JsonKey() final  double spottedKernels;
@override@JsonKey() final  double immatureKernels;
@override@JsonKey() final  double oilyKernels;
@override@JsonKey() final  double voidKernels;
@override@JsonKey() final  double fullyDamagedKernels;
@override@JsonKey() final  double emptyShells;
@override@JsonKey() final  double totalDefective;
@override@JsonKey() final  double totalSpotted;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey(unknownEnumValue: InspectionStatus.pending) final  InspectionStatus status;
@override final  String? notes;
// Persistent QC-Code for this inspection
@override final  String? qcCode;
// Export Specific RCN Quality Report Fields
@override final  String? blNumber;
@override final  String? shipperDetails;
@override final  String? consigneeDetails;
@override@JsonKey() final  String originCountry;
@override final  String? destinationCountry;
@override final  String? transportDescription;
@override final  String? pod;
// Port of Destination
@override final  String? pol;
// Port of Loading
@override final  String? containerCountAndSizes;
@override final  double? grossWeight;
@override final  double? netWeight;
@override final  String? packageDescription;
@override final  String? samplePlaceAndDate;
@override final  String? cuttingTestPlaceAndDate;
@override@JsonKey() final  bool isAuthorized;
@override final  String? authorizedSignature;
@override final  String? authorizedBy;
 final  List<String> _cuttingImageUrls;
@override@JsonKey() List<String> get cuttingImageUrls {
  if (_cuttingImageUrls is EqualUnmodifiableListView) return _cuttingImageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuttingImageUrls);
}

// Analyst identity, denormalised so the approval desk and the decision
// email do not have to look the analyst up.
@override final  String? inspectorName;
@override final  String? inspectorEmail;
// Certificate fee — paid before a Moisture Control, Dispatch, Export or
// Arbitration certificate can be submitted. Field names match the website.
@override@JsonKey() final  double reportFeeAmount;
@override@JsonKey() final  String reportFeeCurrency;
/// `not_required`, `pending_verification`, `verified` or `rejected`.
@override@JsonKey() final  String reportFeeStatus;
@override@JsonKey() final  String reportFeeEvidenceUrl;
@override@JsonKey() final  String reportFeeReference;
@override@JsonKey() final  String reportFeeMomoNetwork;
@override@JsonKey() final  String reportFeeMomoNumber;
@override@JsonKey() final  String reportFeeMomoAccountName;
@override@JsonKey() final  String reportFeePaidAt;
@override@JsonKey() final  String reportFeeVerifiedAt;
@override@JsonKey() final  String reportFeeVerifiedBy;
// CQAAG approval — Export certificates are not valid until approved.
//
// Dates are ISO strings, left empty until set: the shared Firestore rules
// reject an Export certificate created with anything but an empty
// `approved_at` and `approval_seal_url`.
@override@JsonKey() final  String approvalStatus;
@override@JsonKey() final  String approvalRequestedAt;
@override@JsonKey() final  String approvedAt;
@override@JsonKey() final  String approvedByUid;
@override@JsonKey() final  String approvedByName;
/// Image of the association seal, with the president's signature embedded
/// when an admin has uploaded the signed seal, copied on at approval time.
@override@JsonKey() final  String approvalSealUrl;
@override@JsonKey() final  bool approvalSealIncludesSignature;
@override@JsonKey() final  String declinedAt;
@override@JsonKey() final  String declineReason;
@override@JsonKey() final  String declinedByUid;
@override@JsonKey() final  String declinedByName;
/// Export cutting pictures uploaded from the website.
 final  List<String> _reportPhotos;
/// Export cutting pictures uploaded from the website.
@override@JsonKey() List<String> get reportPhotos {
  if (_reportPhotos is EqualUnmodifiableListView) return _reportPhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reportPhotos);
}

// Timestamps
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? completedAt;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionCopyWith<_Inspection> get copyWith => __$InspectionCopyWithImpl<_Inspection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.farmerName, farmerName) || other.farmerName == farmerName)&&(identical(other.location, location) || other.location == location)&&(identical(other.capturedLocation, capturedLocation) || other.capturedLocation == capturedLocation)&&(identical(other.town, town) || other.town == town)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.exactLocation, exactLocation) || other.exactLocation == exactLocation)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.company, company) || other.company == company)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.waybillNumber, waybillNumber) || other.waybillNumber == waybillNumber)&&(identical(other.analysisType, analysisType) || other.analysisType == analysisType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityBags, quantityBags) || other.quantityBags == quantityBags)&&const DeepCollectionEquality().equals(other._cutTests, _cutTests)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.kor, kor) || other.kor == kor)&&(identical(other.goodKernels, goodKernels) || other.goodKernels == goodKernels)&&(identical(other.spottedKernels, spottedKernels) || other.spottedKernels == spottedKernels)&&(identical(other.immatureKernels, immatureKernels) || other.immatureKernels == immatureKernels)&&(identical(other.oilyKernels, oilyKernels) || other.oilyKernels == oilyKernels)&&(identical(other.voidKernels, voidKernels) || other.voidKernels == voidKernels)&&(identical(other.fullyDamagedKernels, fullyDamagedKernels) || other.fullyDamagedKernels == fullyDamagedKernels)&&(identical(other.emptyShells, emptyShells) || other.emptyShells == emptyShells)&&(identical(other.totalDefective, totalDefective) || other.totalDefective == totalDefective)&&(identical(other.totalSpotted, totalSpotted) || other.totalSpotted == totalSpotted)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.qcCode, qcCode) || other.qcCode == qcCode)&&(identical(other.blNumber, blNumber) || other.blNumber == blNumber)&&(identical(other.shipperDetails, shipperDetails) || other.shipperDetails == shipperDetails)&&(identical(other.consigneeDetails, consigneeDetails) || other.consigneeDetails == consigneeDetails)&&(identical(other.originCountry, originCountry) || other.originCountry == originCountry)&&(identical(other.destinationCountry, destinationCountry) || other.destinationCountry == destinationCountry)&&(identical(other.transportDescription, transportDescription) || other.transportDescription == transportDescription)&&(identical(other.pod, pod) || other.pod == pod)&&(identical(other.pol, pol) || other.pol == pol)&&(identical(other.containerCountAndSizes, containerCountAndSizes) || other.containerCountAndSizes == containerCountAndSizes)&&(identical(other.grossWeight, grossWeight) || other.grossWeight == grossWeight)&&(identical(other.netWeight, netWeight) || other.netWeight == netWeight)&&(identical(other.packageDescription, packageDescription) || other.packageDescription == packageDescription)&&(identical(other.samplePlaceAndDate, samplePlaceAndDate) || other.samplePlaceAndDate == samplePlaceAndDate)&&(identical(other.cuttingTestPlaceAndDate, cuttingTestPlaceAndDate) || other.cuttingTestPlaceAndDate == cuttingTestPlaceAndDate)&&(identical(other.isAuthorized, isAuthorized) || other.isAuthorized == isAuthorized)&&(identical(other.authorizedSignature, authorizedSignature) || other.authorizedSignature == authorizedSignature)&&(identical(other.authorizedBy, authorizedBy) || other.authorizedBy == authorizedBy)&&const DeepCollectionEquality().equals(other._cuttingImageUrls, _cuttingImageUrls)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.inspectorEmail, inspectorEmail) || other.inspectorEmail == inspectorEmail)&&(identical(other.reportFeeAmount, reportFeeAmount) || other.reportFeeAmount == reportFeeAmount)&&(identical(other.reportFeeCurrency, reportFeeCurrency) || other.reportFeeCurrency == reportFeeCurrency)&&(identical(other.reportFeeStatus, reportFeeStatus) || other.reportFeeStatus == reportFeeStatus)&&(identical(other.reportFeeEvidenceUrl, reportFeeEvidenceUrl) || other.reportFeeEvidenceUrl == reportFeeEvidenceUrl)&&(identical(other.reportFeeReference, reportFeeReference) || other.reportFeeReference == reportFeeReference)&&(identical(other.reportFeeMomoNetwork, reportFeeMomoNetwork) || other.reportFeeMomoNetwork == reportFeeMomoNetwork)&&(identical(other.reportFeeMomoNumber, reportFeeMomoNumber) || other.reportFeeMomoNumber == reportFeeMomoNumber)&&(identical(other.reportFeeMomoAccountName, reportFeeMomoAccountName) || other.reportFeeMomoAccountName == reportFeeMomoAccountName)&&(identical(other.reportFeePaidAt, reportFeePaidAt) || other.reportFeePaidAt == reportFeePaidAt)&&(identical(other.reportFeeVerifiedAt, reportFeeVerifiedAt) || other.reportFeeVerifiedAt == reportFeeVerifiedAt)&&(identical(other.reportFeeVerifiedBy, reportFeeVerifiedBy) || other.reportFeeVerifiedBy == reportFeeVerifiedBy)&&(identical(other.approvalStatus, approvalStatus) || other.approvalStatus == approvalStatus)&&(identical(other.approvalRequestedAt, approvalRequestedAt) || other.approvalRequestedAt == approvalRequestedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedByUid, approvedByUid) || other.approvedByUid == approvedByUid)&&(identical(other.approvedByName, approvedByName) || other.approvedByName == approvedByName)&&(identical(other.approvalSealUrl, approvalSealUrl) || other.approvalSealUrl == approvalSealUrl)&&(identical(other.approvalSealIncludesSignature, approvalSealIncludesSignature) || other.approvalSealIncludesSignature == approvalSealIncludesSignature)&&(identical(other.declinedAt, declinedAt) || other.declinedAt == declinedAt)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.declinedByUid, declinedByUid) || other.declinedByUid == declinedByUid)&&(identical(other.declinedByName, declinedByName) || other.declinedByName == declinedByName)&&const DeepCollectionEquality().equals(other._reportPhotos, _reportPhotos)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,inspectionId,inspectorId,batchId,farmerName,location,capturedLocation,town,chapter,exactLocation,truckNumber,company,buyerName,waybillNumber,analysisType,quantity,quantityBags,const DeepCollectionEquality().hash(_cutTests),moistureContent,nutCount,kor,goodKernels,spottedKernels,immatureKernels,oilyKernels,voidKernels,fullyDamagedKernels,emptyShells,totalDefective,totalSpotted,const DeepCollectionEquality().hash(_imageUrls),status,notes,qcCode,blNumber,shipperDetails,consigneeDetails,originCountry,destinationCountry,transportDescription,pod,pol,containerCountAndSizes,grossWeight,netWeight,packageDescription,samplePlaceAndDate,cuttingTestPlaceAndDate,isAuthorized,authorizedSignature,authorizedBy,const DeepCollectionEquality().hash(_cuttingImageUrls),inspectorName,inspectorEmail,reportFeeAmount,reportFeeCurrency,reportFeeStatus,reportFeeEvidenceUrl,reportFeeReference,reportFeeMomoNetwork,reportFeeMomoNumber,reportFeeMomoAccountName,reportFeePaidAt,reportFeeVerifiedAt,reportFeeVerifiedBy,approvalStatus,approvalRequestedAt,approvedAt,approvedByUid,approvedByName,approvalSealUrl,approvalSealIncludesSignature,declinedAt,declineReason,declinedByUid,declinedByName,const DeepCollectionEquality().hash(_reportPhotos),createdAt,updatedAt,completedAt]);

@override
String toString() {
  return 'Inspection(id: $id, inspectionId: $inspectionId, inspectorId: $inspectorId, batchId: $batchId, farmerName: $farmerName, location: $location, capturedLocation: $capturedLocation, town: $town, chapter: $chapter, exactLocation: $exactLocation, truckNumber: $truckNumber, company: $company, buyerName: $buyerName, waybillNumber: $waybillNumber, analysisType: $analysisType, quantity: $quantity, quantityBags: $quantityBags, cutTests: $cutTests, moistureContent: $moistureContent, nutCount: $nutCount, kor: $kor, goodKernels: $goodKernels, spottedKernels: $spottedKernels, immatureKernels: $immatureKernels, oilyKernels: $oilyKernels, voidKernels: $voidKernels, fullyDamagedKernels: $fullyDamagedKernels, emptyShells: $emptyShells, totalDefective: $totalDefective, totalSpotted: $totalSpotted, imageUrls: $imageUrls, status: $status, notes: $notes, qcCode: $qcCode, blNumber: $blNumber, shipperDetails: $shipperDetails, consigneeDetails: $consigneeDetails, originCountry: $originCountry, destinationCountry: $destinationCountry, transportDescription: $transportDescription, pod: $pod, pol: $pol, containerCountAndSizes: $containerCountAndSizes, grossWeight: $grossWeight, netWeight: $netWeight, packageDescription: $packageDescription, samplePlaceAndDate: $samplePlaceAndDate, cuttingTestPlaceAndDate: $cuttingTestPlaceAndDate, isAuthorized: $isAuthorized, authorizedSignature: $authorizedSignature, authorizedBy: $authorizedBy, cuttingImageUrls: $cuttingImageUrls, inspectorName: $inspectorName, inspectorEmail: $inspectorEmail, reportFeeAmount: $reportFeeAmount, reportFeeCurrency: $reportFeeCurrency, reportFeeStatus: $reportFeeStatus, reportFeeEvidenceUrl: $reportFeeEvidenceUrl, reportFeeReference: $reportFeeReference, reportFeeMomoNetwork: $reportFeeMomoNetwork, reportFeeMomoNumber: $reportFeeMomoNumber, reportFeeMomoAccountName: $reportFeeMomoAccountName, reportFeePaidAt: $reportFeePaidAt, reportFeeVerifiedAt: $reportFeeVerifiedAt, reportFeeVerifiedBy: $reportFeeVerifiedBy, approvalStatus: $approvalStatus, approvalRequestedAt: $approvalRequestedAt, approvedAt: $approvedAt, approvedByUid: $approvedByUid, approvedByName: $approvedByName, approvalSealUrl: $approvalSealUrl, approvalSealIncludesSignature: $approvalSealIncludesSignature, declinedAt: $declinedAt, declineReason: $declineReason, declinedByUid: $declinedByUid, declinedByName: $declinedByName, reportPhotos: $reportPhotos, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$InspectionCopyWith<$Res> implements $InspectionCopyWith<$Res> {
  factory _$InspectionCopyWith(_Inspection value, $Res Function(_Inspection) _then) = __$InspectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? inspectionId, String inspectorId, String? batchId, String? farmerName, String? location, CapturedLocation? capturedLocation, String? town, String? chapter, String? exactLocation, String? truckNumber, String? company, String? buyerName, String? waybillNumber, String? analysisType, double quantity, int quantityBags, List<CutTest> cutTests, double moistureContent, int nutCount, double kor, double goodKernels, double spottedKernels, double immatureKernels, double oilyKernels, double voidKernels, double fullyDamagedKernels, double emptyShells, double totalDefective, double totalSpotted, List<String> imageUrls,@JsonKey(unknownEnumValue: InspectionStatus.pending) InspectionStatus status, String? notes, String? qcCode, String? blNumber, String? shipperDetails, String? consigneeDetails, String originCountry, String? destinationCountry, String? transportDescription, String? pod, String? pol, String? containerCountAndSizes, double? grossWeight, double? netWeight, String? packageDescription, String? samplePlaceAndDate, String? cuttingTestPlaceAndDate, bool isAuthorized, String? authorizedSignature, String? authorizedBy, List<String> cuttingImageUrls, String? inspectorName, String? inspectorEmail, double reportFeeAmount, String reportFeeCurrency, String reportFeeStatus, String reportFeeEvidenceUrl, String reportFeeReference, String reportFeeMomoNetwork, String reportFeeMomoNumber, String reportFeeMomoAccountName, String reportFeePaidAt, String reportFeeVerifiedAt, String reportFeeVerifiedBy, String approvalStatus, String approvalRequestedAt, String approvedAt, String approvedByUid, String approvedByName, String approvalSealUrl, bool approvalSealIncludesSignature, String declinedAt, String declineReason, String declinedByUid, String declinedByName, List<String> reportPhotos, DateTime? createdAt, DateTime? updatedAt, DateTime? completedAt
});


@override $CapturedLocationCopyWith<$Res>? get capturedLocation;

}
/// @nodoc
class __$InspectionCopyWithImpl<$Res>
    implements _$InspectionCopyWith<$Res> {
  __$InspectionCopyWithImpl(this._self, this._then);

  final _Inspection _self;
  final $Res Function(_Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectionId = freezed,Object? inspectorId = null,Object? batchId = freezed,Object? farmerName = freezed,Object? location = freezed,Object? capturedLocation = freezed,Object? town = freezed,Object? chapter = freezed,Object? exactLocation = freezed,Object? truckNumber = freezed,Object? company = freezed,Object? buyerName = freezed,Object? waybillNumber = freezed,Object? analysisType = freezed,Object? quantity = null,Object? quantityBags = null,Object? cutTests = null,Object? moistureContent = null,Object? nutCount = null,Object? kor = null,Object? goodKernels = null,Object? spottedKernels = null,Object? immatureKernels = null,Object? oilyKernels = null,Object? voidKernels = null,Object? fullyDamagedKernels = null,Object? emptyShells = null,Object? totalDefective = null,Object? totalSpotted = null,Object? imageUrls = null,Object? status = null,Object? notes = freezed,Object? qcCode = freezed,Object? blNumber = freezed,Object? shipperDetails = freezed,Object? consigneeDetails = freezed,Object? originCountry = null,Object? destinationCountry = freezed,Object? transportDescription = freezed,Object? pod = freezed,Object? pol = freezed,Object? containerCountAndSizes = freezed,Object? grossWeight = freezed,Object? netWeight = freezed,Object? packageDescription = freezed,Object? samplePlaceAndDate = freezed,Object? cuttingTestPlaceAndDate = freezed,Object? isAuthorized = null,Object? authorizedSignature = freezed,Object? authorizedBy = freezed,Object? cuttingImageUrls = null,Object? inspectorName = freezed,Object? inspectorEmail = freezed,Object? reportFeeAmount = null,Object? reportFeeCurrency = null,Object? reportFeeStatus = null,Object? reportFeeEvidenceUrl = null,Object? reportFeeReference = null,Object? reportFeeMomoNetwork = null,Object? reportFeeMomoNumber = null,Object? reportFeeMomoAccountName = null,Object? reportFeePaidAt = null,Object? reportFeeVerifiedAt = null,Object? reportFeeVerifiedBy = null,Object? approvalStatus = null,Object? approvalRequestedAt = null,Object? approvedAt = null,Object? approvedByUid = null,Object? approvedByName = null,Object? approvalSealUrl = null,Object? approvalSealIncludesSignature = null,Object? declinedAt = null,Object? declineReason = null,Object? declinedByUid = null,Object? declinedByName = null,Object? reportPhotos = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_Inspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: freezed == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String?,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String?,farmerName: freezed == farmerName ? _self.farmerName : farmerName // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,capturedLocation: freezed == capturedLocation ? _self.capturedLocation : capturedLocation // ignore: cast_nullable_to_non_nullable
as CapturedLocation?,town: freezed == town ? _self.town : town // ignore: cast_nullable_to_non_nullable
as String?,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as String?,exactLocation: freezed == exactLocation ? _self.exactLocation : exactLocation // ignore: cast_nullable_to_non_nullable
as String?,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,buyerName: freezed == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String?,waybillNumber: freezed == waybillNumber ? _self.waybillNumber : waybillNumber // ignore: cast_nullable_to_non_nullable
as String?,analysisType: freezed == analysisType ? _self.analysisType : analysisType // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,quantityBags: null == quantityBags ? _self.quantityBags : quantityBags // ignore: cast_nullable_to_non_nullable
as int,cutTests: null == cutTests ? _self._cutTests : cutTests // ignore: cast_nullable_to_non_nullable
as List<CutTest>,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,kor: null == kor ? _self.kor : kor // ignore: cast_nullable_to_non_nullable
as double,goodKernels: null == goodKernels ? _self.goodKernels : goodKernels // ignore: cast_nullable_to_non_nullable
as double,spottedKernels: null == spottedKernels ? _self.spottedKernels : spottedKernels // ignore: cast_nullable_to_non_nullable
as double,immatureKernels: null == immatureKernels ? _self.immatureKernels : immatureKernels // ignore: cast_nullable_to_non_nullable
as double,oilyKernels: null == oilyKernels ? _self.oilyKernels : oilyKernels // ignore: cast_nullable_to_non_nullable
as double,voidKernels: null == voidKernels ? _self.voidKernels : voidKernels // ignore: cast_nullable_to_non_nullable
as double,fullyDamagedKernels: null == fullyDamagedKernels ? _self.fullyDamagedKernels : fullyDamagedKernels // ignore: cast_nullable_to_non_nullable
as double,emptyShells: null == emptyShells ? _self.emptyShells : emptyShells // ignore: cast_nullable_to_non_nullable
as double,totalDefective: null == totalDefective ? _self.totalDefective : totalDefective // ignore: cast_nullable_to_non_nullable
as double,totalSpotted: null == totalSpotted ? _self.totalSpotted : totalSpotted // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,qcCode: freezed == qcCode ? _self.qcCode : qcCode // ignore: cast_nullable_to_non_nullable
as String?,blNumber: freezed == blNumber ? _self.blNumber : blNumber // ignore: cast_nullable_to_non_nullable
as String?,shipperDetails: freezed == shipperDetails ? _self.shipperDetails : shipperDetails // ignore: cast_nullable_to_non_nullable
as String?,consigneeDetails: freezed == consigneeDetails ? _self.consigneeDetails : consigneeDetails // ignore: cast_nullable_to_non_nullable
as String?,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as String,destinationCountry: freezed == destinationCountry ? _self.destinationCountry : destinationCountry // ignore: cast_nullable_to_non_nullable
as String?,transportDescription: freezed == transportDescription ? _self.transportDescription : transportDescription // ignore: cast_nullable_to_non_nullable
as String?,pod: freezed == pod ? _self.pod : pod // ignore: cast_nullable_to_non_nullable
as String?,pol: freezed == pol ? _self.pol : pol // ignore: cast_nullable_to_non_nullable
as String?,containerCountAndSizes: freezed == containerCountAndSizes ? _self.containerCountAndSizes : containerCountAndSizes // ignore: cast_nullable_to_non_nullable
as String?,grossWeight: freezed == grossWeight ? _self.grossWeight : grossWeight // ignore: cast_nullable_to_non_nullable
as double?,netWeight: freezed == netWeight ? _self.netWeight : netWeight // ignore: cast_nullable_to_non_nullable
as double?,packageDescription: freezed == packageDescription ? _self.packageDescription : packageDescription // ignore: cast_nullable_to_non_nullable
as String?,samplePlaceAndDate: freezed == samplePlaceAndDate ? _self.samplePlaceAndDate : samplePlaceAndDate // ignore: cast_nullable_to_non_nullable
as String?,cuttingTestPlaceAndDate: freezed == cuttingTestPlaceAndDate ? _self.cuttingTestPlaceAndDate : cuttingTestPlaceAndDate // ignore: cast_nullable_to_non_nullable
as String?,isAuthorized: null == isAuthorized ? _self.isAuthorized : isAuthorized // ignore: cast_nullable_to_non_nullable
as bool,authorizedSignature: freezed == authorizedSignature ? _self.authorizedSignature : authorizedSignature // ignore: cast_nullable_to_non_nullable
as String?,authorizedBy: freezed == authorizedBy ? _self.authorizedBy : authorizedBy // ignore: cast_nullable_to_non_nullable
as String?,cuttingImageUrls: null == cuttingImageUrls ? _self._cuttingImageUrls : cuttingImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,inspectorName: freezed == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String?,inspectorEmail: freezed == inspectorEmail ? _self.inspectorEmail : inspectorEmail // ignore: cast_nullable_to_non_nullable
as String?,reportFeeAmount: null == reportFeeAmount ? _self.reportFeeAmount : reportFeeAmount // ignore: cast_nullable_to_non_nullable
as double,reportFeeCurrency: null == reportFeeCurrency ? _self.reportFeeCurrency : reportFeeCurrency // ignore: cast_nullable_to_non_nullable
as String,reportFeeStatus: null == reportFeeStatus ? _self.reportFeeStatus : reportFeeStatus // ignore: cast_nullable_to_non_nullable
as String,reportFeeEvidenceUrl: null == reportFeeEvidenceUrl ? _self.reportFeeEvidenceUrl : reportFeeEvidenceUrl // ignore: cast_nullable_to_non_nullable
as String,reportFeeReference: null == reportFeeReference ? _self.reportFeeReference : reportFeeReference // ignore: cast_nullable_to_non_nullable
as String,reportFeeMomoNetwork: null == reportFeeMomoNetwork ? _self.reportFeeMomoNetwork : reportFeeMomoNetwork // ignore: cast_nullable_to_non_nullable
as String,reportFeeMomoNumber: null == reportFeeMomoNumber ? _self.reportFeeMomoNumber : reportFeeMomoNumber // ignore: cast_nullable_to_non_nullable
as String,reportFeeMomoAccountName: null == reportFeeMomoAccountName ? _self.reportFeeMomoAccountName : reportFeeMomoAccountName // ignore: cast_nullable_to_non_nullable
as String,reportFeePaidAt: null == reportFeePaidAt ? _self.reportFeePaidAt : reportFeePaidAt // ignore: cast_nullable_to_non_nullable
as String,reportFeeVerifiedAt: null == reportFeeVerifiedAt ? _self.reportFeeVerifiedAt : reportFeeVerifiedAt // ignore: cast_nullable_to_non_nullable
as String,reportFeeVerifiedBy: null == reportFeeVerifiedBy ? _self.reportFeeVerifiedBy : reportFeeVerifiedBy // ignore: cast_nullable_to_non_nullable
as String,approvalStatus: null == approvalStatus ? _self.approvalStatus : approvalStatus // ignore: cast_nullable_to_non_nullable
as String,approvalRequestedAt: null == approvalRequestedAt ? _self.approvalRequestedAt : approvalRequestedAt // ignore: cast_nullable_to_non_nullable
as String,approvedAt: null == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as String,approvedByUid: null == approvedByUid ? _self.approvedByUid : approvedByUid // ignore: cast_nullable_to_non_nullable
as String,approvedByName: null == approvedByName ? _self.approvedByName : approvedByName // ignore: cast_nullable_to_non_nullable
as String,approvalSealUrl: null == approvalSealUrl ? _self.approvalSealUrl : approvalSealUrl // ignore: cast_nullable_to_non_nullable
as String,approvalSealIncludesSignature: null == approvalSealIncludesSignature ? _self.approvalSealIncludesSignature : approvalSealIncludesSignature // ignore: cast_nullable_to_non_nullable
as bool,declinedAt: null == declinedAt ? _self.declinedAt : declinedAt // ignore: cast_nullable_to_non_nullable
as String,declineReason: null == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String,declinedByUid: null == declinedByUid ? _self.declinedByUid : declinedByUid // ignore: cast_nullable_to_non_nullable
as String,declinedByName: null == declinedByName ? _self.declinedByName : declinedByName // ignore: cast_nullable_to_non_nullable
as String,reportPhotos: null == reportPhotos ? _self._reportPhotos : reportPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedLocationCopyWith<$Res>? get capturedLocation {
    if (_self.capturedLocation == null) {
    return null;
  }

  return $CapturedLocationCopyWith<$Res>(_self.capturedLocation!, (value) {
    return _then(_self.copyWith(capturedLocation: value));
  });
}
}

// dart format on
