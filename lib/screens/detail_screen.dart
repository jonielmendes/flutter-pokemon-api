import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../utils/pokemon_colors.dart';
import '../utils/string_extensions.dart';
import '../widgets/error_widget.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_badge.dart';

class DetailScreen extends StatelessWidget {
  final int pokemonId;

  const DetailScreen({
    super.key,
    required this.pokemonId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PokemonDetails>(
        future: context.read<PokemonProvider>().getPokemonDetails(pokemonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (snapshot.hasError) {
            return ErrorWidgetCustom(
              message: snapshot.error.toString(),
              onRetry: () {
                // Trigger rebuild
                (context as Element).markNeedsBuild();
              },
            );
          }
          
          final pokemon = snapshot.data!;
          final backgroundColor = PokemonColors.getTypeColor(pokemon.types[0]);
          
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, pokemon, backgroundColor),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTypes(pokemon.types),
                      const SizedBox(height: 20),
                      _buildDescription(context, pokemon.description),
                      const SizedBox(height: 20),
                      _buildInfo(context, pokemon),
                      const SizedBox(height: 20),
                      _buildStats(context, pokemon.stats),
                      const SizedBox(height: 20),
                      _buildAbilities(context, pokemon.abilities),
                      if (pokemon.evolutionChain.length > 1) ...[
                        const SizedBox(height: 20),
                        _buildEvolutionChain(context, pokemon.evolutionChain),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PokemonDetails pokemon, Color backgroundColor) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          pokemon.name.capitalize(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                Icons.catching_pokemon,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Center(
              child: Hero(
                tag: 'pokemon-${pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: pokemon.imageUrl,
                  height: 200,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.catching_pokemon,
                    size: 100,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypes(List<String> types) {
    return Wrap(
      spacing: 10,
      children: types.map((type) => TypeBadge(type: type)).toList(),
    );
  }

  Widget _buildDescription(BuildContext context, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        description,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildInfo(BuildContext context, PokemonDetails pokemon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            context,
            'Altura',
            '${(pokemon.height / 10).toStringAsFixed(1)} m',
            Icons.height,
          ),
          _buildInfoItem(
            context,
            'Peso',
            '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
            Icons.monitor_weight,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, List<PokemonStat> stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas Base',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ...stats.map((stat) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StatBar(stat: stat),
          )),
        ],
      ),
    );
  }

  Widget _buildAbilities(BuildContext context, List<String> abilities) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habilidades',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: abilities.map((ability) {
              return Chip(
                label: Text(ability.formatPokemonName()),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionChain(BuildContext context, List<PokemonEvolution> chain) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cadeia de Evolução',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chain.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward, size: 30),
              ),
              itemBuilder: (context, index) {
                final evolution = chain[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (evolution.id != pokemonId) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(pokemonId: evolution.id),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: evolution.id == pokemonId
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: evolution.imageUrl,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.catching_pokemon,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      evolution.name.capitalize(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
