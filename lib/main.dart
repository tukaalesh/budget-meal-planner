import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
//10.0.2.2
const kBaseUrl = 'http://10.0.2.2:8000/api';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const App());
}
