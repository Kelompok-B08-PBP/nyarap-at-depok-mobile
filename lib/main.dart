import 'package:flutter/material.dart';
import 'package:nyarap_at_depok_mobile/home/home_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      }, child: MaterialApp(
      title: 'Nyarap at Depok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(secondary: Colors.deepPurple[400]),
        fontFamily: 'Montserrat', // Make sure to add this font in pubspec.yaml
      ),
      home: const HomePage(),
      )
    );
  }
}