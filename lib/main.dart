import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

const kBaseUrl = 'http://127.0.0.1:8000/api';

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
