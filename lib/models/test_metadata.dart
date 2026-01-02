import 'range.dart';

class TestMetadata {
  final List<Range> ranges;
  final String? testName;
  final double? maxValue;

  TestMetadata({
    required this.ranges,
    this.testName,
    this.maxValue,
  });

  double get maximumValue {
    if (maxValue != null) return maxValue!;
    if (ranges.isEmpty) return 100.0;
    return ranges.map((r) => r.max).reduce((a, b) => a > b ? a : b);
  }

  double get minimumValue {
    if (ranges.isEmpty) return 0.0;
    return ranges.map((r) => r.min).reduce((a, b) => a < b ? a : b);
  }

  Range? getRangeForValue(double value) {
    for (var range in ranges) {
      if (range.contains(value)) {
        return range;
      }
    }
    return null;
  }

  factory TestMetadata.fromJson(dynamic json) {
    List<Range> rangesList = [];
    String? testName;
    double? maxValue;
    
    if (json is List) {
      rangesList = json
          .map((r) => Range.fromJson(r as Map<String, dynamic>))
          .toList();
    } else if (json is Map<String, dynamic>) {
      if (json['ranges'] != null) {
        rangesList = (json['ranges'] as List)
            .map((r) => Range.fromJson(r as Map<String, dynamic>))
            .toList();
      } else if (json['data'] != null && json['data'] is Map) {
        final data = json['data'] as Map<String, dynamic>;
        if (data['ranges'] != null) {
          rangesList = (data['ranges'] as List)
              .map((r) => Range.fromJson(r as Map<String, dynamic>))
              .toList();
        }
      }
      testName = json['testName'] ?? json['name'];
      maxValue = json['maxValue']?.toDouble();
    }

    return TestMetadata(
      ranges: rangesList,
      testName: testName,
      maxValue: maxValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ranges': ranges.map((r) => r.toJson()).toList(),
      'testName': testName,
      'maxValue': maxValue,
    };
  }
}

