import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonProvider with ChangeNotifier {
  final PokemonService _service = PokemonService();
  
  List<PokemonListItem> _pokemons = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  final int _limit = 20;
  
  List<PokemonListItem> get pokemons => _pokemons;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  
  Future<void> loadPokemons({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _offset = 0;
      _pokemons = [];
      _hasMore = true;
      _error = null;
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _service.getPokemonList(
        offset: _offset,
        limit: _limit,
      );
      
      final newPokemons = result['results'] as List<PokemonListItem>;
      
      if (refresh) {
        _pokemons = newPokemons;
      } else {
        _pokemons.addAll(newPokemons);
      }
      
      _offset += _limit;
      _hasMore = result['next'] != null;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Pokemon> getPokemon(int id) async {
    try {
      return await _service.getPokemon(id);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<PokemonDetails> getPokemonDetails(int id) async {
    try {
      return await _service.getPokemonDetails(id);
    } catch (e) {
      rethrow;
    }
  }
}

class SearchProvider with ChangeNotifier {
  final PokemonService _service = PokemonService();
  
  List<PokemonListItem> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  String _query = '';
  
  List<PokemonListItem> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  String get query => _query;
  
  Future<void> searchPokemon(String query) async {
    _query = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    _searchError = null;
    notifyListeners();
    
    try {
      _searchResults = await _service.searchPokemon(query);
    } catch (e) {
      _searchError = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  
  void clearSearch() {
    _query = '';
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }
}
