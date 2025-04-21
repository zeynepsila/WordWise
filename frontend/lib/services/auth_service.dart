import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // emülatör için
  // static const String baseUrl = 'http://192.168.x.x:8000'; // gerçek cihazda

  static Future<Map<String, dynamic>> login(String username, String password) async {
    print("Login is starting...");

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    return json.decode(response.body);
  }



  static Future<Map<String, dynamic>> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    return json.decode(response.body);
  }
}
