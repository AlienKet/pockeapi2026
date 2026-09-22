import 'package:flutter/material.dart';
import 'package:pockeapi2026/models/generation_detail_response.dart';
import 'package:pockeapi2026/providers/poke_api_provider.dart';
import 'package:pockeapi2026/screens/generation_species_detail_screen.dart';
import 'package:provider/provider.dart';

// Pantalla que muestra, en forma de cuadricula, todos los pokemon
// que pertenecen a la generacion seleccionada
class GenerationDetailScreen extends StatelessWidget {
  final int generationId;

  const GenerationDetailScreen({Key? key, required this.generationId}) : super(key: key);

  // Construye la url de la imagen oficial de cada pokemon a partir de su id
  String _spriteUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // colores definidos en el tema de la app
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Generación $generationId'),
      ),
      // FutureBuilder reconstruye la pantalla dependiendo de como va la peticion http
     body: FutureBuilder(
      future: Provider.of<PokeApiProvider>(context, listen: false)
      .getGenerationDetail(generationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {//snapshot es como el cache
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            // Se convierte el texto crudo que llego de la api en un objeto Dart
            final generationDetailResponse = GenerationDetailResponse.fromRawJson(snapshot.data!.body);
            final speciesList = generationDetailResponse.pokemonSpecies;
            // GridView.builder arma una cuadricula sin cargar todo de golpe,
            // solo va creando las tarjetas que se ven en pantalla
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: speciesList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // cuantas columnas tiene la cuadricula
                crossAxisSpacing: 10, // espacio horizontal entre tarjetas
                mainAxisSpacing: 10, // espacio vertical entre tarjetas
                childAspectRatio: 0.8, // proporcion ancho/alto de cada tarjeta
              ),
              itemBuilder: (context, index) {
                final species = speciesList[index];
                return _PokemonCard(
                  id: species.id,
                  name: species.name,
                  imageUrl: _spriteUrl(species.id),
                  colorScheme: colorScheme,
                  onTap: () {
                    // Al tocar la tarjeta, se abre el detalle de ese pokemon,
                    // enviandole su id y su nombre como parametros
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenerationSpeciesDetailScreen(pokemonId: species.id, pokemonName: species.name),
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

// Tarjeta individual de la cuadricula, muestra el numero, nombre e imagen
// de un pokemon, y reacciona al tocarla
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
      elevation: 4, // sombra debajo de la tarjeta
      child: InkWell( //InkWell es un widget que proporciona una respuesta visual a las interacciones del usuario,
      // como toques y clics. Se utiliza para crear efectos de "ripple" (ondas) cuando el usuario toca un área específica de la pantalla.
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Numero de pokedex, rellenado con ceros a la izquierda (ej. #004)
              Text(
                '#${id.toString().padLeft(3, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              // Nombre con la primera letra en mayuscula
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
              // Expanded hace que la imagen ocupe el resto del espacio disponible
              Expanded(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  // Mientras la imagen carga, se ve un indicador chico girando
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
                  // Si la imagen no carga (url rota, sin internet), se muestra un icono
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