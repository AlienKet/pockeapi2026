import 'dart:convert';

// Representa la respuesta del endpoint /pokemon-species/{id}, trae
// caracteristicas de la especie (color, habitat, descripcion, evoluciones, etc.)
class PokemonSpeciesDetailResponse {
  final int id;
  final String name;
  final int order;
  final int genderRate;
  final int captureRate;
  final int baseHappiness;
  final bool isBaby;
  final bool isLegendary;
  final bool isMythical;
  final int hatchCounter;

  final SpeciesItem? habitat;      // puede ser null
  final SpeciesItem color;
  final SpeciesItem shape;
  final SpeciesItem growthRate;
  final SpeciesItem generation;
  final SpeciesItem? evolvesFromSpecies; // puede ser null
  final SpeciesItem evolutionChain; 
  final List<SpeciesItem> eggGroups;

  final String genus;
  final String flavorText;

  PokemonSpeciesDetailResponse({
    required this.id,
    required this.name,
    required this.order,
    required this.genderRate,
    required this.captureRate,
    required this.baseHappiness,
    required this.isBaby,
    required this.isLegendary,
    required this.isMythical,
    required this.hatchCounter,
    required this.habitat,
    required this.color,
    required this.shape,
    required this.growthRate,
    required this.generation,
    required this.evolvesFromSpecies,
    required this.evolutionChain,
    required this.eggGroups,
    required this.genus,
    required this.flavorText,
  });

  factory PokemonSpeciesDetailResponse.fromRawJson(String str) =>
      PokemonSpeciesDetailResponse.fromJson(json.decode(str));

  factory PokemonSpeciesDetailResponse.fromJson(Map<String, dynamic> json) {
   
    // egg_groups llega como una lista de objetos {name, url}
    var eggGroupsList = json['egg_groups'] as List? ?? [];
    List<SpeciesItem> eggGroups =
        eggGroupsList.map((i) => SpeciesItem.fromJson(i)).toList();

    
    // genera trae el mismo texto en varios idiomas; se busca primero español
    final generaList = json['genera'] as List? ?? [];
    final genusEntry = generaList.firstWhere(
      (g) => g['language']['name'] == 'es',
      orElse: () => generaList.firstWhere(
        (g) => g['language']['name'] == 'en', // si no hay español, se usa ingles
        orElse: () => null,
      ),
    );
    final genusText = genusEntry != null ? genusEntry['genus'] as String : '';

    
     // flavor_text: primero se busca en español, si no hay se usa el inglés
    final entries = json['flavor_text_entries'] as List? ?? [];
    final textEntry = entries.firstWhere(
      (e) => e['language']['name'] == 'es',
      orElse: () => entries.firstWhere(
        (e) => e['language']['name'] == 'en',
        orElse: () => entries.isNotEmpty ? entries.first : null, // si no hay ninguno de los dos, se toma el primero que exista
      ),
    );
      final flavorTextValue = textEntry != null
        ? (textEntry['flavor_text'] as String)
            .replaceAll('\n', ' ') // quita saltos de linea sueltos dentro del texto
            .replaceAll('\f', ' ') // quita saltos de pagina que a veces trae la api
        : 'Sin descripción disponible';

    return PokemonSpeciesDetailResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      genderRate: json['gender_rate'] ?? 0,
      captureRate: json['capture_rate'] ?? 0,
      baseHappiness: json['base_happiness'] ?? 0,
      isBaby: json['is_baby'] ?? false,
      isLegendary: json['is_legendary'] ?? false,
      isMythical: json['is_mythical'] ?? false,
      hatchCounter: json['hatch_counter'] ?? 0,
      // habitat puede venir null en el json, por eso se revisa antes de convertirlo
      habitat: json['habitat'] != null
          ? SpeciesItem.fromJson(json['habitat'])
          : null,
      color: SpeciesItem.fromJson(json['color']),
      shape: SpeciesItem.fromJson(json['shape']),
      growthRate: SpeciesItem.fromJson(json['growth_rate']),
      generation: SpeciesItem.fromJson(json['generation']),
      // igual que habitat, este campo puede no existir si es la primera evolucion
      evolvesFromSpecies: json['evolves_from_species'] != null
          ? SpeciesItem.fromJson(json['evolves_from_species'])
          : null,
      evolutionChain: SpeciesItem.fromJson(json['evolution_chain']),
      eggGroups: eggGroups,
      genus: genusText,
      flavorText: flavorTextValue,
    );
  }
}

// Objeto generico con nombre y url, reutilizado para varios campos
// de la especie (color, forma, habitat, cadena evolutiva, etc.)
class SpeciesItem {
  final String name;
  final String url;

  SpeciesItem({
    required this.name,
    required this.url,
  });

  factory SpeciesItem.fromRawJson(String str) =>
      SpeciesItem.fromJson(json.decode(str));

  factory SpeciesItem.fromJson(Map<String, dynamic> json) {
    return SpeciesItem(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
  };

  // metodo para extraer el id directamente desde la URL
  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.parse(segments.last);
  }
}