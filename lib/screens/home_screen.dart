import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'quiz_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Ekonomi', 'icon': Icons.account_balance},
      {'name': 'Geografi', 'icon': Icons.public},
      {'name': 'Sejarah', 'icon': Icons.museum},
      {'name': 'Kewarganegaraan', 'icon': Icons.flag},
      {'name': 'English', 'icon': Icons.translate},
      {'name': 'Bahasa Indonesia', 'icon': Icons.book},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz IPS'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Petunjuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('- Pilih Kategori\n- Mainkan Quiz\n- Kumpulkan Koin\n- Tukarkan Koin'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (ctx, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => QuizScreen(categoryId: categories[index]['name']!),
                      ));
                    },
                    child: Card(
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(categories[index]['icon'], size: 40, color: Colors.deepPurple),
                          const SizedBox(height: 10),
                          Text(categories[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}