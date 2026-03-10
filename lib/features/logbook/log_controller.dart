// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Box;
import 'package:hive_flutter/hive_flutter.dart'; // TAMBAHAN LAKAH 4: Hive
import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';
import '../../services/access_control_service.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  
  final String username;
  final String role; 
  final String teamId; // TAMBAHAN LAKAH 4
  
  String _currentQuery = ""; 
  String _currentCategoryFilter = "Semua";
  
  final MongoService _mongoService = MongoService();
  final Box<LogModel> _myBox = Hive.box<LogModel>('offline_logs'); // Akses Local Storage Hive

  LogController(this.username, this.role, this.teamId); 

  // --- [Langkah 4: OFFLINE-FIRST LOAD] ---
  Future<void> loadFromDisk() async {
    // 1. Ambil data dari Lokal secara instan agar UI tidak kosong
    logsNotifier.value = _myBox.values.toList();
    _refreshFilter();

    try {
      // 2. Coba ambil data terbaru dari Cloud
      final cloudData = await _mongoService.getLogs(teamId); 
      
      // Sinkronisasi data offline yang tertunda ke Cloud
      final cloudIds = cloudData.map((log) => log.id).toSet();
      final localLogs = _myBox.values.toList();
      
      for (var localLog in localLogs) {
        if (!cloudIds.contains(localLog.id)) {
          try {
            await _mongoService.insertLog(localLog); 
            cloudData.add(localLog);
          } catch (e) {
            // Jika gagal upload satu data, tetap lanjut ke data lain
          }
        }
      }
      
      // 3. Simpan hasil sinkronisasi ke Hive
      await _myBox.clear();
      cloudData.sort((a, b) => b.date.compareTo(a.date));
      await _myBox.addAll(cloudData);
      
      // 4. Update UI dengan data yang sudah sinkron
      logsNotifier.value = cloudData;
      _refreshFilter();
      
      await LogHelper.writeLog("SYNC: Berhasil diperbarui dari Cloud", level: 2);
    } catch (e) {
      // --- KUNCI PERBAIKAN OFFLINE ---
      // Jika internet mati/error, pastikan logsNotifier tetap diisi dari Hive
      logsNotifier.value = _myBox.values.toList();
      _refreshFilter();
      
      await LogHelper.writeLog("OFFLINE: Menggunakan cache lokal (Data aman)", level: 2);
    }
  }

  // --- [LAKAH 4: INSTANT ADD + CLOUD SYNC] ---
  Future<void> addLog(String title, String description, String category) async {
    try {
      final newLog = LogModel(
        id: ObjectId().oid, 
        title: title,
        description: description,
        date: DateTime.now().toString(),
        category: category,
        author: username, 
        teamId: teamId, // Otomatis mengisi teamId user
      );
      
      // ACTION 1: Simpan ke Hive Lokal (Instan 0.01 detik!)
      await _myBox.add(newLog);
      logsNotifier.value = _myBox.values.toList();
      _refreshFilter();

      // ACTION 2: Coba kirim ke Cloud (Background)
      try {
        await _mongoService.insertLog(newLog);
        await LogHelper.writeLog("SUCCESS: Data tersinkron ke Cloud", level: 2);
      } catch (e) {
        await LogHelper.writeLog("WARNING: Offline Mode, data tersimpan lokal", level: 1);
      }
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal tambah data - $e", level: 1);
      rethrow;
    }
  }

  // --- [LAKAH 4: INSTANT UPDATE + CLOUD SYNC] ---
  Future<void> updateLog(int index, String newTitle, String newDesc, String newCategory) async {
    try {
      LogModel targetLog = filteredLogsNotifier.value[index];
      if (targetLog.id == null) return;

      if (!AccessControlService.canPerform(role, AccessControlService.actionUpdate, isOwner: targetLog.author == username)) {
        await LogHelper.writeLog("SECURITY BREACH: Edit data ilegal ditolak!", level: 1);
        return; 
      }

      final updatedLog = LogModel(
        id: targetLog.id, 
        title: newTitle,
        description: newDesc,
        date: targetLog.date, 
        category: newCategory,
        author: targetLog.author, 
        teamId: targetLog.teamId, 
      );

      // ACTION 1: Update di Hive (Instan)
      final boxMap = _myBox.toMap();
      for (var entry in boxMap.entries) {
        if (entry.value.id == updatedLog.id) {
          await _myBox.put(entry.key, updatedLog);
          break;
        }
      }
      logsNotifier.value = _myBox.values.toList();
      _refreshFilter();

      // ACTION 2: Sync ke Cloud
      try {
        await _mongoService.updateLog(updatedLog);
      } catch (e) {
        await LogHelper.writeLog("WARNING: Update lokal sukses, Cloud offline", level: 1);
      }
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal update - $e", level: 1);
    }
  }

  // --- [LAKAH 4: INSTANT DELETE + CLOUD SYNC] ---
  Future<void> deleteLog(int index) async {
    try {
      LogModel targetLog = filteredLogsNotifier.value[index];
      if (targetLog.id == null) return;

      if (!AccessControlService.canPerform(role, AccessControlService.actionDelete, isOwner: targetLog.author == username)) {
        await LogHelper.writeLog("SECURITY BREACH: Hapus data ilegal ditolak!", level: 1);
        return; 
      }

      // ACTION 1: Hapus dari Hive (Instan)
      final boxMap = _myBox.toMap();
      for (var entry in boxMap.entries) {
        if (entry.value.id == targetLog.id) {
          await _myBox.delete(entry.key);
          break;
        }
      }
      logsNotifier.value = _myBox.values.toList();
      _refreshFilter();

      // ACTION 2: Hapus dari Cloud
      try {
        await _mongoService.deleteLog(targetLog.id!);
      } catch (e) {
        await LogHelper.writeLog("WARNING: Delete lokal sukses, Cloud offline", level: 1);
      }
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal hapus - $e", level: 1);
    }
  }

  void searchLog({String? query, String? category}) {
    if (query != null) _currentQuery = query;
    if (category != null) _currentCategoryFilter = category;
    _refreshFilter();
  }

  void resetFilter() {
    _currentQuery = "";
    _currentCategoryFilter = "Semua";
    _refreshFilter();
  }

  void _refreshFilter() {
    List<LogModel> results = logsNotifier.value;
    if (_currentCategoryFilter != "Semua") results = results.where((log) => log.category == _currentCategoryFilter).toList();
    if (_currentQuery.isNotEmpty) {
      final queryLower = _currentQuery.toLowerCase();
      results = results.where((log) {
        return log.title.toLowerCase().contains(queryLower) || 
               log.description.toLowerCase().contains(queryLower) || 
               log.author.toLowerCase().contains(queryLower); 
      }).toList();
    }
    filteredLogsNotifier.value = results;
  }
}