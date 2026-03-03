// Nama : Qlio Amanda Febriany | Nim : 241511087 | Kelas : 2C
import 'package:flutter/material.dart';
import 'login_controller.dart';
import '../features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _c = LoginController();
  final TextEditingController _userC = TextEditingController();
  final TextEditingController _passC = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  // --- PALET WARNA MODERN (Senada dengan Onboarding) ---
  final Color _bgBlue = const Color(0xFFE1F5FE);     // Background Biru Muda
  final Color _primaryBlue = const Color(0xFF1565C0); // Biru Tua (Aksen Utama)
  final Color _errorRed = const Color(0xFFD32F2F);   // Merah untuk Error/Locked

  @override
  void dispose() {
    _userC.dispose(); _passC.dispose(); _c.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      if (_c.login(_userC.text, _passC.text)) {
        // Login Sukses
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LogView(username: _userC.text)),
        );
      } else {
        // Login Gagal
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            _c.isLocked.value ? "Akses Terkunci Sementara!" : "Username atau Password Salah!",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _c.isLocked.value ? _errorRed : Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBlue, // Background penuh warna
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. LOGO GEMBOK BESAR
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 20, offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Icon(Icons.lock_person_rounded, size: 64, color: _primaryBlue),
              ),
              
              const SizedBox(height: 30),

              // 2. KARTU LOGIN (Form Container)
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 30, offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Silakan masuk untuk melanjutkan catatan harianmu di LogBook pribadi.",
                        style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
                      ),
                      
                      const SizedBox(height: 30),

                      // Input Username
                      _buildTextField(_userC, "Username", Icons.person_outline_rounded),
                      const SizedBox(height: 16),
                      
                      // Input Password
                      _buildTextField(_passC, "Password", Icons.lock_outline_rounded, isPass: true),
                      
                      const SizedBox(height: 30),

                      // TOMBOL LOGIN & TIMER LOGIC
                      ValueListenableBuilder<bool>(
                        valueListenable: _c.isLocked,
                        builder: (ctxLock, isLocked, childLock) => ValueListenableBuilder<int>(
                          valueListenable: _c.remainingTime,
                          builder: (ctxTime, timeLeft, childTime) => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLocked ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: isLocked ? 0 : 8,
                                shadowColor: _primaryBlue.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: isLocked 
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 20),
                                      const SizedBox(width: 8),
                                      Text("Tunggu ${timeLeft}s", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : const Text("Masuk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              // Footer Text (Opsional)
              Text(
                "Versi 1.0.0 • Secure LogBook",
                style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Input Field Kustom yang lebih bersih
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass ? _isObscure : false,
      maxLength: isPass ? 8 : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey.shade400),
        prefixIcon: Icon(icon, color: _primaryBlue),
        filled: true,
        fillColor: Colors.grey.shade50, // Latar input abu sangat muda
        counterText: "", // Sembunyikan counter maxLength
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // Hilangkan garis border default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _errorRed),
        ),
        suffixIcon: isPass ? IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.blueGrey.shade300),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ) : null,
      ),
      validator: (v) => isPass 
        ? (v!.length < 3 ? 'Minimal 3 karakter!' : null) 
        : (v!.isEmpty ? 'Username wajib diisi!' : null),
    );
  }
}