import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/inspection/analysis_types.dart';

void main() {
  test('Quality Certificate terminology and types smoke test', () {
    expect(AnalysisTypes.paid, contains(AnalysisTypes.export));
    expect(AnalysisTypes.paid, contains(AnalysisTypes.moistureControl));
    expect(AnalysisTypes.paid, contains(AnalysisTypes.dispatch));
    expect(AnalysisTypes.paid, contains(AnalysisTypes.arbitration));
    expect(AnalysisTypes.reportFeeCedis, equals(100.0));
    expect(AnalysisTypes.requiresApproval(AnalysisTypes.export), isTrue);
    expect(AnalysisTypes.requiresPayment(AnalysisTypes.export), isTrue);
    expect(AnalysisTypes.requiresPayment(AnalysisTypes.arrivalUpcountry), isFalse);
  });
}
