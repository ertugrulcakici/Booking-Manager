import 'package:flutter/material.dart';

mixin LoadingNotifierMixin on ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    if (value != _isLoading) {
      _isLoading = value;
      if (_isLoading) {
        _isError = false;
        _errorMessage = "";
      }
      notifyListeners();
    }
  }

  // error
  bool _isError = false;
  bool get isError => _isError;

  set isError(bool value) {
    if (value != _isError) {
      _isError = value;
      notifyListeners();
    }
  }

  String _errorMessage = "";
  set errorMessage(String value) {
    _errorMessage = value;
    isError = true;
  }

  String get errorMessage => _errorMessage;
}
