import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Clase encargada de comunicarse con la PokeAPI: aqui viven todos los
// metodos que hacen peticiones http hacia los distintos endpoints
class PokeApiProvider extends ChangeNotifier{
  final String _baseUrl = 'pokeapi.co';
  final String _apiPatch = '/api/v2/';

  // Trae el listado completo de generaciones disponibles
  Future<http.Response> getGenerations() async{
    final url = Uri.https(_baseUrl, '$_apiPatch/generation'); // arma la url completa a partir del host y la ruta
    final response = await http.get(url); // espera la respuesta del servidor antes de continuar
    return response;
  }

  // Trae los pokemon que pertenecen a una generacion en especifico
  Future<http.Response> getGenerationDetail(int id) async{//
    final url = Uri.https(_baseUrl, '$_apiPatch/generation/$id');
    final response = await http.get(url);
    return response;
  }

  // Trae los datos detallados de una especie (color, habitat, descripcion, etc.)
  Future<http.Response> getGenerationSpeciesDetail(int id) async {
  final url = Uri.https(_baseUrl, '$_apiPatch/pokemon-species/$id');
  final response = await http.get(url);
  return response;
}

  // Trae la cadena evolutiva completa a la que pertenece un pokemon
  Future<http.Response> getEvolutionChain(int id) async {
  final url = Uri.https(_baseUrl, '$_apiPatch/evolution-chain/$id');
  final response = await http.get(url);
  return response;
}

}