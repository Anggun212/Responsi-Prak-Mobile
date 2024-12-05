import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  static const String routeName = '/main';

  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: const Center(
        child: Text('Welcome to Main Page'),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  static const String routeName = '/favorite';

  final List<dynamic> favorites;
  final List<dynamic> products;

  const FavoritePage({Key? key, required this.favorites, required this.products})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Page'),
      ),
      body: const Center(
        child: Text('Welcome to Favorite Page'),
      ),
    );
  }
}
