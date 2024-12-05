import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(const MaterialApp(
    home: AmiiboApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class AmiiboApp extends StatefulWidget {
  const AmiiboApp({Key? key}) : super(key: key);

  @override
  State<AmiiboApp> createState() => _AmiiboAppState();
}

class _AmiiboAppState extends State<AmiiboApp> {
  int _selectedIndex = 0;
  final Set<Map<String, dynamic>> _favoriteAmiibos = {}; // Favorit global

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? AmiiboListPage(
              favoriteAmiibos: _favoriteAmiibos,
            )
          : FavoritesPage(favoriteAmiibos: _favoriteAmiibos),
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
  final Set<Map<String, dynamic>> favoriteAmiibos;

  const AmiiboListPage({Key? key, required this.favoriteAmiibos}) : super(key: key);

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

  void _toggleFavorite(Map<String, dynamic> amiibo) {
    setState(() {
      if (widget.favoriteAmiibos.contains(amiibo)) {
        widget.favoriteAmiibos.remove(amiibo);
      } else {
        widget.favoriteAmiibos.add(amiibo);
      }
    });
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
                final isFavorite = widget.favoriteAmiibos.contains(amiibo);

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
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        _toggleFavorite(amiibo);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AmiiboDetailPage(amiibo: amiibo),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AmiiboDetailPage extends StatelessWidget {
  final Map<String, dynamic> amiibo;

  const AmiiboDetailPage({Key? key, required this.amiibo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amiibo Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Optional: implement favorite toggle here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                amiibo['image'],
                height: 150,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              amiibo['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Amiibo Series', amiibo['amiiboSeries']),
            _buildDetailRow('Character', amiibo['character']),
            _buildDetailRow('Game Series', amiibo['gameSeries']),
            _buildDetailRow('Type', amiibo['type']),
            _buildDetailRow('Head', amiibo['head']),
            _buildDetailRow('Tail', amiibo['tail']),
            const SizedBox(height: 16),
            const Text(
              'Release Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildReleaseDate('Australia', amiibo['release']['au']),
            _buildReleaseDate('Europe', amiibo['release']['eu']),
            _buildReleaseDate('Japan', amiibo['release']['jp']),
            _buildReleaseDate('North America', amiibo['release']['na']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseDate(String region, String? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$region: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(date ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final Set<Map<String, dynamic>> favoriteAmiibos;

  const FavoritesPage({Key? key, required this.favoriteAmiibos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.deepPurple,
      ),
      body: favoriteAmiibos.isEmpty
          ? const Center(
              child: Text('No favorites yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteAmiibos.length,
              itemBuilder: (context, index) {
                final amiibo = favoriteAmiibos.elementAt(index);
                return Dismissible(
                  key: Key(amiibo['head'] + amiibo['tail']), // Unique key based on amiibo
                  direction: DismissDirection.endToStart, // Gesture to swipe left to delete
                  onDismissed: (direction) {
                    // Remove the amiibo from the set
                    favoriteAmiibos.remove(amiibo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${amiibo['name']} removed from favorites')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AmiiboDetailPage(amiibo: amiibo),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
