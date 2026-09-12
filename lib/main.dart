import 'package:flutter/material.dart';
import 'package:pockeapi2026/screens/generation_list_screen.dart';
import 'package:provider/provider.dart';

import 'providers/poke_api_provider.dart';

void main() => runApp(const AppState());

class AppState extends StatelessWidget{
  const AppState({super.key});
@override
Widget build(BuildContext context){
  return MultiProvider(
    providers:[
     ChangeNotifierProvider(
          create: (_) => PokeApiProvider(), 
          lazy: false,
  ),
  ],
  child: MyApp(),

); // MultiProvider
}

}

const _KPrimary = Color(0xFF5345AB);//para cambiar el color de la barra de arriba 
const _KSecondary = Color(0xFFE5D36D);
const _KSurfaceVariant = Color(0xFFB8BDD5);
const _KDark = Color(0xFF1E2240);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Poke Clase',
  theme: ThemeData(
    useMaterial3: true,
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
    home:const GenerationListScreen(),
    );
      
    
  }
}