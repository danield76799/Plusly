import 'package:flutter/material.dart';
import 'package:Pulsly/services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<SavedMessage> _favorites = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  Future<void> _searchFavorites(String query) async {
    if (query.isEmpty) {
      _loadFavorites();
      return;
    }
    final results = await FavoritesService.searchFavorites(query);
    setState(() {
      _favorites = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ Favorieten'),
        backgroundColor: const Color(0xFF49AFC2),
      ),
      body: Column(
        children: [
          // Zoekbalk
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Zoek in favorieten...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _searchFavorites(value);
              },
            ),
          ),
          // Favorieten lijst
          Expanded(
            child: _favorites.isEmpty
                ? const Center(
                    child: Text(
                      'Geen favorieten yet\n⭐ Lang druk op een bericht om op te slaan',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final msg = _favorites[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF49AFC2),
                            child: Text(
                              msg.sender[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(msg.sender),
                          subtitle: Text(
                            msg.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FavoritesService.removeMessage(msg.id);
                              _loadFavorites();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
