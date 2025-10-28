import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  
  Future<Map<String, dynamic>> getPokemonList({
    required int offset,
    required int limit,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = (data['results'] as List)
            .map((json) => PokemonListItem.fromJson(json))
            .toList();

        return {
          'results': results,
          'count': data['count'],
          'next': data['next'],
          'previous': data['previous'],
        };
      } else {
        throw Exception('Falha ao carregar lista de Pokémon (código ${response.statusCode}).');
      }
    } on SocketException {
      throw Exception('Erro de conexão: verifique sua internet e tente novamente.');
    } on TimeoutException {
      throw Exception('Tempo esgotado: a requisição demorou muito. Tente novamente.');
    } catch (e) {
      throw Exception('Erro ao carregar lista: $e');
    }
  }
  
  Future<Pokemon> getPokemon(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/pokemon/$id');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Falha ao carregar Pokémon (código ${response.statusCode}).');
      }
    } on SocketException {
      throw Exception('Erro de conexão: verifique sua internet e tente novamente.');
    } on TimeoutException {
      throw Exception('Tempo esgotado: a requisição demorou muito. Tente novamente.');
    } catch (e) {
      throw Exception('Erro ao carregar Pokémon: $e');
    }
  }
  
  Future<PokemonDetails> getPokemonDetails(int id) async {
    try {
      // Get basic pokemon data
      final pokemonUri = Uri.parse('$baseUrl/pokemon/$id');
      final pokemonResponse = await http.get(pokemonUri).timeout(const Duration(seconds: 10));

      if (pokemonResponse.statusCode != 200) {
        throw Exception('Falha ao carregar Pokémon (código ${pokemonResponse.statusCode}).');
      }

      final pokemonData = json.decode(pokemonResponse.body);

      // Get species data for description
      final speciesUri = Uri.parse('$baseUrl/pokemon-species/$id');
      final speciesResponse = await http.get(speciesUri).timeout(const Duration(seconds: 10));

      String description = 'Nenhuma descrição disponível.';
      List<PokemonEvolution> evolutionChain = [];

      if (speciesResponse.statusCode == 200) {
        final speciesData = json.decode(speciesResponse.body);

        // Get description (prefer Portuguese-BR, then Portuguese, then English)
        final flavorTextEntries = speciesData['flavor_text_entries'] as List;
        Map<String, dynamic>? chosenEntry;
        
        // Try Portuguese variants first
        for (var langCode in ['pt-BR', 'pt', 'en']) {
          try {
            chosenEntry = flavorTextEntries.firstWhere(
              (entry) => entry['language']['name'] == langCode,
            );
            break; // Found one, stop searching
          } catch (_) {
            continue; // Try next language
          }
        }
        
        // Fallback to any available description
        if (chosenEntry == null && flavorTextEntries.isNotEmpty) {
          chosenEntry = flavorTextEntries[0];
        }

        if (chosenEntry != null) {
          description = (chosenEntry['flavor_text'] as String)
              .replaceAll('\n', ' ')
              .replaceAll('\f', ' ')
              .trim();
        }

        // Get evolution chain
        final evolutionChainUrl = speciesData['evolution_chain']?['url'];
        if (evolutionChainUrl != null) {
          try {
            final evolutionResponse = await http
                .get(Uri.parse(evolutionChainUrl))
                .timeout(const Duration(seconds: 10));
            if (evolutionResponse.statusCode == 200) {
              final evolutionData = json.decode(evolutionResponse.body);
              evolutionChain = _parseEvolutionChain(evolutionData['chain']);
            }
          } catch (_) {
            // ignore evolution chain errors (not critical)
          }
        }
      }

      return PokemonDetails(
        id: pokemonData['id'],
        name: pokemonData['name'],
        imageUrl: pokemonData['sprites']['other']['official-artwork']['front_default'] ?? 
                  pokemonData['sprites']['front_default'] ?? '',
        types: (pokemonData['types'] as List)
            .map((type) => type['type']['name'] as String)
            .toList(),
        height: pokemonData['height'],
        weight: pokemonData['weight'],
        stats: (pokemonData['stats'] as List)
            .map((stat) => PokemonStat.fromJson(stat))
            .toList(),
        abilities: (pokemonData['abilities'] as List)
            .map((ability) => ability['ability']['name'] as String)
            .toList(),
        description: description,
        evolutionChain: evolutionChain,
      );
    } on SocketException {
      throw Exception('Erro de conexão: verifique sua internet e tente novamente.');
    } on TimeoutException {
      throw Exception('Tempo esgotado: a requisição demorou muito. Tente novamente.');
    } catch (e) {
      throw Exception('Erro ao carregar detalhes: $e');
    }
  }
  
  List<PokemonEvolution> _parseEvolutionChain(Map<String, dynamic> chain) {
    List<PokemonEvolution> evolutions = [];
    
    void addEvolution(Map<String, dynamic> node) {
      final speciesUrl = node['species']['url'] as String;
      final id = int.parse(speciesUrl.split('/')[6]);
      final name = node['species']['name'] as String;
      
      evolutions.add(PokemonEvolution(
        id: id,
        name: name,
        imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      ));
      
      if (node['evolves_to'] != null && (node['evolves_to'] as List).isNotEmpty) {
        for (var evolution in node['evolves_to']) {
          addEvolution(evolution);
        }
      }
    }
    
    addEvolution(chain);
    return evolutions;
  }
  
  Future<List<PokemonListItem>> searchPokemon(String query) async {
    try {
      // PokeAPI doesn't have a direct search endpoint
      // We'll fetch a larger list and filter locally
      final uri = Uri.parse('$baseUrl/pokemon?limit=1000');
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = (data['results'] as List)
            .map((json) => PokemonListItem.fromJson(json))
            .where((pokemon) => pokemon.name.contains(query.toLowerCase()))
            .take(20)
            .toList();

        return results;
      } else {
        throw Exception('Falha ao buscar Pokémon (código ${response.statusCode}).');
      }
    } on SocketException {
      throw Exception('Erro de conexão: verifique sua internet e tente novamente.');
    } on TimeoutException {
      throw Exception('Tempo esgotado: a requisição demorou muito. Tente novamente.');
    } catch (e) {
      throw Exception('Erro ao buscar Pokémon: $e');
    }
  }
}
