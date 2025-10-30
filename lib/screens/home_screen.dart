import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/error_widget.dart';
import 'detail_screen.dart';

/// Tela principal com lista de pokémon e busca
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    
    // Carrega pokémon iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PokemonProvider>();
      if (provider.pokemons.isEmpty) {
        provider.loadPokemons();
      }
    });
    
    // Listener para infinite scroll
    _scrollController.addListener(_onScroll);
  }

  /// Detecta quando usuário chega perto do fim da lista
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PokemonProvider>().loadPokemons();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PokéDex',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  context.read<SearchProvider>().clearSearch();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBarWidget(
                onPokemonSelected: (pokemon) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(pokemonId: pokemon.id),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: _showSearch
                ? _buildSearchResults()
                : _buildPokemonList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        if (searchProvider.query.isEmpty) {
          return const Center(
            child: Text('Digite o nome de um Pokémon'),
          );
        }
        
        if (searchProvider.isSearching) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (searchProvider.searchError != null) {
          return ErrorWidgetCustom(
            message: searchProvider.searchError!,
            onRetry: () {
              searchProvider.searchPokemon(searchProvider.query);
            },
          );
        }
        
        if (searchProvider.searchResults.isEmpty) {
          return const Center(
            child: Text('Nenhum Pokémon encontrado'),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: searchProvider.searchResults.length,
          itemBuilder: (context, index) {
            final pokemon = searchProvider.searchResults[index];
            return PokemonCard(
              pokemon: pokemon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(pokemonId: pokemon.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPokemonList() {
    return Consumer<PokemonProvider>(
      builder: (context, provider, _) {
        if (provider.pokemons.isEmpty && provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (provider.error != null && provider.pokemons.isEmpty) {
          return ErrorWidgetCustom(
            message: provider.error!,
            onRetry: () {
              provider.loadPokemons(refresh: true);
            },
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadPokemons(refresh: true);
          },
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.pokemons.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.pokemons.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final pokemon = provider.pokemons[index];
              return PokemonCard(
                pokemon: pokemon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(pokemonId: pokemon.id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
