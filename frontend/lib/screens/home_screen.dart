import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'start_game_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) _logout();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, size: 32, color: color ?? Colors.blueAccent),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'WordWise',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 28,
            color: Color(0xFF6A1B9A),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCard(
              icon: Icons.play_arrow,
              title: "Start New Game",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StartGameScreen()));
              },
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.history,
              title: "My Game History",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.bar_chart,
              title: "My Statistics",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StatsScreen()));
              },
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}
