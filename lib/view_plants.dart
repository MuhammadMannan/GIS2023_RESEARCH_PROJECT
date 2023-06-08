import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gis_app/add_plant.dart';
import 'plant_details.dart';
import 'package:intl/intl.dart';

class ViewPlants extends StatefulWidget {
  const ViewPlants({super.key});

  @override
  State<ViewPlants> createState() => _MyViewPlants();
}

class _MyViewPlants extends State<ViewPlants> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  CollectionReference plants = FirebaseFirestore.instance.collection('plants');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase();
            });
          },
          decoration: const InputDecoration(
            hintText: "Search Plants",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        //title: Text("Species Information"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        //stream: plants.snapshots(),
        stream: plants.orderBy('date', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          List<DocumentSnapshot> filteredDocuments = documents;
          if (_searchQuery.isNotEmpty) {
            filteredDocuments = documents
                .where((document) =>
                    document['plant name']
                        .toLowerCase()
                        .contains(_searchQuery) ||
                    document['description']
                        .toLowerCase()
                        .contains(_searchQuery))
                .toList();
          }
          return ListView.builder(
            itemCount: filteredDocuments.length,
            itemBuilder: (BuildContext context, int index) {
              final document = filteredDocuments[index];
              final date = (document['date'] as Timestamp).toDate();
              final formattedDate = DateFormat.yMd().format(date);
              final double latitude = document['latitude'];
              final double longitude = document['longitude'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetails(document: document),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(document['plant name']),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Diameter: ${document['diameter'].toString()}  Height: ${document['height'].toString()}'),
                      Text('Description: ${document['description']}')
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formattedDate),
                      Text('Lat: $latitude,\nLong: $longitude'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlant()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
