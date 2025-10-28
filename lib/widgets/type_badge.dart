import 'package:flutter/material.dart';
import '../utils/pokemon_colors.dart';
import '../utils/string_extensions.dart';

class TypeBadge extends StatelessWidget {
  final String type;

  const TypeBadge({
    super.key,
    required this.type,
  });

  String _getTypeInPortuguese(String type) {
    final Map<String, String> typeTranslations = {
      'normal': 'Normal',
      'fire': 'Fogo',
      'water': 'Água',
      'electric': 'Elétrico',
      'grass': 'Planta',
      'ice': 'Gelo',
      'fighting': 'Lutador',
      'poison': 'Veneno',
      'ground': 'Terra',
      'flying': 'Voador',
      'psychic': 'Psíquico',
      'bug': 'Inseto',
      'rock': 'Pedra',
      'ghost': 'Fantasma',
      'dragon': 'Dragão',
      'dark': 'Sombrio',
      'steel': 'Aço',
      'fairy': 'Fada',
    };
    return typeTranslations[type.toLowerCase()] ?? type.capitalize();
  }

  @override
  Widget build(BuildContext context) {
    final color = PokemonColors.getTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _getTypeInPortuguese(type),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
