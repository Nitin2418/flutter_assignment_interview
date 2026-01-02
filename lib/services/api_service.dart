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
    print('[API] ========================================');
    print('[API] Starting API request to: $baseUrl');
    print('[API] Timeout: ${timeoutDuration.inSeconds}s');
    final startTime = DateTime.now();
    
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
          final elapsed = DateTime.now().difference(startTime);
          print('[API] ❌ Request timed out after ${elapsed.inSeconds}s');
          throw TimeoutException('Request timed out. Please check your internet connection and try again.');
        },
      );
      
      final elapsed = DateTime.now().difference(startTime);
      print('[API] Response received in ${elapsed.inMilliseconds}ms');
      print('[API] Status Code: ${response.statusCode}');
      print('[API] Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('[API] ✅ Success! Parsing response...');
        print('[API] Response Body Length: ${response.body.length} bytes');
        try {
          final jsonData = json.decode(response.body);
          print('[API] JSON parsed successfully');
          print('[API] JSON Data Type: ${jsonData.runtimeType}');
          
          if (jsonData == null) {
            print('[API] ❌ Error: Empty response from server');
            throw DataException('Received empty response from server');
          }
          
          final metadata = TestMetadata.fromJson(jsonData);
          print('[API] TestMetadata created successfully');
          
          if (metadata.ranges.isEmpty) {
            print('[API] ❌ Error: No ranges found in response');
            throw DataException('No ranges found in the response');
          }
          
          print('[API] Found ${metadata.ranges.length} ranges:');
          for (var i = 0; i < metadata.ranges.length; i++) {
            final range = metadata.ranges[i];
            print('[API]   Range $i: ${range.min}-${range.max} (${range.label}) - Color: ${range.colorHex}');
            
            if (range.min >= range.max) {
              print('[API] ❌ Error: Invalid range $i - min >= max');
              throw DataException('Invalid range: min (${range.min}) must be less than max (${range.max})');
            }
            if (range.label.isEmpty) {
              print('[API] ❌ Error: Range $i missing label');
              throw DataException('Range missing label');
            }
          }
          
          print('[API] ✅ All ranges validated successfully');
          print('[API] Min Value: ${metadata.minimumValue}, Max Value: ${metadata.maximumValue}');
          print('[API] ========================================');
          return metadata;
        } on FormatException catch (e) {
          print('[API] ❌ JSON Parse Error: ${e.message}');
          print('[API] Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
          throw DataException('Invalid JSON format: ${e.message}');
        } catch (e) {
          if (e is DataException) {
            print('[API] ❌ Data Validation Error: ${e.message}');
            rethrow;
          }
          print('[API] ❌ Parse Error: ${e.toString()}');
          throw DataException('Failed to parse response: ${e.toString()}');
        }
      } else if (response.statusCode == 401) {
        print('[API] ❌ Authentication failed (401)');
        throw ApiException('Authentication failed. Please check your credentials.', 401);
      } else if (response.statusCode == 403) {
        print('[API] ❌ Access forbidden (403)');
        throw ApiException('Access forbidden. You may not have permission to access this resource.', 403);
      } else if (response.statusCode == 404) {
        print('[API] ❌ Resource not found (404)');
        throw ApiException('Resource not found. The API endpoint may have changed.', 404);
      } else if (response.statusCode >= 500) {
        print('[API] ❌ Server error (${response.statusCode})');
        throw ApiException('Server error (${response.statusCode}). Please try again later.', response.statusCode);
      } else {
        print('[API] ❌ Unexpected status code: ${response.statusCode}');
        print('[API] Response body: ${response.body}');
        throw ApiException('Failed to load data. Status code: ${response.statusCode}', response.statusCode);
      }
    } on TimeoutException catch (e) {
      print('[API] ❌ Timeout Exception: ${e.message}');
      print('[API] ========================================');
      rethrow;
    } on http.ClientException catch (e) {
      print('[API] ❌ Client Exception: ${e.message}');
      print('[API] ========================================');
      throw NetworkException('Network error: ${e.message}. Please check your internet connection.');
    } on SocketException catch (e) {
      print('[API] ❌ Socket Exception: ${e.message}');
      print('[API] ========================================');
      throw NetworkException('Unable to connect to the server. Please check your internet connection.');
    } catch (e) {
      print('[API] ❌ Unexpected Error: ${e.toString()}');
      print('[API] Error Type: ${e.runtimeType}');
      print('[API] ========================================');
      if (e is ApiException || e is NetworkException || e is TimeoutException || e is DataException) {
        rethrow;
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }
}

