import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PlantDetails extends StatelessWidget {
  final DocumentSnapshot document;

  const PlantDetails({required this.document});

  @override
  Widget build(BuildContext context) {
    final date = (document['date'] as Timestamp).toDate();
    final formattedDate = DateFormat.yMd().format(date);
    final double latitude = document['latitude'];
    final double longitude = document['longitude'];

    return Scaffold(
      appBar: AppBar(
        title: Text(document['plant name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document['description'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Date: $formattedDate',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Location: Lat: $latitude, Long: $longitude',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
