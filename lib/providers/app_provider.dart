import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/sketch_item.dart';
import '../services/sketch_service.dart';
import '../features/history/local_storage/history_storage.dart';

class AppProvider with ChangeNotifier {
  final SketchService _sketchService = SketchService();
  final HistoryStorage _historyStorage = HistoryStorage();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  Uint8List? _sketchBytes;
  SketchType? _selectedSketchType;
  List<SketchItem> _history = [];
  SketchItem? _currentProject;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _lastSavedPath;
  String? _errorMessage;
  int _recentProjectsLimit = 5;

  File? get selectedImage => _selectedImage;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  Uint8List? get sketchBytes => _sketchBytes;
  SketchType? get selectedSketchType => _selectedSketchType;
  List<SketchItem> get history => _history;
  List<SketchItem> get recentProjects => _history.take(_recentProjectsLimit).toList();
  List<SketchItem> get favoriteProjects => _history.where((item) => item.isFavorite).toList();
  SketchItem? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  bool get hasImage => _selectedImage != null;
  bool get hasSketch => _sketchBytes != null;
  String? get lastSavedPath => _lastSavedPath;
  String? get errorMessage => _errorMessage;

  Future<void> pickImageFromCamera() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
      if (image != null) {
        _selectedImage = File(image.path);
        _selectedImageBytes = await image.readAsBytes();
        _sketchBytes = null;
        _selectedSketchType = null;
      }
    } catch (e) { _errorMessage = 'Error: ' + e.toString(); }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickImageFromGallery() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
      if (image != null) {
        _selectedImage = File(image.path);
        _selectedImageBytes = await image.readAsBytes();
        _sketchBytes = null;
        _selectedSketchType = null;
      }
    } catch (e) { _errorMessage = 'Error: ' + e.toString(); }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateSketch(SketchType type) async {
    if (_selectedImageBytes == null) { _errorMessage = 'No image selected'; notifyListeners(); return; }
    _isProcessing = true;
    _errorMessage = null;
    _selectedSketchType = type;
    notifyListeners();
    try {
      _sketchBytes = await _sketchService.generateSketch(_selectedImageBytes!, type);
      if (_sketchBytes == null) _errorMessage = 'Failed to generate sketch';
    } catch (e) { _errorMessage = 'Error: ' + e.toString(); }
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> saveSketch({String? projectName}) async {
    if (_sketchBytes == null || _selectedSketchType == null) { _errorMessage = 'No sketch to save'; notifyListeners(); return; }
    _isLoading = true;
    _errorMessage = null;
    _lastSavedPath = null;
    notifyListeners();
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final name = projectName ?? 'Project_' + DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'sketch_' + id + '.png';
      final path = await _sketchService.saveSketch(_sketchBytes!, fileName);
      if (path != null) {
        _lastSavedPath = path;
        final item = SketchItem(id: id, projectName: name, originalImagePath: _selectedImage!.path, sketchImagePath: path, sketchType: _selectedSketchType!, createdAt: DateTime.now(), isSaved: true, lastModifiedAt: DateTime.now());
        await _historyStorage.addItem(item);
        _currentProject = item;
        await loadHistory();
      } else { _errorMessage = 'Failed to save sketch'; }
    } catch (e) { _errorMessage = 'Error: ' + e.toString(); }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    try { _history = await _historyStorage.loadHistory(); } catch (e) { _errorMessage = 'Error: ' + e.toString(); _history = []; }
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final index = _history.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _history[index];
        final updatedItem = item.copyWith(isFavorite: !item.isFavorite, lastModifiedAt: DateTime.now());
        _history[index] = updatedItem;
        await _historyStorage.updateItem(updatedItem);
        await loadHistory();
      }
    } catch (e) { _errorMessage = 'Error: ' + e.toString(); }
  }

  Future<void> renameProject(String id, String newName) async {
    try {
      final index = _history.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _history[index];
        final updatedItem = item.copyWith(projectName: newName, lastModifiedAt: DateTime.now());
        _history[index] = updatedItem;
        await _historyStorage.updateItem(updatedItem);
        await loadHistory();
      }
    } catch (e) { _errorMessage = 'Error: ' + e.toString(); }
  }

  Future<void> deleteHistoryItem(String id) async { try { await _historyStorage.deleteItem(id); await loadHistory(); } catch (e) { _errorMessage = 'Error: ' + e.toString(); } }
  Future<void> clearHistory() async { try { await _historyStorage.clearHistory(); await loadHistory(); } catch (e) { _errorMessage = 'Error: ' + e.toString(); } }


  void loadProject(SketchItem project) {
    _currentProject = project;
    if (project.sketchImagePath != null) {
      _selectedImage = File(project.originalImagePath);
      _selectedImageBytes = File(project.sketchImagePath!).readAsBytesSync();
      _sketchBytes = _selectedImageBytes;
      _selectedSketchType = project.sketchType;
    }
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    _selectedImageBytes = null;
    _sketchBytes = null;
    _selectedSketchType = null;
    _currentProject = null;
    _errorMessage = null;
    _lastSavedPath = null;
    notifyListeners();
  }
}
