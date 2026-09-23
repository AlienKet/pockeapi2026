import 'package:flutter/material.dart';
import 'package:pockeapi2026/screens/generation_list_screen.dart';
import 'package:provider/provider.dart';

import 'providers/poke_api_provider.dart';

// Punto de entrada de la aplicacion: manda a llamar al widget raiz
void main() => runApp(const AppState());

// Widget raiz encargado de registrar el provider antes de mostrar la app
class AppState extends StatelessWidget{
  const AppState({super.key});
@override
Widget build(BuildContext context){
  // MultiProvider permite registrar varios providers al mismo tiempo,
  // aunque aqui solo se este usando uno
  return MultiProvider(
    providers:[
     ChangeNotifierProvider(
          create: (_) => PokeApiProvider(), // se crea una sola instancia del provider
          lazy: false, // se crea de inmediato, no hasta que alguien lo pida
  ),
  ],
  child: MyApp(), // toda la app queda "envuelta" y puede acceder al provider

); // MultiProvider
}

}

// Colores base del tema, definidos como constantes para reutilizarlos facil
const _KPrimary = Color(0xFF5345AB);//para cambiar el color de la barra de arriba 
const _KSecondary = Color(0xFFE5D36D);
const _KSurfaceVariant = Color(0xFFB8BDD5);
const _KDark = Color(0xFF1E2240);

// Widget que define el tema visual de toda la aplicacion y la pantalla inicial
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es el widget que envuelve toda la app y le da
    // funcionalidades como navegacion, tema, titulo, etc.
    return MaterialApp(
  debugShowCheckedModeBanner: false, // oculta la cinta roja de "debug" en la esquina
  title: 'Poke Clase',
  theme: ThemeData(
    useMaterial3: true, // activa el sistema de diseño mas reciente de Flutter
    scaffoldBackgroundColor: _KSurfaceVariant,
    colorScheme: const ColorScheme.dark(
        primary: _KPrimary,
        onPrimary: Colors.white,
        secondary: _KSecondary,
        onSecondary: _KDark,
        surface: _KSurfaceVariant,
        onSurface: _KDark,
    ),

  appBarTheme: const AppBarTheme(
      backgroundColor: _KPrimary,
      foregroundColor: Colors.white,
      elevation: 0, //sombra 
    ),

  listTileTheme: const ListTileThemeData(
      tileColor: Colors.white,//fondo de los rectangulos de las generaciones
      textColor: _KDark,
      iconColor: _KPrimary,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _KSecondary,
      foregroundColor: _KDark,
    )
),
    home:const GenerationListScreen(), // primera pantalla que se muestra al abrir la app
    );
      
    
  }
}