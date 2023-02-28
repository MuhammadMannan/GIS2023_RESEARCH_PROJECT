import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'view_plants.dart';

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
    _getCurrentLocation();
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Permission has been granted, get current location
      try {
        final position = await Geolocator.getCurrentPosition();
        return position;
      } catch (e) {
        return Future.error('Error getting current position: $e');
      }
    }

    // Permission is still being requested, wait for a short delay and try again
    //await Future.delayed(Duration(milliseconds: 500));
    return _getCurrentLocation();
  }

  /* Future<void> _getCurrentLocation() async {
    final position = await _determinePosition();
    setState(() {
      _latitude = position.latitude.toDouble();
      _longitude = position.longitude.toDouble();
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission dennied');
      }
    }

    return await Geolocator.getCurrentPosition();
  } */

  @override
  void dispose() {
    _speciesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              FutureBuilder<Position>(
                future: _getCurrentLocation(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final Position position = snapshot.data!;
                    return Stack(
                      children: [
                        Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Column(
                          children: [
                            Center(
                                child:
                                    Text('\nLatitude: ${position.latitude}')),
                            Center(
                                child:
                                    Text('Longitude: ${position.longitude}')),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  } else {
                    return Stack(
                      children: [
                        Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
                },
              ),

              /* Center(
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
              ), */
              /* Center(child: Text('Latitude: $_latitude')),
              Center(child: Text('Longitude: $_longitude')), */
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ViewPlants()),
                      );
                    },
                    child: Text('Submit Data'),
                  ),
                ),
              ),
              /* Center(
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ViewPlants()),
                          );
                        },
                        child: Text('View Plants'),
                      ))) */
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: SizedBox.shrink(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewPlants()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ViewPlants()),
          );
        },
        child: Icon(Icons.list),
      ),
    );
  }
}
