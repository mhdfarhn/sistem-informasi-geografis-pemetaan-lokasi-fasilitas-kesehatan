import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:user_location/user_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  StreamController<LatLng> markerlocationStream = StreamController();
  List<Marker> markers = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  onTapFAB() {
    userLocationOptions.updateMapLocationOnPositionChange = false;
  }

  onMarkerPressed(String name, String address, String phone) {
    showModalBottomSheet(
      context: (context),
      builder: (context) {
        return Container(
          height: 215,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                ),
                title: Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                ),
                title: Text(
                  address,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.blue,
                ),
                title: Text(
                  phone,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget loadMap() {
    return StreamBuilder(
      stream: firestore.collection('locations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text('Loading Map.. Please Wait!');
        for (int i = 0; i < snapshot.data.documents.length; i++) {
          markers.add(
            Marker(
              height: 40,
              width: 40,
              point: LatLng(
                snapshot.data.documents[i]['coordinate'].latitude,
                snapshot.data.documents[i]['coordinate'].longitude,
              ),
              anchorPos: AnchorPos.exactly(Anchor(20, 20)),
              builder: (context) => Container(
                child: IconButton(
                  icon: Icon(Icons.local_hospital),
                  color: Colors.red,
                  iconSize: 20,
                  onPressed: () {
                    print(snapshot.data.documents[i]['name']);
                    onMarkerPressed(
                      snapshot.data.documents[i]['name'],
                      snapshot.data.documents[i]['address'],
                      snapshot.data.documents[i]['phone'],
                    );
                  },
                ),
              ),
            ),
          );
        }
        return FlutterMap(
          options: MapOptions(
            center: LatLng(4.4683, 97.9683),
            zoom: 12,
            minZoom: 3,
            maxZoom: 18,
            plugins: [UserLocationPlugin()],
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(markers: markers),
            userLocationOptions,
          ],
          mapController: mapController,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: markers,
      onTapFAB: onTapFAB,
      updateMapLocationOnPositionChange: false,
    );

    return Scaffold(
        appBar: AppBar(title: Text('SIGPL Fasilitas Kesehatan')),
        body: loadMap());
  }

  @override
  void dispose() {
    super.dispose();
    markerlocationStream.close();
  }
}
