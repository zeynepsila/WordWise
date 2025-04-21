import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'game_result_screen.dart';

class GameScreen extends StatefulWidget {
  final int gameId;
  final String meaningTr;
  const GameScreen({super.key, required this.gameId, required this.meaningTr});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String wordProgress = '';
  int attemptsLeft = 0;
  bool isWon = false;
  bool isFinished = false;
  final _letterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGameStatus();
  }

  Future<void> _loadGameStatus() async {
    final result = await ApiService.getGameStatus(widget.gameId);
    if (result['status'] == 'ok') {
      setState(() {
        wordProgress = result['word_progress'];
        attemptsLeft = result['remaining_attempts'];
        isWon = result['is_won'];
        isFinished = isWon || attemptsLeft == 0;
      });

      if (isFinished) {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameResultScreen(gameId: widget.gameId),
            ),
          );
        });
      }
    }
  }

  Future<void> _submitGuess() async {
    final letter = _letterController.text.trim().toLowerCase();
    if (letter.isEmpty || letter.length != 1) return;

    final result = await ApiService.guess(widget.gameId, letter);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? (result['correct'] ? "Correct!" : "Wrong!"))),
    );

    _letterController.clear();
    await _loadGameStatus();
  }

  String _getAsciiHangman() {
    final asciiStages = [
      '''
      
      
      
      
      
=========
''',
      '''
      |
      |
      |
      |
      |
=========
''',
      '''
  +---+
      |
      |
      |
      |
=========
''',
      '''
  +---+
  |   |
  O   |
      |
      |
=========
''',
      '''
  +---+
  |   |
  O   |
  |   |
      |
=========
''',
      '''
  +---+
  |   |
  O   |
 /|\\  |
 / \\  |
=========
''',
    ];
    return asciiStages[5 - attemptsLeft.clamp(0, 5)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: const Text("Word Guessing"),
        backgroundColor: Colors.deepPurple.shade300,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Clue (TR)",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.meaningTr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepPurple.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getAsciiHangman(),
                style: const TextStyle(fontFamily: 'Courier', fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              wordProgress.split('').join(' '),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),
            Text(
              "Remaining Attempts: $attemptsLeft",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 24),

            if (!isFinished) ...[
              TextField(
                controller: _letterController,
                maxLength: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Enter a letter',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitGuess,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Guess"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
