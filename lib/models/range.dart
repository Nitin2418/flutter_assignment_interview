class Range {
  final double min;
  final double max;
  final String label;
  final String colorHex;

  Range({
    required this.min,
    required this.max,
    required this.label,
    required this.colorHex,
  });

  int get colorValue {
    String hex = colorHex.replaceAll('#', '');
    return int.parse(hex, radix: 16) + 0xFF000000;
  }

  bool contains(double value) {
    return value >= min && value <= max;
  }

  factory Range.fromJson(Map<String, dynamic> json) {
    double minValue = 0.0;
    double maxValue = 0.0;

    if (json['range'] != null) {
      if (json['range'] is String) {
        final rangeStr = json['range'] as String;
        final parts = rangeStr.split('-');
        if (parts.length == 2) {
          minValue = double.tryParse(parts[0].trim()) ?? 0.0;
          maxValue = double.tryParse(parts[1].trim()) ?? 0.0;
        }
      } else if (json['range'] is Map) {
        final range = json['range'] as Map;
        if (range['min'] != null) {
          minValue = (range['min'] is num) ? range['min'].toDouble() : double.tryParse(range['min'].toString()) ?? 0.0;
        }
        if (range['max'] != null) {
          maxValue = (range['max'] is num) ? range['max'].toDouble() : double.tryParse(range['max'].toString()) ?? 0.0;
        }
      }
    }

    if (minValue == 0.0 && maxValue == 0.0) {
      if (json['min'] != null) {
        minValue = (json['min'] is num) ? json['min'].toDouble() : double.tryParse(json['min'].toString()) ?? 0.0;
      }
      if (json['max'] != null) {
        maxValue = (json['max'] is num) ? json['max'].toDouble() : double.tryParse(json['max'].toString()) ?? 0.0;
      }
    }

    return Range(
      min: minValue,
      max: maxValue,
      label: json['label']?.toString() ?? json['meaning']?.toString() ?? '',
      colorHex: json['color']?.toString() ?? json['colorHex']?.toString() ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'label': label,
      'color': colorHex,
    };
  }
}

