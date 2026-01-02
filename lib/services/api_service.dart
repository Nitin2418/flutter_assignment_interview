import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/test_metadata.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

class DataException implements Exception {
  final String message;
  DataException(this.message);
  
  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://nd-assignment.azurewebsites.net/api/get-ranges';
  static const String bearerToken = 'eb3dae0a10614a7e719277e07e268b12aeb3af6d7a4655472608451b321f5a95';
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<TestMetadata> fetchTestMetadata() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException('Request timed out. Please check your internet connection and try again.');
        },
      );

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          
          if (jsonData == null) {
            throw DataException('Received empty response from server');
          }
          
          final metadata = TestMetadata.fromJson(jsonData);
          
          if (metadata.ranges.isEmpty) {
            throw DataException('No ranges found in the response');
          }
          
          for (var i = 0; i < metadata.ranges.length; i++) {
            final range = metadata.ranges[i];
            
            if (range.min >= range.max) {
              throw DataException('Invalid range: min (${range.min}) must be less than max (${range.max})');
            }
            if (range.label.isEmpty) {
              throw DataException('Range missing label');
            }
          }
          
          return metadata;
        } on FormatException catch (e) {
          throw DataException('Invalid JSON format: ${e.message}');
        } catch (e) {
          if (e is DataException) {
            rethrow;
          }
          throw DataException('Failed to parse response: ${e.toString()}');
        }
      } else if (response.statusCode == 401) {
        throw ApiException('Authentication failed. Please check your credentials.', 401);
      } else if (response.statusCode == 403) {
        throw ApiException('Access forbidden. You may not have permission to access this resource.', 403);
      } else if (response.statusCode == 404) {
        throw ApiException('Resource not found. The API endpoint may have changed.', 404);
      } else if (response.statusCode >= 500) {
        throw ApiException('Server error (${response.statusCode}). Please try again later.', response.statusCode);
      } else {
        throw ApiException('Failed to load data. Status code: ${response.statusCode}', response.statusCode);
      }
    } on TimeoutException {
      rethrow;
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}. Please check your internet connection.');
    } on SocketException {
      throw NetworkException('Unable to connect to the server. Please check your internet connection.');
    } catch (e) {
      if (e is ApiException || e is NetworkException || e is TimeoutException || e is DataException) {
        rethrow;
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }
}

