import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'game_screen.dart';

class StartGameScreen extends StatefulWidget {
  const StartGameScreen({super.key});

  @override
  State<StartGameScreen> createState() => _StartGameScreenState();
}

class _StartGameScreenState extends State<StartGameScreen> {
  String _selectedLevel = 'beginner';
  bool _isLoading = false;

  Future<void> _startGame() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.startGame(_selectedLevel);

      if (result['status'] == 'ok') {
        int gameId = int.parse(result['game_id'].toString());
        String meaningTr = result['meaning_tr'] ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(gameId: gameId, meaningTr: meaningTr),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Oyun başlatılamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        title: const Text(
          'Start New Game',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Color(0xFF6A1B9A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Difficulty",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: InputDecoration(
                      labelText: 'Level',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'beginner',
                        child: Row(
                          children: [
                            Icon(Icons.star_border, color: Colors.green),
                            SizedBox(width: 8),
                            Text("Beginner"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'intermediate',
                        child: Row(
                          children: [
                            Icon(Icons.star_half, color: Colors.orange),
                            SizedBox(width: 8),
                            Text("Intermediate"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'advanced',
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text("Advanced"),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLevel = value);
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: const Color(0xFF7E57C2), // pastel lila tonu
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shadowColor: Colors.deepPurple.withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.play_arrow, size: 24),
                        SizedBox(width: 8),
                        Text("Start Game"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
