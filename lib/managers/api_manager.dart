import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'logger_manager.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  final LoggerManager _logger = LoggerManager();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET Request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      _logger.info('GET: $url');

      // Allow GET requests to take as long as needed (backend may be slow).
      final response = await http.get(url, headers: _headers);

      return _handleResponse(response);
    } catch (e) {
      _logger.error('GET Error: $endpoint', e);
      rethrow;
    }
  }

  // POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      _logger.info('POST: $url');
      _logger.debug('Body: ${json.encode(body)}');

      final response = await http
          .post(url, headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _logger.error('POST Error: $endpoint', e);
      rethrow;
    }
  }

  // PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      _logger.info('PUT: $url');
      _logger.debug('Body: ${json.encode(body)}');

      final response = await http
          .put(url, headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _logger.error('PUT Error: $endpoint', e);
      rethrow;
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      _logger.info('DELETE: $url');

      final response = await http
          .delete(url, headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _logger.error('DELETE Error: $endpoint', e);
      rethrow;
    }
  }

  // Handle Response
  dynamic _handleResponse(http.Response response) {
    _logger.info('Response Status: ${response.statusCode}');
    _logger.debug('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return true;
      }

      try {
        return json.decode(response.body);
      } catch (e) {
        // If response is just "true" or other non-JSON
        if (response.body.trim().toLowerCase() == 'true') {
          return true;
        }
        return response.body;
      }
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode == 400) {
      throw Exception('Bad request: ${response.body}');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later');
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}
