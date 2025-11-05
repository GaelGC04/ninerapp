import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailService {
  EmailService._();
  static final EmailService instance = EmailService._();

  static const String _apiEndpoint = 'https://api.sendgrid.com/v3/mail/send'; 
  static const String _senderEmail = 'garciajorgecf@gmail.com';

  Future<bool> sendEmail({required String recipientEmail, required String subject, required String bodyHtml}) async {
    try {
      await dotenv.load(fileName: ".env");
      final String? emailApiKey = dotenv.env['EMAIL_API_KEY'];

      if (emailApiKey != null && emailApiKey.isNotEmpty) {
        final Dio dio = Dio();
        
        Map<String, dynamic> data = {
          'personalizations': [
            {
              'to':[
                {'email': recipientEmail}
              ],
              'subject': subject,
            }
          ],
          'from': {
            'email': _senderEmail,
            'name': 'NiñerApp Soporte',
          },
          'content': [
            {
              'type': 'text/html',
              'value': bodyHtml,
            }
          ],
        };

        final response = await dio.post(
          _apiEndpoint,
          data: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $emailApiKey',
              'Content-Type': 'application/json',
            },
            responseType: ResponseType.json,
          ),
        );
        
        if (response.statusCode == 200 || response.statusCode == 202) {
          return true;
        } else {
          return false;
        }
      } 
      else {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: recipientEmail,
          query: encodeQueryParameters(<String, String>{
            'subject': subject,
            'body': bodyHtml.replaceAll(RegExp(r'<[^>]*>'), ''), 
          }),
        );
        
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
          return true; 
        } else {
          return false;
        }
      }
      
    } on DioException catch (e) {
      debugPrint('Error de red o API al enviar correo: ${e.response?.statusCode} | ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado al enviar correo: $e');
      return false;
    }
  }
  
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
  }
}