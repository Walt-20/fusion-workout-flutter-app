import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';
import 'package:http/http.dart' as http;

class SearchFoodPage extends StatefulWidget {
  const SearchFoodPage({super.key});

  @override
  State<SearchFoodPage> createState() => _SearchFoodPageState();
}

Future<List<Food>> fetchSuggestions(String query) async {
  debugPrint("What is the query? $query");
  final url = Uri.parse('http://10.0.2.2:3000/search-food');

  try {
    final request = await http.get(
      Uri.parse('$url?searchExpression=$query'),
    );

    debugPrint("what is the status code? ${request.statusCode}");

    if (request.statusCode == 200) {
      debugPrint("is the status code correct? ");
      debugPrint("RAW JSON Response: ${request.body}");

      List<dynamic> jsonData = json.decode(request.body);
      debugPrint("Parsed JSON data: $jsonData");

      final foodList = jsonData.map((json) => Food.fromJson(json)).toList();
      debugPrint("The food at position 0 is ${foodList[0].foodName}");
      return foodList;
    } else {
      debugPrint("what");
      throw Exception('Failed to load foods');
    }
  } catch (e) {
    throw Exception('OAuth Token has expired. Signout and log back in. ');
  }
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Foods')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor.bar(
              suggestionsBuilder: (context, controller) {
                final searchFuture = fetchSuggestions(controller.text);
                return [
                  FutureBuilder<List<Food>>(
                    future: searchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No results found');
                      } else {
                        final list = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(list[index].foodName),
                              subtitle: Text(list[index].foodDescription),
                              onTap: () {
                                setState(() {});
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}
