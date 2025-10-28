import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../utils/string_extensions.dart';

class StatBar extends StatelessWidget {
  final PokemonStat stat;

  const StatBar({
    super.key,
    required this.stat,
  });

  String _getStatDisplayName(String name) {
    switch (name) {
      case 'hp':
        return 'PS'; // Pontos de Saúde
      case 'attack':
        return 'Ataque';
      case 'defense':
        return 'Defesa';
      case 'special-attack':
        return 'Atq. Especial';
      case 'special-defense':
        return 'Def. Especial';
      case 'speed':
        return 'Velocidade';
      default:
        return name.formatPokemonName();
    }
  }

  Color _getStatColor(int baseStat) {
    if (baseStat < 50) return Colors.red;
    if (baseStat < 80) return Colors.orange;
    if (baseStat < 110) return Colors.yellow[700]!;
    if (baseStat < 140) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final maxStat = 255.0;
    final percentage = (stat.baseStat / maxStat).clamp(0.0, 1.0);
    final statColor = _getStatColor(stat.baseStat);

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            _getStatDisplayName(stat.name),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: statColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            stat.baseStat.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
