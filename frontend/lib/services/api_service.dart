import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> startGame(String level) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/start-game'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'level': level},
    );

    print("Start Game Status: ${response.statusCode}");
    print("Start Game Body: ${response.body}");
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getGameStatus(int gameId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/game-status/$gameId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> guess(int gameId, String letter) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/guess'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'game_id': gameId.toString(),
        'letter': letter,
      },
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getStats() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/my-stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getGames() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/my-games'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getGuesses(int gameId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/guesses/$gameId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }
}
