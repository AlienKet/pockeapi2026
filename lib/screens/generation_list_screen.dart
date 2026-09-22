import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pockeapi2026/models/generation_list_response.dart';
import 'package:pockeapi2026/screens/generation_detail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/poke_api_provider.dart';  

// Primera pantalla de la app: lista todas las generaciones de pokemon
// disponibles, cada una lleva a su propia cuadricula de pokemon
class GenerationListScreen extends StatelessWidget {
  const GenerationListScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Generaciones')),

      ),
      // Se pide la lista de generaciones usando el provider registrado en main.dart;
      // listen:false porque aqui solo se necesita el dato una vez, no escuchar cambios
      body: FutureBuilder<http.Response>(
        future: Provider.of<PokeApiProvider>(context, listen: false).getGenerations(),
        builder: (context, snapshot) {
         if(snapshot.connectionState== ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
         }else if(snapshot.hasError){
          return Center(child: Text('Erro:  ${snapshot.error}'),);
         }else if(!snapshot.hasData || snapshot.data!.statusCode != 200){
          return const Center(child: Text('Failed to load generations'),);
         }else{
          // Se decodifica el json crudo y se transforma en el modelo de la lista
          final generationListResponse = GenerationListResponse.fromJson(json.decode(snapshot.data!.body));
          // ListView.separated dibuja una lista vertical y permite poner
          // un espacio (o cualquier widget) entre cada elemento
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: generationListResponse.results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            
            itemBuilder: (context, index){//este es el que se encarga de crear cada elemento de la lista, en este caso cada generacion
              final generation= generationListResponse.results[index];
                final formattedName = _formatGenerationName(generation.name);//llamamos a la funcion para formatear el nombre de la generacion
              return Card(
                margin: EdgeInsets.zero,
                elevation: 2,//esto es para que los rectangulos tengan sombra
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),//esto es para que los bordes de los rectangulos sean redondeados
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(//BoxDecoration es para darle forma al icono de la generacion
                    shape: BoxShape.circle,//shape es para que el icono de la generacion sea circular
                    color: Colors.white,
                   ),
                   padding: const EdgeInsets.all(4),//el padding es para que el icono de la generacion no se vea grande
                    // Image.asset carga una imagen guardada dentro del proyecto,
                    // a diferencia de Image.network que la trae de internet
                    child: Image.asset(
                      'recursos/iconos/G${index + 1}.png',
                    fit: BoxFit.contain,//fit es para que el icono de la generacion se vea bien
                    ),
                   ),
                  title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Text(
                  formattedName,
                   style: const TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w600,//esto es para que el nombre de la generacion se vea en negrita
                   ),
                   ),
                  const SizedBox(height: 4),//esto es para que el nombre de la generacion no se vea pegado al icono de la generacion
                Container(//aqui es para poner la linea dorada debajo del nombre de la generacion
                  height: 2,//delgado
                   width: 100,//ancho
                  color: const Color.fromARGB(255, 212, 175, 55), // dorado
                ),
                ],//final de children
                  ),
                  onTap: (){
                    // Al tocar una generacion, se navega a su cuadricula de pokemon,
                    // el id se calcula con el indice de la lista (empieza en 0, la api en 1)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context)=> GenerationDetailScreen(generationId: index +1)
                      ));
                  },
                )
              );
            },//final de itemBuilder
          );
         }//final de else
        },//final de builder
      )
      


    );
  }//final de build
String _formatGenerationName(String rawName) {//esta funcion es para formatear el nombre de la generacion
  final parts = rawName.split('-');//esto es para separar el nombre de la generacion en partes, por ejemplo, "generation-i" se separa en ["generation", "i"]
  if (parts.length < 2) return rawName;//esto es para que si el nombre de la generacion no tiene un guion, se devuelva el nombre original
  final numeral = parts[1].toUpperCase();//esto es para que la segunda parte del nombre de la generacion se devuelva en mayusculas, por ejemplo, "i" se devuelve como "I"
  return 'Generation $numeral';
}

}