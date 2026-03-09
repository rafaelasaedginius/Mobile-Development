import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red[600],
            title: const Text('My first App'),
            centerTitle: true,
          ), //AppBar
          body: Center(
              child: Text(
                'hello ninjas!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.grey[600],
                  fontFamily: 'IndieFlower'
                ), //TextStyle
              ) //Text
          ), //Center
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.red[600],
            child: Text('click'),
          ) //FloatingActionButton
      ) //Scaffold
  )); //MaterialApp
}