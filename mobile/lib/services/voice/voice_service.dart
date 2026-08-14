import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class VoiceService {
  final Dio _dio;
  final String _baseUrl;

  VoiceService({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? 'http://10.0.2.2:8000';

  /// Generate a preview sample for voice selection
  Future<String> generatePreview({
    required String language,
    required String voiceGender,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/tts/preview',
        data: {
          'language': language,
          'voice_gender': voiceGender,
        },
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['audio_base64'] as String? ?? '';
      } else {
        throw Exception('Preview generation failed: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      developer.log(
        'DioException in generatePreview',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(_formatDioError(e));
    } catch (e, stackTrace) {
      developer.log(
        'Error in generatePreview',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to generate preview: $e');
    }
  }

  /// Synthesize speech for normal Vexa usage
  Future<String> synthesize({
    required String text,
    required String language,
    required String voiceGender,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/tts/synthesize',
        data: {
          'text': text,
          'language': _mapLanguageCode(language),
          'voice_gender': voiceGender,
        },
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['audio_base64'] as String? ?? '';
      } else {
        throw Exception('Synthesis failed: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      developer.log(
        'DioException in synthesize',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(_formatDioError(e));
    } catch (e, stackTrace) {
      developer.log(
        'Error in synthesize',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to synthesize speech: $e');
    }
  }

  String _mapLanguageCode(String language) {
    switch (language) {
      case 'hi':
        return 'hi-IN';
      case 'fr':
        return 'fr-FR';
      case 'es':
        return 'es-ES';
      case 'de':
        return 'de-DE';
      case 'en':
      default:
        return 'en-US';
    }
  }

  String _formatDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to TTS service. Please check if the server is running.';
    } else if (e.response != null) {
      return 'TTS service error: ${e.response?.statusCode}';
    }
    return 'Network error: ${e.message}';
  }
}