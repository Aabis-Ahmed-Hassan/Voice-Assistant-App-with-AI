import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key.dart';

class GemeniServices {
  static List<Map<String, dynamic>> messages = [];

  Future<String> isImage(String prompt) async {
    String response = '';
    try {
      http.Response res = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$gemeniApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        'Is the user demanding an Image in this prompt or not? Please answer only in a yes or a no. \n $prompt'
                  }
                ]
              }
            ],
          },
        ),
      );

      if (res.statusCode == 200) {
        String gemeniResponse = jsonDecode(res.body)['candidates'][0]['content']
                ['parts'][0]['text']
            .toString();

        messages.add({
          'parts': [
            {'text': prompt}
          ],
          'role': 'user',
        });

        if (gemeniResponse.toLowerCase().contains('yes')) {
          response = 'Sorry, I can\'t generate images. ';
        } else {
          response = await getTextResponse(prompt);
        }
        messages.add({
          'parts': [
            {'text': response}
          ],
          'role': 'model',
        });
      }
      return response;
    } catch (e) {
      print('Exception: $e');
      return 'An Internal Error Occurred';
    }
  }

  Future<String> getTextResponse(String prompt) async {
    try {
      http.Response res = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$gemeniApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ],
                'role': 'user',
              },
              ...messages
            ],
          },
        ),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['candidates'][0]['content']['parts'][0]
                ['text']
            .toString();
      }
      return 'An Internal Error Occurred';
    } catch (e) {
      print('Exception: $e');
      return 'An Internal Error Occurred';
    }
  }

  // Future<String> getImageResponse(String prompt) async {
  //   try {
  //     http.Response res = await http.post(
  //       Uri.parse('https://gemini.google.com//v1/generate_image'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $gemeniApiKey'
  //       },
  //       // body: jsonEncode(
  //       //   {
  //       //     'contents': [
  //       //       {
  //       //         'parts': [
  //       //           {'text': 'Create an image for this format $prompt'}
  //       //         ]
  //       //       }
  //       //     ],
  //       //   },
  //       // ),
  //       body: jsonEncode({
  //         'prompt': prompt,
  //       }),
  //     );
  //
  //     if (res.statusCode == 200) {
  //       print('status code 200');
  //       return jsonDecode(res.body)['candidates'][0]['content']['parts'][0]
  //               ['text']
  //           .toString();
  //     }
  //     print(res.statusCode);
  //     return 'An Internal Error Occurred';
  //   } catch (e) {
  //     print('Exception: $e');
  //     return 'An Internal Error Occurred';
  //   }
  // }
}
