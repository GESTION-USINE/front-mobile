import 'package:flutter/material.dart';

class StatisticsSalesContent extends StatelessWidget {
  const StatisticsSalesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventes')),
      body: const Center(
        child: Text('Page Ventes'),
      ),
    );
  }
}
