import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

class AddPlant extends StatefulWidget {
  const AddPlant({super.key});

  @override
  // ignore: library_private_types_in_public_api
  State<AddPlant> createState() => _MyAddPlant();
}

class _MyAddPlant extends State<AddPlant> {
  CollectionReference plants = FirebaseFirestore.instance.collection('plants');

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;

  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Species Information"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _speciesController,
                decoration: InputDecoration(
                  labelText: 'Name of Species',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the species';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _getCurrentLocation();
                      }
                    },
                    child: Text('Get Location'),
                  ),
                ),
              ),
              Center(child: Text('Latitude: $_latitude')),
              Center(child: Text('Longitude: $_longitude')),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final String name = _speciesController.text;
                        final String description = _descriptionController.text;
                        plants
                            .add({
                              'description': description,
                              'latitude': _latitude,
                              'longitude': _longitude,
                              'plant name': name,
                              'date': _date
                            })
                            .then((value) => print('user entered data'))
                            .catchError((error) =>
                                print('Error adding document: $error'));
                      }
                    },
                    child: Text('Submit Data'),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: plants.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
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
                            ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
