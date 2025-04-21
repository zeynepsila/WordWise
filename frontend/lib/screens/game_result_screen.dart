import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class GameResultScreen extends StatefulWidget {
  final int gameId;
  const GameResultScreen({super.key, required this.gameId});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  bool? isWon;
  String word = '';
  String meaningTr = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGameResult();
  }

  Future<void> _fetchGameResult() async {
    final result = await ApiService.getGameStatus(widget.gameId);

    if (result['status'] == 'ok') {
      setState(() {
        isWon = result['is_won'];
        word = result['word'];
        meaningTr = result['meaning_tr'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Oyun sonucu alınamadı")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF), // Background color set to the pastel purple
      appBar: AppBar(
        title: const Text("Game Result"),
        backgroundColor: const Color(0xFFF3E8FF),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWon == null
          ? const Center(child: Text("Sonuç alınamadı."))
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWon! ? Icons.emoji_events : Icons.cancel,
              color: isWon! ? Colors.green : Colors.red,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              isWon! ? "🎉 You Won!" : "😢 You Lost!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "The word was: \"$word\"",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Meaning (TR): $meaningTr",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade700],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
