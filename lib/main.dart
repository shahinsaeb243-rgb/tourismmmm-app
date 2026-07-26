import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HamsafarApp());
}

class HamsafarApp extends StatelessWidget {
  const HamsafarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'همسفر من',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      // راست‌چین کردن کل اپ برای زبان فارسی
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Vazir', // فونت فارسی - راهنمای نصب در README
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const HomeScreen(),
    );
  }
}
