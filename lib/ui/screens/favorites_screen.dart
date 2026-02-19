import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/favorite.dart';
import '../../data/models/hadith.dart';
import '../../bloc/favorites/favorites_bloc.dart';
import '../../bloc/favorites/favorites_state.dart';
import '../../bloc/favorites/favorites_event.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/hadith_card.dart';
import '../widgets/empty_state.dart';

/// FavoritesScreen - Display all saved/favorited Hadiths
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(const LoadFavorites());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: GoogleFonts.notoNaskhArabic(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final count = state is FavoritesLoaded ? state.count : 0;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(context),
          // Favorites list
          Expanded(
            child: BlocConsumer<FavoritesBloc, FavoritesState>(
              listener: (context, state) {
                // Show error SnackBar for error states
                if (state is FavoritesError) {
                  _showErrorSnackBar(state.message);
                }
              },
              builder: (context, state) {
                if (state is FavoritesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is FavoritesError) {
                  // Return previous state if available, otherwise show error
                  if (state is! FavoritesLoaded) {
                    return EmptyState.error(
                      errorMessage: state.message,
                      onRetry: () {
                        context.read<FavoritesBloc>().add(const LoadFavorites());
                      },
                    );
                  }
                }

                if (state is FavoritesLoaded) {
                  final displayed = state.displayedFavorites;

                  // No favorites at all
                  if (state.favorites.isEmpty) {
                    return EmptyState.noFavorites(
                      onExplore: () {
                        Navigator.of(context).pop();
                      },
                    );
                  }

                  // Search returned no results
                  if (displayed.isEmpty && _searchQuery.isNotEmpty) {
                    return EmptyState.noSearchResults(
                      query: _searchQuery,
                      onClear: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    );
                  }

                  return _buildFavoritesList(context, displayed, state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search favorites...',
          hintStyle: TextStyle(
            color: AppColors.text.withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(Icons.search_outlined),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<FavoritesBloc>().add(SearchFavorites(query));
  }

  Widget _buildFavoritesList(
    BuildContext context,
    List<Favorite> favorites,
    FavoritesLoaded state,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        final hadith = favorite.hadith;

        return Dismissible(
          key: Key(hadith.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Remove Favorite'),
                content: const Text(
                  'Are you sure you want to remove this Hadith from favorites?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            context.read<FavoritesBloc>().add(
                  RemoveFavorite(hadith.id),
                );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Removed from favorites'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    context.read<FavoritesBloc>().add(AddFavorite(hadith));
                  },
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                // Hadith Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hadith text
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          hadith.arabicText,
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 20,
                            height: 2.0,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.justify,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Citation
                      Text(
                        '${hadith.sourceBook} - Book ${hadith.bookNumber}, Hadith ${hadith.hadithNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.text.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Saved date
                      Text(
                        'Saved ${_formatDate(favorite.savedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.text.withValues(alpha: 0.5),
                        ),
                      ),

                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 20),
                            onPressed: () {
                              _showHadithDetail(context, hadith, state);
                            },
                            tooltip: 'View Full',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () {
                              _confirmRemove(context, hadith);
                            },
                            tooltip: 'Remove',
                            color: AppColors.error,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.delete_rounded,
        color: AppColors.white,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showHadithDetail(
    BuildContext context,
    Hadith hadith,
    FavoritesLoaded state,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _HadithDetailScreen(
          hadith: hadith,
          isFavorite: state.isFavorite(hadith.id),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, Hadith hadith) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: const Text(
          'Are you sure you want to remove this Hadith from favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FavoritesBloc>().add(
                    RemoveFavorite(hadith.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Detail screen for a single favorite Hadith
class _HadithDetailScreen extends StatelessWidget {
  final Hadith hadith;
  final bool isFavorite;

  const _HadithDetailScreen({
    required this.hadith,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Details'),
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final isFav = state is FavoritesLoaded &&
                  state.isFavorite(hadith.id);

              return IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                ),
                onPressed: () {
                  context.read<FavoritesBloc>().add(
                        ToggleFavorite(hadith),
                      );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HadithCard(
          hadith: hadith,
          fontSize: 26.0,
        ),
      ),
    );
  }
}
