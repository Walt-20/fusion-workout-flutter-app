import 'package:http/http.dart' as http;
import 'dart:convert';

class FatSecretAPI {
  static const String baseURL =
      'https://platform.fatsecret.com/rest/server.api';
  static const String clientId = '634f2a4e10fd47f09ad31ae5db02b67f';
  static const String clientSecret = '8ea8f9f27a0c47d7b3bd64e5691272b0 ';

  static Future<List<dynamic>> searchFoods(String query) async {
    String method = 'foods.search';

    Map<String, String> parameters = {
      'method': method,
      'oauth_consumer_key': clientId,
      'format': 'json',
      'search_expression': query,
    };

    Uri uri = Uri.parse(baseURL + '?' + _buildQueryString(parameters));
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['foods']
          ['food']; // Assuming 'food' is an array of search results
    } else {
      throw Exception('Failed to load search results');
    }
  }

  static String _buildQueryString(Map<String, String> parameters) {
    return parameters.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
