import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'guess_history_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGameHistory();
  }

  Future<void> _fetchGameHistory() async {
    final result = await ApiService.getGames();

    if (result['status'] == 'ok') {
      setState(() {
        _games = result['games'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geçmiş oyunlar alınamadı")),
      );
    }
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    final bool isWon = game['is_won'] == 1;
    final String date = game['played_at'].toString().split(' ').first;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          isWon ? Icons.emoji_events : Icons.cancel,
          color: isWon ? Colors.green : Colors.red,
        ),
        title: Text(
          "Word: ${game['word']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Level: ${game['level']} • Attempts left: ${game['attempts_left']}",
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 20, color: Colors.blueGrey),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GuessHistoryScreen(gameId: game['id']),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game History"),
        backgroundColor: const Color(0xFFF3E8FF), // Pastel purple background
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF3E8FF), // Pastel purple background for the screen
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
          ? const Center(child: Text("Henüz hiç oyun oynamamışsınız."))
          : ListView.builder(
        itemCount: _games.length,
        itemBuilder: (context, index) {
          return _buildGameCard(_games[index]);
        },
      ),
    );
  }
}
