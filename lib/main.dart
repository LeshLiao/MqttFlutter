import 'package:flutter/material.dart';
import 'MQTTClientWrapper.dart';
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
  String mqttMessage = '';

  final MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();

  @override
  void initState() {
    super.initState();
    futureCards = ApiService.fetchCards();
    mqttClientWrapper.onMessageReceived = (String message) {
      setState(() {
        mqttMessage = message;
      });
    };
    mqttClientWrapper.prepareMqttClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder<List<CardModel>>(
              future: futureCards,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<CardModel>? cards = snapshot.data;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: SizedBox(
                            width: 80, // Set the desired fixed width for "Create Time"
                            child: Text('Create Time', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100, // Set the desired fixed width for "Card ID"
                            child: Text('Card ID', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        DataColumn(label: Text('Card Data', style: TextStyle(fontSize: 12))),
                      ],
                      rows: cards!.map((card) {
                        return DataRow(cells: [
                          DataCell(
                            SizedBox(
                              width: 80, // Set the same fixed width for the cell
                              child: Text(card.formattedCreatedAt, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 100, // Set the same fixed width for the cell
                              child: Text(card.cardId, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                          DataCell(Text(card.cardData, style: const TextStyle(fontSize: 12))),
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
            const SizedBox(height: 20),
            Text('MQTT Message: $mqttMessage', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
