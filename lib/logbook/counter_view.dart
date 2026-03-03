// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:flutter/material.dart';
import 'counter_controller.dart';
import 'package:logbook_app_087/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late CounterController _c;
  bool _isLoading = true;
  
  // PALET WARNA VINTAGE (DARK CARD)
  final Color _bgCream = const Color(0xFFFDF5E6);   // Latar belakang terang
  final Color _darkCard = const Color(0xFF3E2723);  // REVISI: Kotak Coklat Tua (Dark Brown)
  final Color _lightText = const Color(0xFFFFF8E1); // Teks terang untuk di dalam kotak
  final Color _accentGold = const Color(0xFFD4AF37); // Aksen emas vintage

  @override
  void initState() {
    super.initState();
    _c = CounterController(widget.username);
    _c.loadData(() { if (mounted) setState(() => _isLoading = false); });
  }

  void _dialog(String title, String msg, VoidCallback onYes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgCream,
        title: Text(title, style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold, fontFamily: 'serif')), 
        content: Text(msg, style: const TextStyle(color: Color(0xFF3E2723), fontFamily: 'serif')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Color(0xFF6D4C41)))),
          TextButton(onPressed: () { Navigator.pop(ctx); onYes(); }, 
            child: const Text("Ya", style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // REVISI LINT: Menambahkan kurung kurawal pada if-else
  void _handleLogic(bool isSuccess, String errorMsg) {
    if (!isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: const Color(0xFFA1887F))
      );
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(backgroundColor: _bgCream, body: const Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        title: Text("LogBook: ${widget.username}", 
          style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold, fontFamily: 'serif')),
        centerTitle: true, backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Color(0xFF3E2723)),
            onPressed: () => _dialog("Tutup LogBook", "Yakin ingin menyimpan dan keluar?", () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingView()), (r) => false);
            }),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBanner(), const SizedBox(height: 15),
            _buildTotal(), const SizedBox(height: 15),
            _buildSlider(), const SizedBox(height: 20),
            _buildButtons(), const SizedBox(height: 20),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _darkCard, // Kotak Coklat Tua
        borderRadius: BorderRadius.circular(15),
        // FIX OPACITY LINT
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: _accentGold.withValues(alpha: 0.5), width: 1), // Garis tepi emas
      ),
      child: child,
    );
  }

  Widget _buildBanner() {
    int h = DateTime.now().hour;
    String greet = h < 12 ? "Pagi" : h < 15 ? "Siang" : h < 19 ? "Sore" : "Malam";
    return _buildCard(Row(children: [
       Icon(Icons.history_edu_rounded, color: _accentGold, size: 32),
       const SizedBox(width: 12),
       Text("Selamat $greet, Tuan ${widget.username}.", 
         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _lightText, fontFamily: 'serif')),
    ]));
  }

  Widget _buildTotal() {
    return _buildCard(Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(children: [
        Text("TOTAL CATATAN", style: TextStyle(fontWeight: FontWeight.bold, color: _accentGold, letterSpacing: 1.5, fontFamily: 'serif')),
        const SizedBox(height: 10),
        Text('${_c.value}', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: _lightText, fontFamily: 'serif')),
        const SizedBox(height: 10),
        Text("Kapasitas Logbook: 300", style: TextStyle(color: _lightText.withValues(alpha: 0.6), fontFamily: 'serif', fontStyle: FontStyle.italic)),
      ]),
    ));
  }

  Widget _buildSlider() {
    return _buildCard(Row(children: [
      Text("STEP:", style: TextStyle(fontWeight: FontWeight.bold, color: _accentGold, fontFamily: 'serif')),
      Expanded(child: Slider(value: _c.step.toDouble(), min: 1, max: 10, divisions: 9,
          activeColor: _accentGold, inactiveColor: _lightText.withValues(alpha: 0.2), // FIX OPACITY
          onChanged: (v) => setState(() => _c.setStep(v.toInt())))),
      Text("${_c.step}", style: TextStyle(fontWeight: FontWeight.bold, color: _lightText, fontSize: 18, fontFamily: 'serif')),
    ]));
  }

  Widget _buildButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _btn(Icons.remove, const Color(0xFFC62828), () => _handleLogic(_c.decrement(), "Minimal 0!")),
      _btn(Icons.refresh, const Color(0xFFF57F17), () => _dialog("Hapus Tinta", "Kosongkan halaman LogBook?", () {
        setState(() => _c.reset()); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dibersihkan!")));
      })),
      _btn(Icons.add, const Color(0xFF388E3C), () => _handleLogic(_c.increment(), "Maksimal 300!")),
    ]);
  }

  Widget _btn(IconData ic, Color c, VoidCallback onTap) {
    return InkWell(onTap: onTap, customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(shape: BoxShape.circle, color: c,
          boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))], // FIX OPACITY
          border: Border.all(color: _bgCream, width: 2)),
        child: Icon(ic, color: _bgCream, size: 28),
      ));
  }

  Widget _buildHistory() {
    return _buildCard(SizedBox(
      height: 250,
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text("RIWAYAT TULISAN", 
          style: TextStyle(fontWeight: FontWeight.bold, color: _accentGold, fontFamily: 'serif', letterSpacing: 1.2))),
        Divider(height: 1, color: _accentGold.withValues(alpha: 0.3)), // FIX OPACITY
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(vertical: 10), itemCount: _c.history.length, itemBuilder: (ctx, i) {
            String item = _c.history[i];
            bool isAdd = item.contains("Ditambah"); bool isSub = item.contains("Dikurang");
            return Container(
              margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Warna background list transparan agar menyatu dengan kotak coklat tua
                color: isAdd ? Colors.green.withValues(alpha: 0.2) : isSub ? Colors.red.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8), border: Border.all(color: _lightText.withValues(alpha: 0.1))
              ),
              child: Text(item, style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'serif',
                  // Warna teks riwayat yang terang agar terbaca di background gelap
                  color: isAdd ? Colors.green.shade200 : isSub ? Colors.red.shade200 : Colors.orange.shade200)),
            );
        })),
      ]),
    ));
  }
}