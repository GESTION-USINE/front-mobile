import 'package:flutter/material.dart';

class StatisticsInventoryContent extends StatelessWidget {
  const StatisticsInventoryContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventaire')),
      body: const Center(
        child: Text('Page Inventaire'),
      ),
    );
  }
}
