import "package:flutter/foundation.dart";
import "../core/constants/app_constants.dart";

class TraceModeProvider with ChangeNotifier {
  double _opacity = AppConstants.defaultOpacity;
  double _zoom = AppConstants.defaultZoom;
  int _gridSize = 0;
  bool _showGrid = false;
  bool _isTraceModeActive = false;

  double get opacity => _opacity;
  double get zoom => _zoom;
  int get gridSize => _gridSize;
  bool get showGrid => _showGrid;
  bool get isTraceModeActive => _isTraceModeActive;

  void setOpacity(double value) {
    _opacity = value.clamp(AppConstants.minOpacity, AppConstants.maxOpacity);
    notifyListeners();
  }

  void setZoom(double value) {
    _zoom = value.clamp(AppConstants.minZoom, AppConstants.maxZoom);
    notifyListeners();
  }

  void setGridSize(int size) {
    _gridSize = size;
    _showGrid = size > 0;
    notifyListeners();
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  void setTraceModeActive(bool active) {
    _isTraceModeActive = active;
    notifyListeners();
  }

  void reset() {
    _opacity = AppConstants.defaultOpacity;
    _zoom = AppConstants.defaultZoom;
    _gridSize = 0;
    _showGrid = false;
    _isTraceModeActive = false;
    notifyListeners();
  }
}
