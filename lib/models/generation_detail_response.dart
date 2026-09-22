import 'dart:convert';

// Representa la respuesta del endpoint /generation/{id}, que trae
// todos los pokemon que pertenecen a esa generacion
class GenerationDetailResponse{
  final int id;
  final String name;
  final List <PokemonSpeciesItem> pokemonSpecies;

  GenerationDetailResponse({
    required this.id,
    required this.name,
    required this.pokemonSpecies
  });

  // Recibe el texto plano (response.body) y lo convierte primero en Map
  factory GenerationDetailResponse.fromRawJson(String str) => GenerationDetailResponse.fromJson(json.decode(str));

  // Arma el objeto ya con el Map decodificado
  factory GenerationDetailResponse.fromJson(Map<String, dynamic> json){
    var list=json['pokemon_species'] as List? ?? []; // si no existe el campo, se usa una lista vacia
    List<PokemonSpeciesItem> speciesList = list.map((i) => PokemonSpeciesItem.fromJson(i)).toList(); // convierte cada elemento del json en un objeto Dart

    return GenerationDetailResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      pokemonSpecies: speciesList,
    );
  }

  // Convierte el objeto de vuelta a Map, por si se necesita mandar como json
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'pokemon_species': pokemonSpecies.map((x) => x.toJson()).toList()
  };

}

// Representa cada pokemon dentro de la lista de una generacion,
// la api solo entrega su nombre y su url de detalle
class PokemonSpeciesItem{
  final String name;
  final String url;

  PokemonSpeciesItem({
    required this.name,
    required this.url
  });

  factory PokemonSpeciesItem.fromRawJson(String str) => PokemonSpeciesItem.fromJson(json.decode(str));

  factory PokemonSpeciesItem.fromJson(Map<String, dynamic> json){
    return PokemonSpeciesItem(
      name: json['name'],
      url: json['url']
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url
  };

  //extraer el id del pokemon desde la url

  int get id {
    final uri = Uri.parse(url); // convierte el texto de la url en un objeto manejable
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList(); // separa la ruta en partes y descarta las vacias
    return int.parse(segments.last); // el ultimo segmento es el numero de id
  }
}