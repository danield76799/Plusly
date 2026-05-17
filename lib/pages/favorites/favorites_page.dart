import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Pulsly/services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<SavedMessage> _favorites = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final favorites = await FavoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Fout bij laden: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ Favorieten'),
        backgroundColor: const Color(0xFF49AFC2),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return const Center(
        child: Text(
          'Geen favorieten yet\n⭐ Lang druk op een bericht om op te slaan',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final msg = _favorites[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF49AFC2),
              child: Text(
                msg.sender.isNotEmpty ? msg.sender[0].toUpperCase() : '?',
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
            onTap: () {
              // Open de chat waar dit bericht vandaan komt
              context.go('/rooms/${msg.roomId}');
            },
          ),
        );
      },
    );
  }
}
