# 📱 Documentación del Proyecto — PockeAPI 2026

Este proyecto es una aplicación móvil desarrollada en **Flutter** que consume la **PokeAPI** para mostrar información de generaciones y Pokémon, a manera de Pokédex.

---

## 🎯 1. Propósito del Proyecto

La aplicación permite al usuario **explorar las generaciones de Pokémon**, ver todos los Pokémon que pertenecen a cada una, y consultar el **detalle de cada especie** (color, hábitat, descripción, estadísticas de captura y evoluciones), consumiendo en tiempo real los datos públicos de la PokeAPI.

### 🛠️ Tecnologías y Conceptos Utilizados

* **Lenguaje:** Dart
* **Framework:** Flutter
* **Manejo de estado:** Provider (`ChangeNotifier`)
* **Peticiones HTTP:** paquete `http`
* **Fuente de datos:** [PokeAPI](https://pokeapi.co/) (API pública en formato JSON)
* **Navegación:** `Navigator.push` entre pantallas

---

## 📂 2. Estructura de Carpetas

El proyecto sigue una arquitectura de capas simple. Cada carpeta tiene una responsabilidad específica:

* **`models/`**
  Clases que representan la forma de los datos que llegan de la API, y los convierten en objetos Dart utilizables.

* **`providers/`**
  Contiene toda la lógica de conexión con la PokeAPI: arma las URLs y hace las peticiones HTTP.

* **`screens/`**
  Contiene las pantallas visuales de la app y la lógica de cada una (qué mostrar, cómo navegar, etc.).

* **`main.dart`**
  Punto de entrada de la app. Define el tema visual y registra el `PokeApiProvider` para toda la aplicación.

---

## 🧭 3. Flujo de Navegación

La app tiene tres pantallas principales, conectadas en este orden:

* **Pantalla 1 — `GenerationListScreen`**
  Lista todas las generaciones de Pokémon disponibles.

* **Pantalla 2 — `GenerationDetailScreen`**
  Al tocar una generación, muestra en cuadrícula todos los Pokémon que le pertenecen.

* **Pantalla 3 — `GenerationSpeciesDetailScreen`**
  Al tocar un Pokémon, muestra su detalle completo. Si tiene evolución, un botón permite avanzar a la siguiente especie dentro de la misma pantalla.

Cada pantalla se abre con `Navigator.push`, así que el botón "atrás" del `AppBar` siempre regresa a la pantalla anterior en el mismo orden en que se visitaron.

---

## 🧩 4. Modelos (`models/`)

* **`GenerationListResponse`**
  Representa la respuesta del endpoint `/generation`. Contiene el conteo total y la lista de generaciones disponibles (`GenerationItem`).

* **`GenerationDetailResponse`**
  Representa la respuesta del endpoint `/generation/{id}`. Contiene el id, nombre y la lista de especies (`PokemonSpeciesItem`) que pertenecen a esa generación.

* **`GenerationSpeciesDetailResponse`**
  Representa la respuesta del endpoint `/pokemon-species/{id}`. Es el modelo más completo: incluye color, forma, hábitat, ritmo de crecimiento, grupos huevo, descripción, si es legendario, mítico o bebé, y la referencia a su cadena evolutiva.

### Patrón común en todos los modelos

Los tres modelos siguen la misma estructura interna:

1. **`fromRawJson(String str)`** — recibe el texto plano que llega del `http.Response.body` y lo decodifica a `Map`.
2. **`fromJson(Map<String, dynamic> json)`** — arma el objeto Dart a partir de ese `Map`, usando `??` para asignar valores por defecto si algún campo llega nulo.
3. **`toJson()`** — convierte el objeto de vuelta a `Map`, útil si se necesita reenviar los datos como JSON.

### Clases auxiliares `{name, url}`

La PokeAPI repite constantemente el patrón `{ "name": "...", "url": "..." }` para referenciar recursos relacionados (color, hábitat, generación, etc.). Por eso existen clases pequeñas (`GenerationItem`, `PokemonSpeciesItem`) que reutilizan ese mismo patrón, incluyendo un getter `id` que extrae el número identificador directamente de la URL.

---

## 🔌 5. Provider (`providers/`)

### `PokeApiProvider`

Extiende `ChangeNotifier` para poder registrarse con el paquete `provider` en `main.dart`. Contiene un método por cada endpoint que la app necesita consultar:

* **`getGenerations()`** → `/generation`
* **`getGenerationDetail(id)`** → `/generation/{id}`
* **`getGenerationSpeciesDetail(id)`** → `/pokemon-species/{id}`
* **`getEvolutionChain(id)`** → `/evolution-chain/{id}`

Todos siguen el mismo patrón: arman la URL con `Uri.https`, hacen la petición con `http.get` y devuelven el `Response` crudo, dejando que cada pantalla lo decodifique con el modelo correspondiente.

---

## 🖥️ 6. Pantallas (`screens/`)

### `GenerationListScreen`
Primera pantalla de la app. Muestra en una lista (`ListView.separated`) todas las generaciones disponibles, cada una con su ícono y nombre formateado (ej. `generation-i` se convierte en `Generation I`).

### `GenerationDetailScreen`
Muestra, en una cuadrícula (`GridView.builder`), todos los Pokémon que pertenecen a la generación seleccionada. Cada tarjeta incluye número, nombre e imagen oficial.

### `GenerationSpeciesDetailScreen`
Pantalla de detalle de un Pokémon específico. Muestra:

* Imagen con fondo de color generado automáticamente según el campo `color` de la API.
* Categoría (`genus`) y descripción (`flavorText`) del Pokédex.
* Secciones con detalles físicos, crecimiento, estadísticas de captura e información general.
* Un botón con flecha que navega a la siguiente evolución, si existe (obtenida consultando la cadena evolutiva completa).

---

## 📚 7. Conceptos Clave de Dart y Flutter

* **`StatelessWidget`**
  Widget que no cambia su propio estado internamente; toda la información que necesita se le pasa por su constructor.

* **`FutureBuilder`**
  Widget que espera el resultado de una operación asíncrona (`Future`, como una petición HTTP) y reconstruye la interfaz según su estado (`waiting`, `error`, `hasData`).

* **`async` / `await`**
  Permiten escribir código asíncrono de forma secuencial; `await` pausa la ejecución hasta que la operación (por ejemplo, `http.get`) termine.

* **Factory constructors** (`factory NombreClase.metodo(...)`)
  Constructores especiales que permiten devolver una instancia ya procesada, muy usados para convertir JSON en objetos.

* **`ChangeNotifier` + `Provider`**
  Patrón de manejo de estado de Flutter. Una clase extiende `ChangeNotifier` para poder ser "escuchada", y se inyecta en el árbol de widgets mediante `ChangeNotifierProvider` en `main.dart`.

* **`Navigator.push` / `Navigator.pop`**
  `push` apila una nueva pantalla encima de la actual; el botón "atrás" hace `pop`, regresando a la pantalla anterior en el historial.

* **Null safety (`?`, `??`, `!`)**
  Dart obliga a declarar explícitamente si una variable puede ser nula (`String?`). El operador `??` asigna un valor por defecto si algo es nulo, y `!` afirma que un valor no es nulo (se usa con cuidado, ya que si en verdad es nulo, la app se cierra con error).

* **`Uri.https` / `Uri.parse`**
  Clases de Dart para construir o interpretar URLs de forma segura, sin concatenar texto manualmente.

---

## 🧾 8. Fragmentos de Código Importantes

### Conversión de JSON a objeto Dart

```dart
factory GenerationItem.fromJson(Map<String, dynamic> json) {
  return GenerationItem(
    name: json['name'] ?? '',
    url: json['url'] ?? '',
  );
}
```
Este patrón se repite en todos los modelos: lee cada campo del `Map` y, si no existe, usa un valor por defecto para que la app no truene por un dato faltante.

### Extraer un id desde una URL

```dart
int get id {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  return int.parse(segments.last);
}
```
La PokeAPI no siempre entrega el id como número directo; en muchos casos solo da la URL del recurso (ej. `.../pokemon-species/25/`), así que este getter la interpreta y extrae el último segmento como id.

### Petición HTTP típica del provider

```dart
Future<http.Response> getGenerationDetail(int id) async {
  final url = Uri.https(_baseUrl, '$_apiPatch/generation/$id');
  final response = await http.get(url);
  return response;
}
```
Arma la URL, espera la respuesta del servidor y la retorna sin procesar; el procesamiento (decodificar el JSON) queda a cargo de cada pantalla.

### `FutureBuilder` para manejar estados de carga

```dart
FutureBuilder(
  future: PokeApiProvider().getGenerationDetail(generationId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      // usar snapshot.data
    }
  },
)
```
Este patrón se repite en las tres pantallas principales para mostrar un ícono de carga mientras llega la respuesta, un mensaje si algo falla, y el contenido real una vez que los datos están listos.

---
