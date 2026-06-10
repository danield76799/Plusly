import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Pulsly/services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  final VoidCallback? onBack;
  const FavoritesPage({this.onBack, super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<SavedMessage> _favorites = [];
  bool _isLoading = true;
  String _error = '';

  // Spacing constants
  static const double screenPadding = 12.0;
  static const double cardBorderRadius = 12.0;
  static const double cardPadding = 12.0;
  static const double avatarSize = 48.0;
  static const double cardSpacing = 4.0;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // Header with Plusly blue background
          Container(
            height: headerHeight,
            color: colorScheme.primaryContainer,
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onPrimaryContainer, size: 24),
                    onPressed: widget.onBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (widget.onBack != null) const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 28),
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
            child: _buildBody(colorScheme: colorScheme),
          ),
        ],
      ),
      floatingActionButton: null, // Geen FAB op Favorieten pagina
    );
  }

  Widget _buildBody({required ColorScheme colorScheme}) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error, style: TextStyle(color: colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
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
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Geen favorieten',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '⭐ Lang druk op een bericht om op te slaan',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
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
        return _buildFavoriteCard(msg, colorScheme: colorScheme);
      },
    );
  }

  Widget _buildFavoriteCard(SavedMessage msg, {required ColorScheme colorScheme}) {
    return Card(
      margin: const EdgeInsets.only(bottom: cardSpacing),
      color: colorScheme.surfaceContainerHigh,
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
              // Avatar circle with primary color
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    msg.sender.isNotEmpty ? msg.sender[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
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
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: colorScheme.error),
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
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
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