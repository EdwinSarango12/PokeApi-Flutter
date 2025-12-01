import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(PokemonApp());
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon API',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    PokemonSearch(),
    DogViewer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pokémon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Perros',
          ),
        ],
      ),
    );
  }
}

class PokemonSearch extends StatefulWidget {
  @override
  _PokemonSearchState createState() => _PokemonSearchState();
}

class _PokemonSearchState extends State<PokemonSearch> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _pokemonList = [];
  Map<String, dynamic>? _selectedPokemon;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPokemonList();
  }

  Future<void> fetchPokemonList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedPokemon = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=50'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        setState(() {
          _pokemonList = results.map((p) {
            final url = p['url'] as String;
            // Extract ID from URL (e.g., .../pokemon/1/)
            final id = url.split('/')[6];
            return {
              'name': p['name'],
              'url': url,
              'image':
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar la lista.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Verifica tu internet.';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchPokemonDetails(String nameOrId) async {
    if (nameOrId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${nameOrId.toLowerCase().trim()}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _selectedPokemon = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Pokémon no encontrado. Intenta con otro nombre.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Verifica tu internet.';
        _isLoading = false;
      });
    }
  }

  void _goBack() {
    setState(() {
      _selectedPokemon = null;
      _controller.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If a Pokemon is selected, show the Detail View
    if (_selectedPokemon != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_selectedPokemon!['name'].toString().toUpperCase()),
          backgroundColor: Colors.redAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDetailCard(),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _goBack,
                icon: Icon(Icons.home),
                label: Text('Volver al Inicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Otherwise, show the List/Search View
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchPokemonList,
            tooltip: 'Refrescar lista',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon (ej. ditto)',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => fetchPokemonDetails(_controller.text),
                ),
              ),
              onSubmitted: (value) => fetchPokemonDetails(value),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _pokemonList.length,
                  itemBuilder: (context, index) {
                    final pokemon = _pokemonList[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () => fetchPokemonDetails(pokemon['name']),
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.network(
                                pokemon['image'],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                pokemon['name'].toString().toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              _selectedPokemon!['sprites']['front_default'] ?? '',
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.image_not_supported, size: 100),
            ),
            SizedBox(height: 10),
            _buildDetailRow('Altura', '${_selectedPokemon!['height'] / 10} m'),
            _buildDetailRow('Peso', '${_selectedPokemon!['weight'] / 10} kg'),
            SizedBox(height: 10),
            Text(
              'Tipos:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: (_selectedPokemon!['types'] as List)
                  .map((t) => Chip(
                        label: Text(t['type']['name']),
                        backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                      ))
                  .toList(),
            ),
            SizedBox(height: 10),
            Text(
              'Habilidades:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: (_selectedPokemon!['abilities'] as List)
                  .map((a) => Chip(
                        label: Text(a['ability']['name']),
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      ))
                  .toList(),
            ),
            SizedBox(height: 10),
            Text(
              'Estadísticas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Column(
              children: (_selectedPokemon!['stats'] as List).map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['stat']['name'].toString().toUpperCase(),
                          style: TextStyle(fontSize: 12)),
                      Text(s['base_stat'].toString(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class DogViewer extends StatefulWidget {
  @override
  _DogViewerState createState() => _DogViewerState();
}

class _DogViewerState extends State<DogViewer> {
  List<String> _dogImages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchDogFeed();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchDogFeed();
      }
    });
  }

  Future<void> fetchDogFeed() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://dog.ceo/api/breeds/image/random/10');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> newImages = List<String>.from(data['message']);
        setState(() {
          _dogImages.addAll(newImages);
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar imágenes.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener imágenes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Perros',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 0, 0, 0),
              const Color.fromARGB(255, 0, 0, 0)
            ],
          ),
        ),
        child: _dogImages.isEmpty && _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 100, bottom: 20),
                itemCount: _dogImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _dogImages.length) {
                    return _isLoading
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ))
                        : SizedBox.shrink();
                  }
                  return DogPost(imageUrl: _dogImages[index]);
                },
              ),
      ),
    );
  }
}

class DogPost extends StatefulWidget {
  final String imageUrl;

  const DogPost({required this.imageUrl});

  @override
  _DogPostState createState() => _DogPostState();
}

class _DogPostState extends State<DogPost> {
  bool _isLiked = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (optional, could be breed name if parsed)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.pets, color: Colors.grey),
                ),
                SizedBox(width: 10),
                Text(
                  'Doggo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(),
                Icon(Icons.more_horiz),
              ],
            ),
          ),
          // Image
          GestureDetector(
            onDoubleTap: _toggleLike,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(0), // Square image style or rounded?
              // Let's keep it slightly rounded or square. Instagram is square usually.
              // But user asked for "sheets" which might imply rounded cards.
              // Let's go with no border radius for the image itself inside the card.
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 400,
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 400,
                  color: Colors.grey[200],
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.black,
                    size: 30,
                  ),
                  onPressed: _toggleLike,
                ),
                SizedBox(width: 10),
                Icon(Icons.chat_bubble_outline, size: 28),
                SizedBox(width: 15),
                Icon(Icons.send, size: 28),
                Spacer(),
                Icon(Icons.bookmark_border, size: 30),
              ],
            ),
          ),
          // Likes count (fake)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _isLiked ? '1,001 Me gusta' : '1,000 Me gusta',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
