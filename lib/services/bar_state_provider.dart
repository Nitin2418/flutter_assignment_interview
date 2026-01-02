import 'package:flutter/foundation.dart';
import '../models/test_metadata.dart';
import '../models/range.dart';

class BarStateProvider extends ChangeNotifier {
  TestMetadata? _testMetadata;
  double _inputValue = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  TestMetadata? get testMetadata => _testMetadata;
  double get inputValue => _inputValue;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _testMetadata != null && _testMetadata!.ranges.isNotEmpty;

  void updateInputValue(double value) {
    if (_inputValue != value) {
      print('[STATE] Input value changed: $_inputValue -> $value');
      _inputValue = value;
      final currentRange = _testMetadata?.getRangeForValue(value);
      if (currentRange != null) {
        print('[STATE] Current range: ${currentRange.label} (${currentRange.min}-${currentRange.max})');
      } else {
        print('[STATE] Value $value is outside all ranges');
      }
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      print('[STATE] Loading state changed: $_isLoading -> $loading');
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setTestMetadata(TestMetadata metadata) {
    print('[STATE] ========================================');
    print('[STATE] Setting test metadata');
    print('[STATE] Ranges count: ${metadata.ranges.length}');
    print('[STATE] Min value: ${metadata.minimumValue}, Max value: ${metadata.maximumValue}');
    _testMetadata = metadata;
    _errorMessage = null;
    _isLoading = false;
    if (_inputValue == 0.0 && metadata.ranges.isNotEmpty) {
      _inputValue = metadata.minimumValue;
      print('[STATE] Initialized input value to minimum: $_inputValue');
    }
    print('[STATE] ========================================');
    notifyListeners();
  }

  void setError(String error) {
    print('[STATE] ❌ Error set: $error');
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    print('[STATE] Clearing error state');
    _errorMessage = null;
    notifyListeners();
  }

  Range? getCurrentRange() {
    if (_testMetadata == null) return null;
    return _testMetadata!.getRangeForValue(_inputValue);
  }
}

