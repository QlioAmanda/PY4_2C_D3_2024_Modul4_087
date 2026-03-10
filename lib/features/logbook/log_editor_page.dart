// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart';
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final String username; // Disesuaikan dengan strukturmu

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.username,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  // Fitur Kategori (Disesuaikan agar tidak merusak kodemu yang lama)
  String _selectedCategory = 'Pekerjaan';
  final List<String> _categories = ['Pekerjaan', 'Pribadi', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _selectedCategory = widget.log?.category ?? 'Pekerjaan';

    // Listener agar Tab Pratinjau terupdate otomatis saat mengetik
    _descController.addListener(() {
      setState(() {}); 
    });
  }

  void _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Judul tidak boleh kosong!"), backgroundColor: Colors.red));
      return;
    }

    try {
      if (widget.log == null) {
        // Tambah Baru
        await widget.controller.addLog(
          _titleController.text,
          _descController.text,
          _selectedCategory,
        );
      } else {
        // Update Catatan Lama
        await widget.controller.updateLog(
          widget.index!,
          _titleController.text,
          _descController.text,
          _selectedCategory,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Catatan berhasil disimpan!"), backgroundColor: Colors.green));
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          backgroundColor: const Color(0xFF4DB6AC),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Editor", icon: Icon(Icons.edit_document)),
              Tab(text: "Pratinjau", icon: Icon(Icons.preview_rounded)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_rounded, size: 28), 
              tooltip: "Simpan",
              onPressed: _save
            )
          ],
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: EDITOR ---
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Judul Catatan",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dropdown Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400)
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: _categories.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                        onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // UBAH: Menghapus 'Expanded' dan mengatur 'minLines' agar kotak tidak tergencet
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade500),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: null, // Bisa mengetik panjang ke bawah tanpa batas
                      minLines: 12,   // Tinggi minimal kotak dibuat 12 baris teks
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Tulis dengan Markdown...\n\nContoh:\n# Judul Besar\n## Subjudul\n**Teks Tebal**\n* Item List\n\n`Kode Program`",
                        border: InputBorder.none, 
                        contentPadding: EdgeInsets.all(16), 
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TAB 2: PRATINJAU MARKDOWN ---
            Container(
              padding: const EdgeInsets.all(16.0),
              child: _descController.text.isEmpty 
                ? Center(child: Text("Belum ada teks untuk dipratinjau", style: TextStyle(color: Colors.grey.shade500)))
                : MarkdownBody(
                    data: _descController.text,
                    selectable: true, // Teks bisa di-copy
                  ),
            )
          ],
        ),
      ),
    );
  }
}