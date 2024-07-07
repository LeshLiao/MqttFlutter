// main.dart

import 'package:flutter/material.dart';
import 'card_model.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<CardModel>> futureCards;

  @override
  void initState() {
    super.initState();
    futureCards = ApiService.fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<CardModel>>(
          future: futureCards,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<CardModel>? cards = snapshot.data;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Create Time')),
                    DataColumn(label: Text('Card ID')),
                    DataColumn(label: Text('Card Data')),
                  ],
                  rows: cards!.map((card) {
                    return DataRow(cells: [
                      DataCell(Text(card.formattedCreatedAt)),
                      DataCell(Text(card.cardId)),
                      DataCell(Text(card.cardData)),
                    ]);
                  }).toList(),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
