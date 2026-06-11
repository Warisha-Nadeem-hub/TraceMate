enum SketchType { pencilSketch, outlineSketch, highContrastSketch, smoothSketch, artisticSketch, comicSketch, drawSketch }

extension SketchTypeExtension on SketchType {
  String get displayName {
    switch (this) {
      case SketchType.pencilSketch: return 'Pencil Sketch';
      case SketchType.outlineSketch: return 'Outline Sketch';
      case SketchType.highContrastSketch: return 'High Contrast';
      case SketchType.smoothSketch: return 'Smooth';
      case SketchType.artisticSketch: return 'Artistic';
      case SketchType.comicSketch: return 'Comic';
      case SketchType.drawSketch: return 'Free Draw';
    }
  }
}

class SketchItem {
  final String id;
  String projectName;
  final String originalImagePath;
  String? sketchImagePath;
  final SketchType sketchType;
  final DateTime createdAt;
  DateTime? lastModifiedAt;
  bool isSaved;
  bool isFavorite;

  SketchItem({required this.id, this.projectName = 'Untitled', required this.originalImagePath, this.sketchImagePath, required this.sketchType, required this.createdAt, this.lastModifiedAt, this.isSaved = false, this.isFavorite = false});


  SketchItem copyWith({String? id, String? projectName, String? originalImagePath, String? sketchImagePath, SketchType? sketchType, DateTime? createdAt, DateTime? lastModifiedAt, bool? isSaved, bool? isFavorite}) {
    return SketchItem(id: id ?? this.id, projectName: projectName ?? this.projectName, originalImagePath: originalImagePath ?? this.originalImagePath, sketchImagePath: sketchImagePath ?? this.sketchImagePath, sketchType: sketchType ?? this.sketchType, createdAt: createdAt ?? this.createdAt, lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt, isSaved: isSaved ?? this.isSaved, isFavorite: isFavorite ?? this.isFavorite);
  }

  Map<String, dynamic> toJson() => {'id': id, 'projectName': projectName, 'originalImagePath': originalImagePath, 'sketchImagePath': sketchImagePath, 'sketchType': sketchType.index, 'createdAt': createdAt.toIso8601String(), 'lastModifiedAt': lastModifiedAt?.toIso8601String(), 'isSaved': isSaved, 'isFavorite': isFavorite};

  factory SketchItem.fromJson(Map<String, dynamic> json) => SketchItem(id: json['id'] as String, projectName: json['projectName'] as String? ?? 'Untitled', originalImagePath: json['originalImagePath'] as String, sketchImagePath: json['sketchImagePath'] as String?, sketchType: SketchType.values[json['sketchType'] as int], createdAt: DateTime.parse(json['createdAt'] as String), lastModifiedAt: json['lastModifiedAt'] != null ? DateTime.parse(json['lastModifiedAt'] as String) : null, isSaved: json['isSaved'] as bool? ?? false, isFavorite: json['isFavorite'] as bool? ?? false);
}
