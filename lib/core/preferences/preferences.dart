import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: AmiiboApp(),
  ));
}

class AmiiboApp extends StatefulWidget {
  const AmiiboApp({Key? key}) : super(key: key);

  @override
  State<AmiiboApp> createState() => _AmiiboAppState();
}

class _AmiiboAppState extends State<AmiiboApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? const AmiiboListPage() : const FavoritesPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

class AmiiboListPage extends StatefulWidget {
  const AmiiboListPage({Key? key}) : super(key: key);

  @override
  State<AmiiboListPage> createState() => _AmiiboListPageState();
}

class _AmiiboListPageState extends State<AmiiboListPage> {
  List<dynamic> amiiboList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAmiiboData();
  }

  Future<void> _fetchAmiiboData() async {
    try {
      final response =
          await http.get(Uri.parse('https://www.amiiboapi.com/api/amiibo'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          amiiboList = data['amiibo'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  void _toggleFavorite(String amiiboId) async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> favoriteAmiibos = prefs.getStringList('favorites')?.toSet() ?? {};

    if (favoriteAmiibos.contains(amiiboId)) {
      favoriteAmiibos.remove(amiiboId); // Remove from favorites
    } else {
      favoriteAmiibos.add(amiiboId); // Add to favorites
    }

    await prefs.setStringList('favorites', favoriteAmiibos.toList());
    setState(() {}); // Rebuild after updating favorites
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nintendo Amiibo List'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: amiiboList.length,
              itemBuilder: (context, index) {
                final amiibo = amiiboList[index];
                final amiiboId = amiibo['head'] + amiibo['tail']; // Combining unique ID
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(amiibo['image']),
                      radius: 30,
                    ),
                    title: Text(
                      amiibo['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Game Series: ${amiibo['gameSeries']}'),
                    trailing: FutureBuilder<bool>(
                      future: _isFavorite(amiiboId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return IconButton(
                          icon: Icon(
                            snapshot.data! ? Icons.favorite : Icons.favorite_border,
                            color: snapshot.data! ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            _toggleFavorite(amiiboId);
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<bool> _isFavorite(String amiiboId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    return favorites.contains(amiiboId);
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  Future<List<String>> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<String>>(
        future: _loadFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index]),
              );
            },
          );
        },
      ),
    );
  }
}
