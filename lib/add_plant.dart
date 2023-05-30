// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _getCurrentLocation() async {
    final position = await _determinePosition();
    setState(() {
      _latitude = position.latitude.toDouble();
      _longitude = position.longitude.toDouble();
    });
  }

  Future<void> _updateLocation() async {
    await _getCurrentLocation();
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission denied');
      }
    }

    return await Geolocator.getCurrentPosition();
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
      backgroundColor: const Color.fromARGB(255, 131, 227, 134),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 131, 227, 134),
        elevation: 0,
        title: const Text("Species Information"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateLocation,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color.fromARGB(255, 214, 255, 192)),
                child: TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                      labelText: 'Name of Species',
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of the species';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color.fromARGB(255, 214, 255, 192)),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),
              Center(
                child: Text(
                  '\nLatitude: $_latitude',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Center(
                child: Text(
                  'Longitude: $_longitude',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0, // Set elevation to 0 for a flat button
                    ),
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
                    child: const Text(
                      'Submit Data', style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 131, 227, 134),
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const SizedBox.shrink(),
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
        elevation: 0,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ViewPlants()),
          );
        },
        child: const Icon(
          Icons.list,
        ),
      ),
    );
  }
}
