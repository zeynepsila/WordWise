import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GuessHistoryScreen extends StatefulWidget {
  final int gameId;
  const GuessHistoryScreen({super.key, required this.gameId});

  @override
  State<GuessHistoryScreen> createState() => _GuessHistoryScreenState();
}

class _GuessHistoryScreenState extends State<GuessHistoryScreen> {
  List<dynamic> _guesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuesses();
  }

  Future<void> _fetchGuesses() async {
    final result = await ApiService.getGuesses(widget.gameId);

    if (result['status'] == 'ok') {
      setState(() {
        _guesses = result['guesses'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not load guess history")),
      );
    }
  }

  Widget _buildGuessCard(Map<String, dynamic> guess) {
    final bool isCorrect = guess['is_correct'] == 1;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCorrect ? Colors.green : Colors.red,
          child: Icon(
            isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          "Letter: ${guess['letter'].toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Guessed at: ${guess['guessed_at']}"),
        trailing: Text(
          isCorrect ? "Correct" : "Wrong",
          style: TextStyle(
            color: isCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guess History"),
        backgroundColor: const Color(0xFFF3E8FF), // Pastel purple for AppBar
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF3E8FF), // Same pastel purple for the screen
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guesses.isEmpty
          ? const Center(child: Text("No guesses made."))
          : ListView.builder(
        itemCount: _guesses.length,
        itemBuilder: (context, index) {
          return _buildGuessCard(_guesses[index]);
        },
      ),
    );
  }
}
