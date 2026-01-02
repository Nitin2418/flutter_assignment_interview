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
      _inputValue = value;
      notifyListeners();
    }
  }


  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setTestMetadata(TestMetadata metadata) {
    _testMetadata = metadata;
    _errorMessage = null;
    _isLoading = false;
    if (_inputValue == 0.0 && metadata.ranges.isNotEmpty) {
      _inputValue = metadata.minimumValue;
    }
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Range? getCurrentRange() {
    if (_testMetadata == null) return null;
    return _testMetadata!.getRangeForValue(_inputValue);
  }
}

