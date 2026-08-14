import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentType {
  priceList,
  menu,
  brochure,
  catalog,
  other,
}

enum UploadStatus {
  pending,
  uploading,
  uploaded,
  processing,
  completed,
  failed,
}

class KnowledgeDocumentModel {
  final String id;
  final String fileName;
  final DocumentType documentType;
  final String storagePath;
  final String? downloadUrl;
  final int fileSize;
  final String mimeType;
  final UploadStatus uploadStatus;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeDocumentModel({
    required this.id,
    required this.fileName,
    required this.documentType,
    required this.storagePath,
    this.downloadUrl,
    required this.fileSize,
    required this.mimeType,
    this.uploadStatus = UploadStatus.pending,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeDocumentModel.fromMap(String id, Map<String, dynamic> map) {
    return KnowledgeDocumentModel(
      id: id,
      fileName: map['fileName'] as String? ?? '',
      documentType: _parseDocumentType(map['documentType']),
      storagePath: map['storagePath'] as String? ?? '',
      downloadUrl: map['downloadUrl'] as String?,
      fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
      mimeType: map['mimeType'] as String? ?? '',
      uploadStatus: _parseUploadStatus(map['uploadStatus']),
      errorMessage: map['errorMessage'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'documentType': documentType.name,
      'storagePath': storagePath,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadStatus': uploadStatus.name,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  KnowledgeDocumentModel copyWith({
    String? id,
    String? fileName,
    DocumentType? documentType,
    String? storagePath,
    String? downloadUrl,
    int? fileSize,
    String? mimeType,
    UploadStatus? uploadStatus,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KnowledgeDocumentModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      documentType: documentType ?? this.documentType,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DocumentType _parseDocumentType(String? value) {
    return DocumentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DocumentType.other,
    );
  }

  static UploadStatus _parseUploadStatus(String? value) {
    return UploadStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UploadStatus.pending,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String get documentTypeLabel {
    switch (documentType) {
      case DocumentType.priceList:
        return 'Price List';
      case DocumentType.menu:
        return 'Menu';
      case DocumentType.brochure:
        return 'Brochure';
      case DocumentType.catalog:
        return 'Catalog';
      case DocumentType.other:
        return 'Other';
    }
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}