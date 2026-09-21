import 'dart:convert';

class GenerationSpeciesDetailResponse {
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

  final GenerationItem? habitat;      // puede ser null
  final GenerationItem color;
  final GenerationItem shape;
  final GenerationItem growthRate;
  final GenerationItem generation;
  final GenerationItem? evolvesFromSpecies; // puede ser null
  final GenerationItem evolutionChain; 
  final List<GenerationItem> eggGroups;

  final String genus;
  final String flavorText;

  GenerationSpeciesDetailResponse({
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

  factory GenerationSpeciesDetailResponse.fromRawJson(String str) =>
      GenerationSpeciesDetailResponse.fromJson(json.decode(str));

  factory GenerationSpeciesDetailResponse.fromJson(Map<String, dynamic> json) {
   
    var eggGroupsList = json['egg_groups'] as List? ?? [];
    List<GenerationItem> eggGroups =
        eggGroupsList.map((i) => GenerationItem.fromJson(i)).toList();

    
    final generaList = json['genera'] as List? ?? [];
    final genusEntry = generaList.firstWhere(
      (g) => g['language']['name'] == 'es',
      orElse: () => generaList.firstWhere(
        (g) => g['language']['name'] == 'en',
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
        orElse: () => entries.isNotEmpty ? entries.first : null,
      ),
    );
      final flavorTextValue = textEntry != null
        ? (textEntry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ')
        : 'Sin descripción disponible';

    return GenerationSpeciesDetailResponse(
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
      habitat: json['habitat'] != null
          ? GenerationItem.fromJson(json['habitat'])
          : null,
      color: GenerationItem.fromJson(json['color']),
      shape: GenerationItem.fromJson(json['shape']),
      growthRate: GenerationItem.fromJson(json['growth_rate']),
      generation: GenerationItem.fromJson(json['generation']),
      evolvesFromSpecies: json['evolves_from_species'] != null
          ? GenerationItem.fromJson(json['evolves_from_species'])
          : null,
      evolutionChain: GenerationItem.fromJson(json['evolution_chain']),
      eggGroups: eggGroups,
      genus: genusText,
      flavorText: flavorTextValue,
    );
  }
}

class GenerationItem {
  final String name;
  final String url;

  GenerationItem({
    required this.name,
    required this.url,
  });

  factory GenerationItem.fromRawJson(String str) =>
      GenerationItem.fromJson(json.decode(str));

  factory GenerationItem.fromJson(Map<String, dynamic> json) {
    return GenerationItem(
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