import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/utils/ghana_card.dart';

part 'verification_data.freezed.dart';
part 'verification_data.g.dart';

/// A member's KYC record.
///
/// Ghanaian law now limits what the Association may collect to the Ghana Card
/// *number*: no photograph of the card, and no selfie, is captured or stored.
/// [idCardNumber] is therefore the whole of the identity evidence an admin
/// verifies against.
///
/// The image URL fields remain on the model, nullable and never written, only
/// so records created under the previous flow still deserialize. Nothing in the
/// app reads or displays them.
@freezed
abstract class VerificationData with _$VerificationData {
  const VerificationData._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VerificationData({
    /// Ghana Card personal ID number, in the form `GHA-#########-#`.
    required String idCardNumber,

    /// UID of the admin who verified the number.
    String? verifiedBy,

    /// When the number was verified.
    DateTime? dateVerified,

    /// Legacy, from the superseded document-upload flow. Never written.
    String? idCardFrontUrl,

    /// Legacy, from the superseded document-upload flow. Never written.
    String? idCardBackUrl,

    /// Legacy, from the superseded document-upload flow. Never written.
    String? selfieUrl,
  }) = _VerificationData;

  factory VerificationData.fromJson(Map<String, dynamic> json) => _$VerificationDataFromJson(json);

  /// Whether the recorded number is structurally a valid Ghana Card number.
  bool get hasValidNumber => GhanaCard.isValid(idCardNumber);

  /// The number in canonical `GHA-#########-#` form, for display and matching.
  String get normalisedNumber => GhanaCard.normalise(idCardNumber) ?? idCardNumber.trim().toUpperCase();
}
