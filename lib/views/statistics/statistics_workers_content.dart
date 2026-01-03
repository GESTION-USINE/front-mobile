import 'package:flutter/material.dart';

class StatisticsWorkersContent extends StatelessWidget {
  const StatisticsWorkersContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travailleurs')),
      body: const Center(
        child: Text('Page Travailleurs'),
      ),
    );
  }
}
