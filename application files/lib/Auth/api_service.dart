import 'dart:convert';
import 'package:http/http.dart' as http;
// Import the http package

class ApiService {
  //  Change this to your actual backend URL
  final String baseUrl = 'http://localhost:8080/api';

  //  ---  User Authentication  ---

  Future<Map<String, dynamic>> registerUser(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/users/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  Future<String> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['token'];
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  //  ---  Document Operations  ---

  Future<List<dynamic>> getDocuments(String token, String userId) async {
    final url = Uri.parse('$baseUrl/documents/user/$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get documents: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> uploadDocument(
      String documentType,
      String documentName,
      String expiryDate,
      String token,
      String filePath) async {
    final url = Uri.parse('$baseUrl/documents/upload');
    var request = http.MultipartRequest('POST', url)
      ..fields['user_id'] = "1" //  Replace "1" with actual userId
      ..fields['document_type'] = documentType
      ..fields['document_name'] = documentName
      ..fields['expiry_date'] = expiryDate
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to upload document: $responseBody');
    }
  }

//  ...  Add other API calls as needed
}