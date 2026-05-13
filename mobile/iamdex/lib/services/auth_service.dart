import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
    static Future<Map<String, dynamic>> register(String name, String email, String password) async {
        final response = await http.post(
            Uri.parse('${Constants.baseUrl}/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
                'name': name,
                'email': email,
                'password': password
            }),
        );
        print('Register response: ${response.statusCode} - ${response.body}');
        print('URL: ${Constants.baseUrl}/auth/register');
        return jsonDecode(response.body);
    }

    static Future<Map<String, dynamic>> login(String email, String password) async {
        final response = await http.post(
            Uri.parse('${Constants.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
                'email': email,
                'password': password
            }),
        );
        print('Login URL: ${Constants.baseUrl}/auth/login');
        print('Login response: ${response.statusCode} - ${response.body}');
        return jsonDecode(response.body);
    }

    static Future<void> saveToken(String token) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
    }

    static Future<String?> getToken() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('token');
    }

    static Future<void> logout() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
    }
}