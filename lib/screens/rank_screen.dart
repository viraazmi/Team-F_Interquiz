import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankScreen extends StatelessWidget {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papan Peringkat'), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .limit(50)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada data peringkat.'));
          }

          final userDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (ctx, index) {
              final userData = userDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple[100],
                  child: Text('${index + 1}'),
                ),
                title: Text(userData['fullName'] ?? 'No Name'),
                trailing: Text(
                  '${userData['score'] ?? 0} Poin',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}