// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String? id; // Ubah ke String agar Hive bisa menyimpannya

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String author; 

  @HiveField(6)
  final String teamId; // Tambahan wajib untuk Modul 5

  LogModel({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
    required this.author,
    required this.teamId, // Wajib diisi
  });

  // Konversi dari Cloud (BSON) ke Aplikasi
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] as ObjectId?)?.oid, // Convert ObjectId dari Mongo ke String
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pekerjaan',
      author: map['author'] ?? 'Unknown',
      teamId: map['teamId'] ?? 'no_team',
    );
  }

  // Konversi dari Aplikasi ke Cloud (BSON)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': ObjectId.fromHexString(id!), // Convert balik ke ObjectId
      'title': title,
      'date': date,
      'description': description,
      'category': category,
      'author': author,
      'teamId': teamId,
    };
  }
}