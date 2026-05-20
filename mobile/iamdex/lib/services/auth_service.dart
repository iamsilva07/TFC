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

    static Future<bool> updateProfile({String? name, String? currentPassword, String? newPassword}) async {
        final token = await getToken();
        final response = await http.put(
            Uri.parse('${Constants.baseUrl}/auth/profile'),
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
                if (name != null) 'name': name,
                if (currentPassword != null) 'current_password': currentPassword,
                if (newPassword != null) 'new_password': newPassword,
            }),
        );
        return response.statusCode == 200;
    }

    static Future<void> saveName(String name) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
    }

    static Future<String> getName() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('name') ?? 'Usuario';
    }
    
}