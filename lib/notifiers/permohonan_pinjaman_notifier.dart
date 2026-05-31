// lib/notifiers/permohonan_pinjaman_notifier.dart
import 'package:flutter/material.dart';
import '../models/permohonan_pinjaman_model.dart';
import '../repositories/permohonan_pinjaman_repository.dart';

class PengajuanNotifier extends ChangeNotifier {
  final PengajuanRepository _repository = PengajuanRepository();

  List<PengajuanModel> _data = [];
  List<PengajuanModel> _historiData = [];
  bool _isLoading = false;
  bool _isLoadingHistori = false;
  bool _isUpdating = false;
  String _errorMessage = '';
  String _errorMessageHistori = '';

  final Map<String, String> _jaminanMap = {};

  List<PengajuanModel> get data => _data;
  List<PengajuanModel> get historiData => _historiData;
  bool get isLoading => _isLoading;
  bool get isLoadingHistori => _isLoadingHistori;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;
  String get errorMessageHistori => _errorMessageHistori;

  Future<void> loadMasterJaminan() async {
    final jaminanList = await _repository.getAllJaminan();
    for (var j in jaminanList) {
      if (j.status == 'A') {
        _jaminanMap[j.kdJaminan] = j.deskripsi;
      }
    }
  }

  Future<void> loadPengajuan() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_jaminanMap.isEmpty) await loadMasterJaminan();
      _data = await _repository.getPengajuan();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistori() async {
    _isLoadingHistori = true;
    _errorMessageHistori = '';
    notifyListeners();

    try {
      if (_jaminanMap.isEmpty) await loadMasterJaminan();
      _historiData = await _repository.getHistori();
    } catch (e) {
      _errorMessageHistori = e.toString();
    } finally {
      _isLoadingHistori = false;
      notifyListeners();
    }
  }

  String getNamaJaminan(String kdJaminan) {
    if (kdJaminan.isEmpty) return 'Tidak ada jaminan';
    return _jaminanMap[kdJaminan] ?? 'Kode: $kdJaminan (tidak dikenal)';
  }

  Future<bool> updateStatus({
    required String noId,
    required String noHp,
    required String status,
    required String alasan,
    required String tglKeputusan,
  }) async {
    _isUpdating = true;
    notifyListeners();

    final success = await _repository.updateStatus(
      noId: noId,
      noHp: noHp,
      status: status,
      alasan: alasan,
      tglKeputusan: tglKeputusan,
    );

    if (success) {
      await loadPengajuan();
      await loadHistori();
    }

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  Future<void> refreshData() async => loadPengajuan();
  Future<void> refreshHistori() async => loadHistori();
}