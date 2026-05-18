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

  // Plusly brand colors
  static const Color pluslyBlue = Color(0xFF49AFC2);
  static const Color darkBackground = Color(0xFF333333);
  static const Color cardBackground = Color(0xFF3D3D3D);
  static const Color textGray = Color(0xFF999999);
  static const Color warmRed = Color(0xFFE74C3C);

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
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: pluslyBlue,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Favorieten',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/rooms/newprivatechat');
        },
        backgroundColor: pluslyBlue,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(pluslyBlue),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, style: const TextStyle(color: warmRed)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              style: ElevatedButton.styleFrom(
                backgroundColor: pluslyBlue,
              ),
              child: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Geen favorieten yet',
              style: TextStyle(
                color: textGray,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⭐ Lang druk op een bericht om op te slaan',
              style: TextStyle(
                color: textGray,
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final msg = _favorites[index];
        return _buildFavoriteCard(msg);
      },
    );
  }

  Widget _buildFavoriteCard(SavedMessage msg) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go('/rooms/${msg.roomId}?event=${msg.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: pluslyBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    msg.sender.isNotEmpty ? msg.sender[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.sender,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textGray,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(msg.savedAt),
                      style: TextStyle(
                        color: textGray.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: warmRed,
                onPressed: () async {
                  await FavoritesService.removeMessage(msg.id);
                  _loadFavorites();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'Zojuist';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m geleden';
    if (diff.inHours < 24) return '${diff.inHours}u geleden';
    if (diff.inDays < 7) return '${diff.inDays}d geleden';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}