# Translator
The code below is responsible for translation:
```dart
class Translator {
  static Future<String> translate(String str, String targetLanguage, String baseUrl) async {
    final url = Uri.parse('$baseUrl/translate/anything/auto/$targetLanguage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': str}),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['text'] ?? '';
    } else {
      throw Exception('Failed to translate text: ${response.statusCode}');
    }
  }
}
```

`$baseUrl` is derived from app settings. You can change base URL and target language in **advanced config** (**Settings** > **About** > **Advanced config**). If target language is left blank, interface language will be used as target language.

Message translations are not available in encrypted rooms for security measures.

## API
This part is useful, if you want to implement your own translation back-end.

### `POST` /translate/:engine/:sourceLanguage/:targetLanguage
Although `engine` and `sourceLanguage` parameters aren't configurable yet, this may change in future.

#### Path params
- **engine**. `ecs.extera.xyz` back-end does not support this anymore, but available engines were: `google`, `deepl` and `neural` (translations using LLMs).
- **sourceLanguage**. Translation source language. Client app always passes `auto`.
- **targetLanguage**. Translation target language. This can't be `auto`.

#### Body params
Request body must be a JSON, with applicable `Content-Type` header (`application/json`).

- **text**. This is the only body parameter, which contains the text to translate.

#### Response
If OK, the server must return HTTP status-code 200 and a JSON response body:
```json
{"text":"Translated text"}
```

If an error has occured, the server must return HTTP status-code 500 and JSON response body in following format:
```json
{
    "error": {
        "error": "Human readable error message"
    }
}
```

*Please note that Extera does not show error messages yet :)*