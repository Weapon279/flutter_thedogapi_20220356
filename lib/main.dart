import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El perro de Weapon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DogScreen(),
    );
  }
}

class DogScreen extends StatefulWidget {
  const DogScreen({Key? key}) : super(key: key);

  @override
  _DogScreenState createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  String _searchQuery = '';
  String _dogImageUrl = '';
  final String _apiKey =
      'live_BD9nXIFHO6IzpObs0UWzlXh5qibffr1KOafu64U9I8pzzCn64GnIUfmyjCxzJqWd';

  Future<void> _fetchDogImage(String breedName) async {
    final response = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$breedName'),
      headers: {'x-api-key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final breedId = data[0]['id'];
        final breedResponse = await http.get(
          Uri.parse(
              'https://api.thedogapi.com/v1/images/search?breed_id=$breedId'),
          headers: {'x-api-key': _apiKey},
        );
        if (breedResponse.statusCode == 200) {
          final List<dynamic> breedData = jsonDecode(breedResponse.body);
          if (breedData.isNotEmpty) {
            setState(() {
              _dogImageUrl = breedData[0]['url'];
            });
            return;
          }
        }
      }
    } else {
      throw Exception('Fallo la carga de la imagen');
    }
  }

  FutureBuilder _buildDogImage(BuildContext context) {
    return FutureBuilder(
      future: _fetchDogImage(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Image.network(_dogImageUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar raza de perro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Enter a dog breed'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _fetchDogImage(_searchQuery);
              },
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 16),
            _buildDogImage(context),
          ],
        ),
      ),
    );
  }
}
