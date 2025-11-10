import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chapters = [
      {'name': 'BAB 1', 'icon': 'assets/book.png'},
      {'name': 'BAB 2', 'icon': 'assets/book.png'},
      {'name': 'BAB 3', 'icon': 'assets/book.png'},
      {'name': 'BAB 4', 'icon': 'assets/book.png'},
      {'name': 'BAB 5', 'icon': 'assets/book.png'},
      {'name': 'BAB 6', 'icon': 'assets/book.png'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFB388FF), // ungu pastel
      body: SafeArea(
        child: Column(
          children: [
            // ==== HEADER DENGAN LOGOUT ====
            Container(
              color: const Color(0xFFFFB0B5), // pink pastel
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // teks di tengah
                  const Center(
                    child: Text(
                      'InterQuiz',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // tombol logout di kanan atas
                  Positioned(
                    right: 0,
                    child: IconButton(
                      tooltip: 'Logout',
                      icon: const Icon(Icons.logout, color: Colors.white, size: 26),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ==== SPIN WHEEL ====
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/spinner.png',
                      width: 36,
                      height: 36,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Spin Wheel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==== JUDUL BESAR ====
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  'Dasar-Dasar Desain\nKomunikasi Visual',
                  textAlign: TextAlign.center, // agar teks rata tengah
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ==== PRETEST ====
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: InkWell(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/catatan.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'PreTest',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ==== GRID BAB ====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  itemCount: chapters.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            categoryId: chapters[index]['name'],
                          ),
                        ));
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            chapters[index]['icon'],
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            chapters[index]['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==== POSTTEST ====
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: InkWell(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/catatan.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'PostTest',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
