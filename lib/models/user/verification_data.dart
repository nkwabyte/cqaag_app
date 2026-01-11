import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_data.freezed.dart';
part 'verification_data.g.dart';

@freezed
abstract class VerificationData with _$VerificationData {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VerificationData({
    required String idCardFrontUrl,
    required String idCardBackUrl,
    required String idCardNumber,
    required String selfieUrl,
    String? verifiedBy,
    DateTime? dateVerified,
  }) = _VerificationData;

  factory VerificationData.fromJson(Map<String, dynamic> json) => _$VerificationDataFromJson(json);
}
