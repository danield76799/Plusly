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

  // Exact colors from the reference image
  static const Color tealPrimary = Color(0xFF4DB6AC);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color redAccent = Color(0xFFEF5350);
  static const Color bottomNavBg = Color(0xFF2C2C2C);
  static const Color avatarBg = Color(0xFF4DB6AC);

  // Spacing constants
  static const double screenPadding = 12.0;
  static const double cardBorderRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double avatarSize = 48.0;
  static const double cardSpacing = 8.0;
  static const double headerHeight = 110.0;

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
      backgroundColor: backgroundDark,
      body: Column(
        children: [
          // Header with teal background
          Container(
            height: headerHeight,
            color: tealPrimary,
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Favorieten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // List content
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/rooms/newprivatechat');
        },
        backgroundColor: tealPrimary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'New chat',
          style: TextStyle(color: Colors.white),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(tealPrimary),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, style: const TextStyle(color: redAccent)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              style: ElevatedButton.styleFrom(
                backgroundColor: tealPrimary,
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
              color: textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Geen favorieten yet',
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⭐ Lang druk op een bericht om op te slaan',
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(screenPadding),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final msg = _favorites[index];
        return _buildFavoriteCard(msg);
      },
    );
  }

  Widget _buildFavoriteCard(SavedMessage msg) {
    return Card(
      margin: const EdgeInsets.only(bottom: cardSpacing),
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          context.go('/rooms/${msg.roomId}?event=${msg.id}');
        },
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  color: avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    msg.sender.isNotEmpty ? msg.sender[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
                    // Name row with delete icon
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            msg.sender,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: redAccent,
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            await FavoritesService.removeMessage(msg.id);
                            _loadFavorites();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Message preview
                    Text(
                      msg.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}