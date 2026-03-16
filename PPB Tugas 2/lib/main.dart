import 'package:flutter/material.dart';

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
      home: const RowColumnPage(),
    );
  }
}

class RowColumnPage extends StatelessWidget {
  const RowColumnPage({super.key}); // Menggunakan sintaks modern super.key

  @override
  Widget build(BuildContext context) {
    // Menghapus mediaQueryData dan screenHeight yang tidak terpakai
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My First App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange[200],
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: screenWidth,
            height: screenWidth,
            margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
            padding: const EdgeInsets.all(20.0),
            color: Colors.lightBlue[100],
            child: Center(
              child: Image.network(
                'https://picsum.photos/200',
                fit: BoxFit.cover,
                width: 500,
              ),
            ),
          ),
          Container(
            width: screenWidth,
            margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
            padding: const EdgeInsets.all(20.0),
            color: Colors.pink[200],
            child: const Text('What image is that', style: TextStyle(fontSize: 16)),
          ),
          Container(
            width: screenWidth,
            color: Colors.yellow[200],
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(children: [Icon(Icons.food_bank), Text("Food")]),
                Column(children: [Icon(Icons.landscape), Text("Scenery")]),
                Column(children: [Icon(Icons.people), Text("People")]),
              ],
            ),
          ),
          const CounterCard(),
        ],
      ),
    );
  }
}

class CounterCard extends StatefulWidget {
  const CounterCard({super.key});

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
      padding: const EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width,
      color: Colors.cyan[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Counter here: $_counter", style: const TextStyle(fontSize: 16)),
          Container(
            color: Colors.cyan[200],
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.add, color: Colors.black, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}