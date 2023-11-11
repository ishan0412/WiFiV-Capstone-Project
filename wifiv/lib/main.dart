import 'package:flutter/material.dart';
import 'package:wifiv/home_page.dart';
// import 'custom_number_input.dart';
// import 'package:tcp_socket_connection/tcp_socket_connection.dart';
// import 'data_service.dart';
// import 'data_model.dart';

// /// TODO: Database storing each patient and pump along with their connection info (IP/port), medication, patient name, pump edit history, etc.
// ///
// const String controllerIP =
//     '192.168.224.182'; // will prob be dynamically obtained/updated
// const int controllerPort = 80; // will always be 80?
// const int connectionTimeout =
//     5000; // 5 seconds until app gives up connecting to microcontroller

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}
