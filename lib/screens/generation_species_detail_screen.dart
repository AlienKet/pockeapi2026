import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pockeapi2026/models/generation_species_detail_response.dart';
import 'package:pockeapi2026/providers/poke_api_provider.dart';

class GenerationSpeciesDetailScreen extends StatelessWidget {
  final int pokemonId;
  final String pokemonName;

  const GenerationSpeciesDetailScreen({
    Key? key,
    required this.pokemonId,
    required this.pokemonName,
  }) : super(key: key);

  // Arma la url del sprite oficial usando el id del pokemon
  String _spriteUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  // Genera un color distinto para cada nombre de color que devuelve la API
  Color _colorFromApi(String colorName) {
    final hash = colorName.hashCode; // convierte el texto en un numero
    final hue = (hash % 360).toDouble(); // ese numero se ajusta a la rueda de color (0-360)
    return HSLColor.fromAHSL(1.0, hue, 0.45, 0.65).toColor(); // tono pastel parejo para todos
  }

  // Pide el detalle de la especie y, si tiene, obtiene tambien su siguiente evolucion
    Future<Map<String, dynamic>> _loadData(BuildContext context) async {
      final provider = Provider.of<PokeApiProvider>(context, listen: false);

    final speciesResponse = await provider.getGenerationSpeciesDetail(pokemonId);
    final detail = PokemonSpeciesDetailResponse.fromRawJson(speciesResponse.body);

    Map<String, dynamic>? nextEvolution;
    try {
      final chainResponse =
          await provider.getEvolutionChain(detail.evolutionChain.id);
      nextEvolution = _findNextEvolution(chainResponse.body, detail.id);
    } catch (_) {
      nextEvolution = null; // si la peticion falla, no se muestra el boton
    }

    return {'detail': detail, 'next': nextEvolution};
  }

  // Recorre el arbol de la cadena evolutiva hasta ubicar al pokemon actual
  // y regresa solo su primera evolucion, si existe
  Map<String, dynamic>? _findNextEvolution(String rawJson, int currentId) {
    final decoded = json.decode(rawJson);
    final chain = decoded['chain'];

    Map<String, dynamic>? buscar(Map<String, dynamic> node) {
      final speciesItem = SpeciesItem.fromJson(node['species']);
      final evolvesTo = node['evolves_to'] as List? ?? [];

      if (speciesItem.id == currentId) {
        if (evolvesTo.isEmpty) return null; // ya llego a su ultima forma
        final next = SpeciesItem.fromJson(evolvesTo.first['species']);
        return {'id': next.id, 'name': next.name};
      }

      // continua bajando por las ramas del arbol hasta encontrar coincidencia
      for (final hijo in evolvesTo) {
        final resultado = buscar(hijo as Map<String, dynamic>);
        if (resultado != null) return resultado;
      }
      return null;
    }

    return buscar(chain as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(pokemonName[0].toUpperCase() + pokemonName.substring(1)),
      ),
      // FutureBuilder espera la respuesta de _loadData y reconstruye la pantalla
      // segun el estado de esa peticion (cargando, error o datos listos)
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos'));
          } else {
            final detail = snapshot.data!['detail'] as PokemonSpeciesDetailResponse;
            final next = snapshot.data!['next'] as Map<String, dynamic>?;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta principal: imagen del pokemon con fondo segun su color
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _colorFromApi(detail.color.name),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.network(
                              _spriteUrl(detail.id),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.catching_pokemon,
                                size: 100,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        // El boton solo aparece cuando existe una siguiente evolucion
                        if (next != null)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: _EvolutionButton(
                              nextName: next['name'] as String,
                              onTap: () {
                                // Se apila la nueva pantalla encima de la actual,
                                // por eso "atras" regresa a la evolucion previa
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GenerationSpeciesDetailScreen(
                                      pokemonId: next['id'] as int,
                                      pokemonName: next['name'] as String,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Genus: categoria corta del pokemon, ej. "Mouse Pokémon"
                  if (detail.genus.isNotEmpty)
                    Text(
                      detail.genus,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.primary,
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Texto descriptivo tomado del pokedex
                  Text(
                    detail.flavorText,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),

                  // Bloque de caracteristicas fisicas
                  _SectionCard(
                    title: 'Detalles Físicos',
                    children: [
                      _InfoRow(label: 'Color', value: detail.color.name),
                      _InfoRow(label: 'Forma', value: detail.shape.name),
                      _InfoRow(
                          label: 'Hábitat',
                          value: detail.habitat?.name ?? 'Desconocido'),
                    ],
                  ),

                  // Bloque de datos evolutivos y de crecimiento
                  _SectionCard(
                    title: 'Crecimiento y Linaje',
                    children: [
                      _InfoRow(
                          label: 'Ritmo de crecimiento',
                          value: detail.growthRate.name),
                      _InfoRow(label: 'Generación', value: detail.generation.name),
                      _InfoRow(
                          label: 'Grupos huevo',
                          value: detail.eggGroups.map((e) => e.name).join(', ')),
                      _InfoRow(
                          label: 'Evoluciona de',
                          value: detail.evolvesFromSpecies?.name ?? 'Ninguno'),
                    ],
                  ),

                  // Bloque de valores numericos relacionados con la captura
                  _SectionCard(
                    title: 'Estadísticas de Captura',
                    children: [
                      _StatRow(
                        label: 'Tasa de captura',
                        value: detail.captureRate,
                        max: 255,
                      ),
                      _StatRow(
                        label: 'Felicidad base',
                        value: detail.baseHappiness,
                        max: 140,
                      ),
                      _StatRow(
                        label: 'Ciclos de huevo',
                        value: detail.hatchCounter,
                        max: 40,
                      ),
                    ],
                  ),

                  // Bloque con datos booleanos varios
                  _SectionCard(
                    title: 'Misc. Info',
                    children: [
                      _InfoRow(label: 'Es bebé', value: detail.isBaby ? 'Sí' : 'No'),
                      _InfoRow(
                          label: 'Legendario',
                          value: detail.isLegendary ? 'Sí' : 'No'),
                      _InfoRow(
                          label: 'Mítico', value: detail.isMythical ? 'Sí' : 'No'),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// Boton flotante con flecha que lleva a la siguiente evolucion
class _EvolutionButton extends StatelessWidget {
  final String nextName;
  final VoidCallback onTap;

  const _EvolutionButton({required this.nextName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.secondary,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_forward, color: colorScheme.onSecondary, size: 28),
              const SizedBox(height: 4),
              Text(
                nextName[0].toUpperCase() + nextName.substring(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Contenedor blanco reutilizable que agrupa un titulo con varias filas
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

// Fila simple de tipo "etiqueta: valor"
class _InfoRow extends StatelessWidget { 
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(
              child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

// Fila con barra de progreso para mostrar valores numericos de forma visual
class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;

  const _StatRow({required this.label, required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    // El valor se limita entre 0 y 1 para que la barra nunca se desborde
    final porcentaje = (value / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '$value'),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: porcentaje,
                minHeight: 12,
                backgroundColor: const Color(0xFFD7EED5),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}