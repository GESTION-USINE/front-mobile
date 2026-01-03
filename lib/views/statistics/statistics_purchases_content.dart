import 'package:flutter/material.dart';

class StatisticsPurchasesContent extends StatelessWidget {
  const StatisticsPurchasesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achats')),
      body: const Center(
        child: Text('Page Achats'),
      ),
    );
  }
}
