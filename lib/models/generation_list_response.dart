import 'dart:convert';

// Representa la respuesta del endpoint /generation, con el listado
// completo de todas las generaciones existentes
class GenerationListResponse {
  final int count;
  final String? next;     // url de la siguiente pagina de resultados, si existe
  final String? previous;  // url de la pagina anterior, si existe
  final List<GenerationItem> results;

GenerationListResponse({
  required this.count,
  this.next,
  this.previous,
  required this.results
});
//metodo para recibir directamente el response.body
factory GenerationListResponse.fromRawJson(String str) => GenerationListResponse.fromJson(json.decode(str));
  
  //metodo para recibir el Map ya decodificado
factory GenerationListResponse.fromJson(Map<String, dynamic>json){
  var list=json['results'] as List? ?? [];
  List<GenerationItem> resultsList=list.map((i) => GenerationItem.fromJson(i)).toList();

  return GenerationListResponse(
    count: json['count'] ?? 0,
    next: json['next'],
    previous: json['previous'],
    results: resultsList
  );
}

}

// Objeto simple con nombre y url, usado dentro de la lista de generaciones
class GenerationItem{
  final String name;
  final String url;

GenerationItem({
  required this.name,
  required this.url
});

factory GenerationItem.fromRawJson(String str) => GenerationItem.fromJson(json.decode(str));

factory GenerationItem.fromJson(Map<String, dynamic>json){
  return GenerationItem(
    name: json['name'] ?? '',
    url: json['url'] ?? ''
  );
}

//metodo para mandar el mapa a un json
Map<String, dynamic> toJson() => {
  'name': name,
  'url': url
};

// metodo para extraer el id de la Generacion directamente desde la URL
int get id{
  final uri=Uri.parse(url);//.parse convierte la url en un objeto Uri, Uri es para manejar las rutas de manera mas facil y segura
  final segments=uri.pathSegments.where((s)=> s.isNotEmpty).toList();// aqui se obtiene la lista de segmentos de la ruta y se filtra para eliminar los vacios
  return int.parse(segments.last);//aqui se obtiene el ultimo segmento de la ruta que es el id de la generacion y se convierte a int
}

}//fin class