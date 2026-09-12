import 'package:flutter/material.dart';
import 'package:pockeapi2026/models/generation_detail_response.dart';
import 'package:pockeapi2026/providers/poke_api_provider.dart';
import 'package:pockeapi2026/screens/pokemon_detail_screen.dart';


class GenerationDetailScreen extends StatelessWidget {
  final int generationId;

  const GenerationDetailScreen({Key? key, required this.generationId}) : super(key: key);

  String _spriteUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Generación $generationId'),
      ),
      body: FutureBuilder(
        future: PokeApiProvider().getGenerationDetail(generationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {//snapshot es como el cache
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final generationDetailResponse = GenerationDetailResponse.fromRawJson(snapshot.data!.body);
            final speciesList = generationDetailResponse.pokemonSpecies;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: speciesList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final species = speciesList[index];
                return _PokemonCard(
                  id: species.id,
                  name: species.name,
                  imageUrl: _spriteUrl(species.id),
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailScreen(pokemonId: species.id, pokemonName: species.name),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final int id;
  final String name;
  final String imageUrl;
  final ColorScheme colorScheme;
  final VoidCallback onTap; //VoidCallback es un tipo de función que no devuelve ningún valor y no recibe parámetros.

  const _PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.onPrimary,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell( //InkWell es un widget que proporciona una respuesta visual a las interacciones del usuario,
      // como toques y clics. Se utiliza para crear efectos de "ripple" (ondas) cuando el usuario toca un área específica de la pantalla.
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${id.toString().padLeft(3, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name[0].toUpperCase() + name.substring(1),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,//overflow es para que el texto no se salga del contenedor y se vea feo, si es muy largo se pone "..."
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),//strokeWidth es el grosor del circulo de carga
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.catching_pokemon, color: colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}