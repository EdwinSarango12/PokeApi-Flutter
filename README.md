# Pokémon API Flutter - Proyecto
Este repositorio contiene una aplicación Flutter creada como actividad práctica. El proyecto incluye dos actividades diferenciadas que consumen APIs públicas:

- Actividad 1: Aplicación para buscar y mostrar Pokémons con todas sus características, incluida la imagen.
- Actividad 2: Implementación que utiliza una API de perros aleatorios (Random Dog) para mostrar imágenes de perros.

---
## RESULTADOS

- Enlace del video [video](https://youtube.com/shorts/_IPfgqzpzOw)
- Enlace del Apk: [apk](build/app/outputs/flutter-apk)

---

## Actividad 1 — Búsqueda y visualización de Pokémon

Descripción:

La aplicación permite buscar un Pokémon por nombre y mostrar sus características completas (tipos, estadísticas, habilidades, y la foto). Para ello consume la PokeAPI.

Endpoint usado (ejemplo):

```
https://pokeapi.co/api/v2/pokemon/ditto
```

Notas importantes:
- En la respuesta JSON, la imagen principal suele encontrarse en `sprites.front_default`.
- La API devuelve muchas propiedades (abilities, stats, types, moves, etc.). La app muestra los campos más relevantes para la actividad.

Ejemplo de flujo:
- Usuario escribe el nombre del Pokémon (por ejemplo: `ditto`).
- La app hace una petición GET a `https://pokeapi.co/api/v2/pokemon/<nombre>`.
- Se parsean los campos necesarios y se muestran en la UI junto con la imagen.

---

## Actividad 2 — API de perros aleatorios (Random Dog)

Descripción:

Para la segunda actividad se implementó una pantalla que muestra imágenes de perros aleatorios consumiendo una API pública. La API utilizada en este proyecto es la de Dog CEO (Random Dog):

Endpoint usado:

```
https://dog.ceo/api/breeds/image/random
```

Notas:
- La respuesta típica tiene la forma: `{ "message": "https://images.dog.ceo/breeds/xxx/xxx.jpg", "status": "success" }`.
- La app descarga y muestra la URL contenida en `message`.

Alternativas:
- Otra API popular es `https://random.dog/woof.json`, que también devuelve una URL de imagen/archivo para perros.

---

## Requisitos y cómo ejecutar

Requisitos previos:
- Tener Flutter instalado y configurado (SDK y herramientas). Verifica con `flutter --version`.
- Conexión a Internet (la aplicación consume APIs públicas).

Pasos para ejecutar la aplicación en tu máquina:

```powershell
cd "c:\Users\APP MOVILES\Documents\My Flutter\ES\pokemonapi_flutter\pokemonapi_flutter-main"
flutter pub get
flutter run
```

---

## Créditos

- Actividad 1: PokeAPI — https://pokeapi.co/
- Actividad 2: Dog CEO — https://dog.ceo/

---

## Descripción de la Aplicación

La aplicación consta de dos módulos principales, accesibles a través de una barra de navegación inferior:

### Actividad 1: Buscador de Pokémon
Implementación de un buscador que consume la [PokéAPI](https://pokeapi.co/).
- **Funcionalidad**: Permite al usuario ingresar el nombre de un Pokémon.
- **Endpoint utilizado**: `https://pokeapi.co/api/v2/pokemon/{nombre}`
- **Datos mostrados**:
  - Imagen (Sprite frontal)
  - Nombre
  - Altura y Peso
  - Tipos (Chips naranjas)
  - Habilidades (Chips azules)
  - Estadísticas base (HP, Attack, Defense, etc.)

### Actividad 2: Visualizador de Perros Aleatorios
Implementación de un visualizador que consume la [Dog API](https://dog.ceo/dog-api/).
- **Funcionalidad**: Muestra una imagen aleatoria de un perro cada vez que se presiona un botón.
- **Endpoint utilizado**: `https://dog.ceo/api/breeds/image/random`

## Estructura del Código

- **MainScreen**: Widget principal que gestiona la navegación entre las dos actividades usando un `BottomNavigationBar`.
- **PokemonSearch**: Widget `Stateful` que maneja la lógica de búsqueda y visualización de datos de Pokémon.
- **DogViewer**: Widget `Stateful` que realiza peticiones para obtener y mostrar imágenes de perros.

## Instrucciones de Ejecución

1. Clonar el repositorio.
2. Ejecutar `flutter pub get` para instalar las dependencias.
3. Ejecutar `flutter run` para iniciar la aplicación en un emulador o dispositivo físico.

