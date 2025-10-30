import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

/// Serviço responsável pela comunicação com a PokéAPI
class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  /// Retorna lista paginada de pokémon
  Future<Map<String, dynamic>> obterListaPokemon({
    required int deslocamento,
    required int limite,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/pokemon?offset=$deslocamento&limit=$limite',
      );
      final resposta = await http.get(uri).timeout(const Duration(seconds: 10));

      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);
        final resultados = (dados['results'] as List)
            .map((json) => PokemonListItem.fromJson(json))
            .toList();

        return {
          'results': resultados,
          'count': dados['count'],
          'next': dados['next'],
          'previous': dados['previous'],
        };
      } else {
        throw Exception(
          'Falha ao carregar lista de Pokémon (código ${resposta.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception(
        'Erro de conexão: verifique sua internet e tente novamente.',
      );
    } on TimeoutException {
      throw Exception(
        'Tempo esgotado: a requisição demorou muito. Tente novamente.',
      );
    } catch (e) {
      throw Exception('Erro ao carregar lista: $e');
    }
  }

  Future<Pokemon> obterPokemon(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/pokemon/$id');
      final resposta = await http.get(uri).timeout(const Duration(seconds: 10));

      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);
        return Pokemon.fromJson(dados);
      } else {
        throw Exception(
          'Falha ao carregar Pokémon (código ${resposta.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception(
        'Erro de conexão: verifique sua internet e tente novamente.',
      );
    } on TimeoutException {
      throw Exception(
        'Tempo esgotado: a requisição demorou muito. Tente novamente.',
      );
    } catch (e) {
      throw Exception('Erro ao carregar Pokémon: $e');
    }
  }

  Future<PokemonDetails> obterDetalhesPokemon(int id) async {
    try {
      // REQUISIÇÃO 1
      final uriPokemon = Uri.parse('$baseUrl/pokemon/$id');
      final respostaPokemon = await http
          .get(uriPokemon)
          .timeout(const Duration(seconds: 10));

      if (respostaPokemon.statusCode != 200) {
        throw Exception(
          'Falha ao carregar Pokémon (código ${respostaPokemon.statusCode}).',
        );
      }

      final dadosPokemon = json.decode(respostaPokemon.body);

      //  REQUISIÇÃO 2
      final uriEspecie = Uri.parse('$baseUrl/pokemon-species/$id');
      final respostaEspecie = await http
          .get(uriEspecie)
          .timeout(const Duration(seconds: 10));

      String descricao = 'Nenhuma descrição disponível.';
      List<PokemonEvolution> cadeiaEvolucao = [];

      if (respostaEspecie.statusCode == 200) {
        final dadosEspecie = json.decode(respostaEspecie.body);

        // Busca descrição (prioridade: pt-BR, pt, depois en)
        final entradasTexto = dadosEspecie['flavor_text_entries'] as List;
        Map<String, dynamic>? entradaEscolhida;

        // Tenta português primeiro
        for (var codigoIdioma in ['pt-BR', 'pt', 'en']) {
          try {
            entradaEscolhida = entradasTexto.firstWhere(
              (entrada) => entrada['language']['name'] == codigoIdioma,
            );
            break; // Encontrou, para de buscar
          } catch (_) {
            continue; // Tenta próximo idioma
          }
        }

        // Fallback para qualquer descrição disponível
        if (entradaEscolhida == null && entradasTexto.isNotEmpty) {
          entradaEscolhida = entradasTexto[0];
        }

        if (entradaEscolhida != null) {
          descricao = (entradaEscolhida['flavor_text'] as String)
              .replaceAll('\n', ' ')
              .replaceAll('\f', ' ')
              .trim();
        }

        // REQUISIÇÃO 3
        final urlCadeiaEvolucao = dadosEspecie['evolution_chain']?['url'];
        if (urlCadeiaEvolucao != null) {
          try {
            final respostaEvolucao = await http
                .get(Uri.parse(urlCadeiaEvolucao))
                .timeout(const Duration(seconds: 10));
            if (respostaEvolucao.statusCode == 200) {
              final dadosEvolucao = json.decode(respostaEvolucao.body);
              cadeiaEvolucao = _processarCadeiaEvolucao(dadosEvolucao['chain']);
            }
          } catch (_) {}
        }
      }

      return PokemonDetails(
        id: dadosPokemon['id'],
        name: dadosPokemon['name'],
        imageUrl:
            dadosPokemon['sprites']['other']['official-artwork']['front_default'] ??
            dadosPokemon['sprites']['front_default'] ??
            '',
        types: (dadosPokemon['types'] as List)
            .map((tipo) => tipo['type']['name'] as String)
            .toList(),
        height: dadosPokemon['height'],
        weight: dadosPokemon['weight'],
        stats: (dadosPokemon['stats'] as List)
            .map((stat) => PokemonStat.fromJson(stat))
            .toList(),
        abilities: (dadosPokemon['abilities'] as List)
            .map((habilidade) => habilidade['ability']['name'] as String)
            .toList(),
        description: descricao,
        evolutionChain: cadeiaEvolucao,
      );
    } on SocketException {
      throw Exception(
        'Erro de conexão: verifique sua internet e tente novamente.',
      );
    } on TimeoutException {
      throw Exception(
        'Tempo esgotado: a requisição demorou muito. Tente novamente.',
      );
    } catch (e) {
      throw Exception('Erro ao carregar detalhes: $e');
    }
  }

  List<PokemonEvolution> _processarCadeiaEvolucao(Map<String, dynamic> cadeia) {
    List<PokemonEvolution> evolucoes = [];

    void adicionarEvolucao(Map<String, dynamic> no) {
      final urlEspecie = no['species']['url'] as String;
      final id = int.parse(urlEspecie.split('/')[6]);
      final nome = no['species']['name'] as String;

      evolucoes.add(
        PokemonEvolution(
          id: id,
          name: nome,
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
        ),
      );

      if (no['evolves_to'] != null && (no['evolves_to'] as List).isNotEmpty) {
        for (var evolucao in no['evolves_to']) {
          adicionarEvolucao(evolucao);
        }
      }
    }

    adicionarEvolucao(cadeia);
    return evolucoes;
  }

  Future<List<PokemonListItem>> pesquisarPokemon(String consulta) async {
    try {
      // PokéAPI não tem endpoint de busca direto
      // Busca lista maior e filtra localmente
      final uri = Uri.parse('$baseUrl/pokemon?limit=1000');
      final resposta = await http.get(uri).timeout(const Duration(seconds: 12));

      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);
        final resultados = (dados['results'] as List)
            .map((json) => PokemonListItem.fromJson(json))
            .where((pokemon) => pokemon.name.contains(consulta.toLowerCase()))
            .take(20)
            .toList();

        return resultados;
      } else {
        throw Exception(
          'Falha ao buscar Pokémon (código ${resposta.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception(
        'Erro de conexão: verifique sua internet e tente novamente.',
      );
    } on TimeoutException {
      throw Exception(
        'Tempo esgotado: a requisição demorou muito. Tente novamente.',
      );
    } catch (e) {
      throw Exception('Erro ao buscar Pokémon: $e');
    }
  }
}
