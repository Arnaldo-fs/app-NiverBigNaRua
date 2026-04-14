import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/notification_service.dart';
import 'services/work_manager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  WorkManagerService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}