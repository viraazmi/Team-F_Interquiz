import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  const QuizScreen({super.key, required this.categoryId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.categoryId)
        .collection('questions')
        .get();

    final fetchedQuestions = snapshot.docs
        .map((doc) => Question.fromFirestore(doc.data()))
        .toList();

    if(mounted) {
      setState(() {
        _questions = fetchedQuestions;
        _isLoading = false;
      });
    }
  }

  void _answerQuestion(int selectedIndex) {
    if (_selectedAnswerIndex != null) return;

    setState(() {
      _selectedAnswerIndex = selectedIndex;
      if (selectedIndex == _questions[_questionIndex].correctAnswerIndex) {
        _score++;
      }
    });

    Timer(const Duration(seconds: 1), () {
      if (_questionIndex < _questions.length - 1) {
        if(mounted) {
          setState(() {
            _questionIndex++;
            _selectedAnswerIndex = null;
          });
        }
      } else {
        if(mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) =>
                ResultsScreen(score: _score, totalQuestions: _questions.length),
          ));
        }
      }
    });
  }

  Color _getButtonColor(int index) {
    if (_selectedAnswerIndex != null) {
      if (index == _questions[_questionIndex].correctAnswerIndex) {
        return Colors.green;
      } else if (index == _selectedAnswerIndex) {
        return Colors.red;
      }
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[400],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _questions.isEmpty
                ? const Center(
                    child: Text("Soal untuk kategori ini belum tersedia.",
                        style: TextStyle(color: Colors.white, fontSize: 18)))
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Soal ${_questionIndex + 1}/${_questions.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _questions[_questionIndex].questionText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ...List.generate(
                            _questions[_questionIndex].options.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getButtonColor(index),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text(
                                  _questions[_questionIndex].options[index],
                                  style: const TextStyle(color: Colors.black)),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
      ),
    );
  }
}