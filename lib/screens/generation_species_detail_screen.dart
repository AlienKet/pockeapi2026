import 'dart:convert';

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

  String _spriteUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  // Convierte el nombre del color que da la API a un Color de Flutter
  Color _colorFromApi(String colorName) {
    switch (colorName) {
      case 'black':
        return const Color(0xFF6E6E6E);
      case 'blue':
        return const Color(0xFF7FB2E5);
      case 'brown':
        return const Color(0xFFC2A17B);
      case 'gray':
        return const Color(0xFFBFC4C9);
      case 'green':
        return const Color(0xFF8FD48A);
      case 'pink':
        return const Color(0xFFF7A8C4);
      case 'purple':
        return const Color(0xFFB79CE0);
      case 'red':
        return const Color(0xFFEE8C8C);
      case 'white':
        return const Color(0xFFE8E8E8);
      case 'yellow':
        return const Color(0xFFF2CE4B);
      default:
        return const Color(0xFFBFC4C9);
    }
  }

  // Trae el detalle de la especie y, con el id de la cadena evolutiva,
  // busca cual es la siguiente evolucion de este pokemon (solo una).
  Future<Map<String, dynamic>> _loadData() async {
    final provider = PokeApiProvider();

    final speciesResponse = await provider.getGenerationSpeciesDetail(pokemonId);
    final detail = GenerationSpeciesDetailResponse.fromRawJson(speciesResponse.body);

    Map<String, dynamic>? nextEvolution;
    try {
      final chainResponse =
          await provider.getEvolutionChain(detail.evolutionChain.id);
      nextEvolution = _findNextEvolution(chainResponse.body, detail.id);
    } catch (_) {
      nextEvolution = null; // si falla la cadena, simplemente no se muestra el boton
    }

    return {'detail': detail, 'next': nextEvolution};
  }

  // Recorre el arbol de la cadena evolutiva buscando el nodo del pokemon actual
  // y devuelve SOLO la primera especie a la que evoluciona (si existe).
  Map<String, dynamic>? _findNextEvolution(String rawJson, int currentId) {
    final decoded = json.decode(rawJson);
    final chain = decoded['chain'];

    Map<String, dynamic>? buscar(Map<String, dynamic> node) {
      final speciesItem = GenerationItem.fromJson(node['species']);
      final evolvesTo = node['evolves_to'] as List? ?? [];

      if (speciesItem.id == currentId) {
        if (evolvesTo.isEmpty) return null; // ya es la ultima evolucion
        final next = GenerationItem.fromJson(evolvesTo.first['species']);
        return {'id': next.id, 'name': next.name};
      }

      // si no es este nodo, se sigue buscando en sus hijos
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos'));
          } else {
            final detail = snapshot.data!['detail'] as GenerationSpeciesDetailResponse;
            final next = snapshot.data!['next'] as Map<String, dynamic>?;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Tarjeta de la imagen, con fondo segun el color del pokemon ----
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
                        // Boton de evolucion (solo uno, si tiene siguiente evolucion)
                        if (next != null)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: _EvolutionButton(
                              nextName: next['name'] as String,
                              onTap: () {
                                // push normal: apila la pantalla de la evolucion
                                // encima de la actual, asi el boton "atras"
                                // regresa a la evolucion anterior, no a la lista.
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

                  // ---- Genus ----
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

                  // ---- Descripcion ----
                  Text(
                    detail.flavorText,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),

                  // ---- Secciones ----
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

// Boton con la flecha para pasar a la evolucion
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

// Tarjeta blanca con titulo que agrupa varias filas
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

// Fila con barra de progreso para los valores numericos
class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;

  const _StatRow({required this.label, required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    // se limita entre 0 y 1 para que la barra nunca se pase
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