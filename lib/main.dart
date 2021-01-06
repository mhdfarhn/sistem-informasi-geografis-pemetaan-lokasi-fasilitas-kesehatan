import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MapScreen()));
}
