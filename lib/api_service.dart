// api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'card_model.dart';

class ApiService {
  static const String apiUrl = 'https://mern-stack-website.onrender.com/api/workouts';

  static Future<List<CardModel>> fetchCards() async {
    final response = await http.get(Uri.parse(apiUrl));

    print("HI~~~~~~~~~~~~~~~~~~~~~~~");
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      // print(jsonResponse);
      return jsonResponse.map((card) => CardModel.fromJson(card)).toList();
    } else {
      print('Failed to load cards: ${response.body}');
      throw Exception('Failed to load cards');
    }
  }
}