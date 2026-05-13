import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';


class DocumentService{
    static Future<Map<String, String>> _headers() async{
        final token = await AuthService.getToken();
        return{
            'Content-Type':'application/json',
            'Authorization': 'Bearer $token',
        };
    }

    static Future<List<dynamic>> getDocuments() async{
        final headers = await _headers();
        final response = await http.get(
            Uri.parse('${Constants.baseUrl}/documents'),
            headers: headers,
        );
        return jsonDecode(response.body);
    }

    static Future<bool> uploadDocument() async{
        final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions:['pdf', 'txt', 'docx'],
        );

        if (result == null) return false;

        final file = result.files.first;
        final token = await AuthService.getToken();

        final request  = http. MultipartRequest(
            'POST',
            Uri.parse('${Constants.baseUrl}/documents/upload'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(await http.MultipartFile.fromPath('file', file.path!));

        final response = await request.send();
        return response.statusCode == 201;
    }
    
    static Future<bool> deleteDocument(int id) async{
        final headers = await _headers();
        final response = await http.delete(
            Uri.parse('${Constants.baseUrl}/documents/$id'),
            headers: headers,
        );
        print('Delete status: ${response.statusCode}');
        return response.statusCode == 204;
    }

    static Future<Map<String, dynamic>> chat(String question, {int? docId}) async{
        final headers = await _headers();
        final response = await http.post(
            Uri.parse('${Constants.baseUrl}/documents/chat'),
            headers: headers,
            body: jsonEncode({
                'question': question,
                if (docId != null) 'doc_id':docId,
            }),
        );
        return jsonDecode(response.body);
    }

    static Future <List<dynamic>> getChatHistory() async{
        final headers = await _headers();
        final response = await http.get(
            Uri.parse('${Constants.baseUrl}/documents/chat/history'),
            headers: headers,
        );
        return jsonDecode(response.body);
    }

    static Future<bool> deleteChatHistory() async{
        final headers = await _headers();
        final response = await http.delete(
            Uri.parse('${Constants.baseUrl}/documents/chat/history'),
            headers: headers,
        );
        return response.statusCode == 204;
    }

    static Future<bool> deleteChatMessage(int messageId) async {
        final headers = await _headers();
        final response = await http.delete(
            Uri.parse('${Constants.baseUrl}/documents/chat/history/$messageId'),
            headers: headers,
        );
        return response.statusCode == 204;
    }
    
    static Future<Map<String, dynamic>> getDocument(int id) async {
        final headers = await _headers();
        final response = await http.get(
            Uri.parse('${Constants.baseUrl}/documents/$id'),
            headers: headers,
        );
        print('Documents response: ${response.statusCode} - ${response.body}');
        return jsonDecode(response.body);
    }

}