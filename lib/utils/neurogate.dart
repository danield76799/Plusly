import 'dart:convert';

import 'package:extera_next/config/setting_keys.dart';
import 'package:extera_next/utils/custom_http_client.dart';
import 'package:matrix/matrix.dart';

class NeurogateTranslationResponse {
  final String translation;
  final String? reasoning;
  final String engine;

  const NeurogateTranslationResponse({
    required this.translation,
    required this.reasoning,
    required this.engine,
  });
}

class Neurogate {
  static Future<void> updateToken(Client client) async {
    final openIdToken = await client.requestOpenIdToken(client.userID!, {});

    final url = Uri.parse('${AppSettings.neurogateUrl.value}/v1/get_token');
    final http = CustomHttpClient.createHTTPClient();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'access_token': openIdToken.accessToken,
        'token_type': openIdToken.tokenType,
        'matrix_server_name': openIdToken.matrixServerName,
        'expires_in': openIdToken.expiresIn,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      AppSettings.neurogateToken.setItem(responseData['token']);
      AppSettings.neurogateTokenExpiry.setItem(responseData['expiresAt']);

      Logs().w("Successfully updated Neurogate token");
    } else {
      throw Exception('Failed to get neurogate token: ${response.statusCode}');
    }
  }

  static Future<NeurogateTranslationResponse> translateText(
    Client client,
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    if (AppSettings.neurogateTokenExpiry.value.isEmpty ||
        DateTime.parse(
              AppSettings.neurogateTokenExpiry.value,
            ).millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch) {
      // token expired, update it
      await updateToken(client);
    }

    final url = Uri.parse(
      '${AppSettings.neurogateUrl.value}/v1/translations/$sourceLanguage/$targetLanguage',
    );
    final http = CustomHttpClient.createHTTPClient();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${AppSettings.neurogateToken.value}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      return NeurogateTranslationResponse(
        translation: responseData['translation'],
        reasoning:
            responseData['reasoning'], // Sometimes, translation is powered by LLM with reasoning capabilities. In this case, reasoning content is exposed in translations API response.
        engine: responseData['engine'],
      );
    } else {
      throw Exception('Failed to translate text: ${response.statusCode}');
    }
  }
}
