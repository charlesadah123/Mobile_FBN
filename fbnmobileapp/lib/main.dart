import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class MyPosition {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
  final double altitudeAccuracy;
  final double altitude;
  final double headingAccuracy;
  final double speed;
  final double speedAccuracy;
  final double heading;

  MyPosition({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
    required this.altitudeAccuracy,
    required this.altitude,
    required this.headingAccuracy,
    required this.speed,
    required this.speedAccuracy,
    required this.heading,
  });
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentAddress = 'My Address';
  late MyPosition currentposition;

  Future<MyPosition> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentposition = MyPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(), // Removed the 'const' keyword
          accuracy: position.accuracy,
          altitudeAccuracy: position.altitudeAccuracy,
          altitude: position.altitude,
          headingAccuracy: position.headingAccuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          heading: position.heading,
        );
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }

    // Adding a default return statement
    return MyPosition(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitudeAccuracy: 0.0,
      altitude: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      heading: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Location'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(currentAddress),
            currentposition != null
                ? Text('Latitude = ' + currentposition.latitude.toString())
                : Container(),
            currentposition != null
                ? Text('Longitude = ' + currentposition.longitude.toString())
                : Container(),
            TextButton(
              onPressed: () {
                _determinePosition();
              },
              child: Text('Locate me'),
            ),
          ],
        ),
      ),
    );
  }
}
