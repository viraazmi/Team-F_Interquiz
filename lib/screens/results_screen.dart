import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultsScreen({super.key, required this.score, required this.totalQuestions});

  void _updateUserScore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'score': FieldValue.increment(score * 10),
        'coins': FieldValue.increment(score * 5),
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    _updateUserScore();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Kuis Selesai!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Skor Anda:', style: TextStyle(fontSize: 24)),
            Text(
              '${score * 10}',
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            Text('Benar $score dari $totalQuestions pertanyaan', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Kembali ke Halaman Utama'),
            ),
          ],
        ),
      ),
    );
  }
}