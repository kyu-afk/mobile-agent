// lib/models/permohonan_pinjaman_model.dart
class PengajuanModel {
  final String noId;
  final String nama;
  final String noHp;
  final String alamat;
  final String kdJaminan;
  final String nilaiPinjaman;
  final String jkWaktu;
  final String rate;
  final String status;
  final String tglinput;
  final String tglproses;
  final String tglkeputusan;
  final String userHandle;
  final String alasan;
  final String fhotojaminan;

  PengajuanModel({
    required this.noId,
    required this.nama,
    required this.noHp,
    required this.alamat,
    required this.kdJaminan,
    required this.nilaiPinjaman,
    required this.jkWaktu,
    required this.rate,
    required this.status,
    required this.tglinput,
    required this.tglproses,
    required this.tglkeputusan,
    required this.userHandle,
    required this.alasan,
    this.fhotojaminan = '',

  });

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    return PengajuanModel(
      noId: json['no_id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      kdJaminan: json['jaminan']?.toString() ?? '',
      nilaiPinjaman: json['nilai_pinjaman']?.toString() ?? '0',
      jkWaktu: json['jk_waktu']?.toString() ?? '0',
      rate: json['rate']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
      tglinput: json['tgl_input']?.toString() ?? '',
      tglproses: json['tgl_proses']?.toString() ?? '',
      tglkeputusan: json['tgl_keputusan']?.toString() ?? '',
      userHandle: json['user_handle']?.toString() ?? '',
      alasan: json['alasan']?.toString() ?? '',
      fhotojaminan: json['fhoto_jaminan']?.toString() ?? '',
    );
  }
}