import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Inisialisasi instance Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variabel untuk menyimpan data pengguna
  Map<String, dynamic>? userData;

  // Variabel untuk menyimpan riwayat kuiz pengguna
  List<Map<String, dynamic>> quizHistory = [];

  // Flag loading untuk history supaya UI profil tetap muncul cepat
  bool isHistoryLoading = true;

  @override
  void initState() {
    super.initState();

    // Isi awal cepat dari FirebaseAuth supaya UI muncul langsung
    final current = _auth.currentUser;
    userData = {
      'name': current?.displayName ?? 'Nama Tidak Diketahui',
      'email': current?.email ?? '',
      'avatar': 'assets/profil.png',
    };

    // Ambil data Firestore di background dan update UI ketika selesai
    _loadUserData();
    _loadQuizHistory();
  }

  ImageProvider _imageProvider(String? path) {
    if (path == null) return const AssetImage('assets/profil.png');
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  // Mengambil data pengguna dari Firestore berdasarkan UID
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          // Gabungkan data Firestore dengan data awal (firebaseAuth)
          setState(() {
            userData = {
              ...?userData,
              ...data,
            };
          });
        }
      } catch (_) {
        // silent fail — tetap tunjukkan data awal
      }
    }
  }

  // Mengambil daftar history kuiz user dari subkoleksi Firestore
  Future<void> _loadQuizHistory() async {
    setState(() {
      isHistoryLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final historySnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_history')
            .orderBy('date', descending: true)
            .get();

        setState(() {
          quizHistory = historySnap.docs.map((doc) => doc.data()).toList();
        });
      } catch (_) {
        setState(() {
          quizHistory = [];
        });
      }
    }

    if (mounted) {
      setState(() {
        isHistoryLoading = false;
      });
    }
  }

  // Fungsi logout dari akun Firebase
  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login'); // Kembali ke halaman login
    }
  }

  // === BARU: dialog edit profil ===
  Future<void> _showEditProfileDialog() async {
    final user = _auth.currentUser;
    final nameController = TextEditingController(text: userData?['name'] as String?);
    final avatarController = TextEditingController(text: userData?['avatar'] as String?);
    var saving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Profil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(
                    labelText: 'Avatar (URL atau asset path)',
                    hintText: 'contoh: https://... atau assets/profil.png',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final newName = nameController.text.trim();
                        final newAvatar = avatarController.text.trim();
                        if (newName.isEmpty) {
                          // simple validation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama tidak boleh kosong')),
                          );
                          return;
                        }

                        setStateDialog(() => saving = true);

                        try {
                          if (user != null) {
                            // update Firestore user doc
                            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                              'name': newName,
                              'avatar': newAvatar,
                            }, SetOptions(merge: true));

                            // update FirebaseAuth profile (optional)
                            try {
                              await user.updateDisplayName(newName);
                              await user.updatePhotoURL(newAvatar);
                              await user.reload();
                            } catch (_) {
                              // ignore auth update error
                            }

                            // update local state
                            if (mounted) {
                              setState(() {
                                userData = {
                                  ...?userData,
                                  'name': newName,
                                  'avatar': newAvatar,
                                };
                              });
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
                          );
                        } finally {
                          if (mounted) {
                            setStateDialog(() => saving = false);
                            Navigator.of(context).pop();
                          }
                        }
                      },
                child: saving ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D7FF), // Warna dasar lembut ungu muda
      body: SafeArea(
        // Tampilkan UI profil segera — data akan diperbarui jika Firestore merespon
        child: SingleChildScrollView(
          // Menghindari overflow saat layar kecil
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === HEADER APLIKASI ===
              Container(
                color: const Color(0xFFFFB0B5),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Profil Pengguna',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Tombol edit di header (ikon kecil) agar mudah diakses
                    IconButton(
                      onPressed: _showEditProfileDialog,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Edit Profil',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // === FOTO PROFIL BESAR DI TENGAH ===
              CircleAvatar(
                radius: 60, // Ukuran besar agar lebih menonjol
                backgroundImage: _imageProvider(userData?['avatar'] as String?),
              ),

              const SizedBox(height: 16),

              // === NAMA DAN EMAIL PENGGUNA ===
              Text(
                userData?['name'] ?? 'Nama Tidak Diketahui',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _auth.currentUser?.email ?? userData?['email'] ?? 'Email tidak tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 12),
              // Tombol edit alternatif di bawah nama (lebih jelas untuk pengguna)
              TextButton.icon(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit, color: Color(0xFF4A148C)),
                label: const Text(
                  'Edit Profil',
                  style: TextStyle(color: Color(0xFF4A148C), fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 18),

              // === BAGIAN RIWAYAT KUIZ ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul riwayat kuiz
                        const Text(
                          'Riwayat Kuiz 📚',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Loading indicator hanya untuk history
                        if (isHistoryLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (quizHistory.isEmpty)
                          const Center(
                            child: Text(
                              'Belum ada riwayat kuiz',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: quizHistory.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Kiri: ikon + info kuiz
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: const AssetImage('assets/book.png'),
                                          backgroundColor: Colors.deepPurple[100],
                                          radius: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'] ?? 'Kuiz Tidak Diketahui',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              item['date'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Kanan: skor
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB0B5),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${item['score'] ?? 0}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // === TOMBOL LOGOUT ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB0B5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}