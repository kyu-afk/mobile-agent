// lib/models/jaminan_model.dart
class JaminanModel {
  final String kdJaminan;
  final String deskripsi;
  final String status;

  JaminanModel({
    required this.kdJaminan,
    required this.deskripsi,
    required this.status,
  });

  factory JaminanModel.fromJson(Map<String, dynamic> json) {
    return JaminanModel(
      kdJaminan: json['kd_jaminan']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}