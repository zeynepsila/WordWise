import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final result = await ApiService.getStats();

    if (result['status'] == 'ok') {
      setState(() {
        stats = result;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("İstatistikler alınamadı")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Statistics"),
        backgroundColor: const Color(0xFFF3E8FF), // Pastel purple background for AppBar
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF3E8FF), // Same pastel purple background for the screen
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
          ? const Center(child: Text("Veri bulunamadı."))
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatCard("Total Games", stats!['total_games'].toString(), Icons.videogame_asset),
            _buildStatCard("Games Won", stats!['games_won'].toString(), Icons.emoji_events),
            _buildStatCard("Success Rate", "${stats!['success_rate']}%", Icons.star),
            _buildStatCard("Avg. Attempts Left", stats!['avg_attempts_left'].toString(), Icons.favorite),
            _buildStatCard("Avg. Correct Guesses", stats!['avg_correct_guesses'].toString(), Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4, // increased elevation for better shadow effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
