import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
  String temperature = '';
  String humidity = '';

  final MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();

  @override
  void initState() {
    super.initState();
    futureCards = ApiService.fetchCards();
    mqttClientWrapper.onMessageReceived = (String message) {
      setState(() {
        mqttMessage = message;
        _parseMqttMessage(mqttMessage);
      });
    };
    mqttClientWrapper.prepareMqttClient();
  }

  void _parseMqttMessage(String message) {
    final regex = RegExp(r'Temperature:\s(\d+)\sC,\sHumidity:\s(\d+)\s%');
    final match = regex.firstMatch(message);
    if (match != null) {
      setState(() {
        temperature = match.group(1) ?? '';
        humidity = match.group(2) ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double temperatureValue = 0.0;
    double humidityValue = 0.0;
    try {
      temperatureValue = double.parse(temperature);
    } catch (e) {
      // Handle the case where temperature is not a valid double
      temperatureValue = 0.0;
    }
    try {
      humidityValue = double.parse(humidity);
    } catch (e) {
      // Handle the case where humidity is not a valid double
      humidityValue = 0.0;
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('RFID Card', style: TextStyle(fontSize: 20)),
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
            Text('MQTT Temperature', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 13.0,
              animation: false,
              percent: temperatureValue / 100,
              center: Text(
                '$temperatureValue°C',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.purple,
            ),
            const SizedBox(height: 10),
            Text('MQTT Humidity', style: TextStyle(fontSize: 18)),
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 13.0,
              animation: false,
              percent: humidityValue / 100,
              center: Text(
                '$humidityValue%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
