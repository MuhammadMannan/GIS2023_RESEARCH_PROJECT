import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gis_app/add_plant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

class ViewPlants extends StatefulWidget {
  const ViewPlants({super.key});

  @override
  State<ViewPlants> createState() => _MyViewPlants();
}

class _MyViewPlants extends State<ViewPlants> {
  CollectionReference plants = FirebaseFirestore.instance.collection('plants');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Species Information"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: plants.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final document = documents[index];
              final date = (document['date'] as Timestamp).toDate();
              final formattedDate = DateFormat.yMd().format(date);
              final double latitude = document['latitude'];
              final double longitude = document['longitude'];
              return ListTile(
                title: Text(document['plant name']),
                subtitle: Text(document['description']),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formattedDate),
                    Text('Lat: $latitude, Long: $longitude'),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlant()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
