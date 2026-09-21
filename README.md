
#Crear Modelos
El modelo es la clase que "traduce" el JSON crudo que llega de la API a un
objeto Dart que puedas usar cómodamente

#Generar los metodos:
fromRawJson
FromJson
Qué hace cada parte:**
- `fromRawJson`: recibe el `String` crudo (el `body` de la respuesta HTTP) y lo decodifica.
- `fromJson`: recibe ya un `Map<String, dynamic>` y arma el objeto, con valores por defecto (`?? 0`, `?? ''`) para evitar errores si algo viene nulo.

Generar metodo del proveedor
El provider es el único lugar que sabe hablar con la API. La pantalla nunca
llama a `http.get` directamente, siempre pasa por aquí

Generar la ventana