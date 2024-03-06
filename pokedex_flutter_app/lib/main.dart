import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex Gen 7',
      home: PokedexPage(),
      routes: {
        '/info': (context) => PokemonInfoPage(),
      },
    );
  }
}

class PokedexPage extends StatefulWidget {
  @override
  _PokedexPageState createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  List pokemonList = [];

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  fetchPokemon() async {
    var res = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=80&offset=721'));
    var decodedRes = jsonDecode(res.body);
    print(decodedRes);
    setState(() {
      pokemonList = decodedRes['results'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gen 7', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF45dccc).withOpacity(0.7),
                Color(0xFF2f8480).withOpacity(0.7),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF45dccc),
              Color(0xFF2f8480),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Stack(
            children: <Widget>[
              ListView.builder(
                itemCount: pokemonList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/info',
                        arguments: PokemonInfoArguments(
                          pokemonName: pokemonList[index]['name'],
                          pokemonNumber: (index + 722).toString(),
                        ),
                      );
                    },
                    child: PokemonCard(
                        name: pokemonList[index]['name'],
                        number: (index + 722).toString()),
                  );
                },
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF6ABCFF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: PokemonSearchDelegate(pokemonList),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final String name;
  final String number;

  PokemonCard({required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Color(0xFFEC4C42),
            shadowColor: Color(0xFF4B1A22),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${number}.png'),
              ),
              title: Text(
                name,
                style: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: -18,
            left: 18,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF4B1A22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#$number',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonInfoArguments {
  final String pokemonName;
  final String pokemonNumber;

  PokemonInfoArguments(
      {required this.pokemonName, required this.pokemonNumber});
}

//Aun no se ve como quiero asi que, aunque no tenga nota luego probablemente modifique la clase PokemonInfoPage

class PokemonInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PokemonInfoArguments args =
        ModalRoute.of(context)!.settings.arguments as PokemonInfoArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.pokemonName),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF45dccc),
              Color(0xFF2f8480),
            ],
          ),
        ),
        child: FutureBuilder(
          future: Future.wait([
            http.get(Uri.parse(
                'https://pokeapi.co/api/v2/pokemon/${args.pokemonNumber}')),
            http.get(Uri.parse(
                'https://pokeapi.co/api/v2/pokemon-species/${args.pokemonNumber}')),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              var pokemonData = jsonDecode((snapshot.data as List)[0].body);
              var pokemonSpeciesData =
                  jsonDecode((snapshot.data as List)[1].body);
              var pokemonTypes = pokemonData['types']
                  .map((typeData) => typeData['type']['name'])
                  .toList();
              var pokemonDescription = pokemonSpeciesData['flavor_text_entries']
                      .firstWhere((entry) => entry['language']['name'] == 'en')[
                  'flavor_text'];

              return ListView(
                children: [
                  Stack(
                    children: [
                      SvgPicture.network(
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png', //COMO HAGO QUE FUNCIONE EL SVG NI PONIENDOLO LOCAL AGARRA ME QUIERO VOLVER CHANGO
                        height: 100,
                      ),
                      Card(
                        color: typeColors[pokemonTypes.first] ?? Colors.grey,
                        child: Column(
                          children: [
                            Image.network(
                                pokemonData['sprites']['front_default']),
                            Text('Height: ${pokemonData['height']}'),
                            Text('Weight: ${pokemonData['weight']}'),
                            Text('Type: ${pokemonTypes.first}'),
                            Text('Description: $pokemonDescription'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class PokemonSearchDelegate extends SearchDelegate {
  final List pokemonList;

  PokemonSearchDelegate(this.pokemonList);

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.transparent,
      textTheme: TextTheme(
        headline6: TextStyle(color: Colors.black, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(pokemonList[index]['name']),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List suggestions = query.isEmpty
        ? pokemonList
        : pokemonList
            .where((pokemon) => pokemon['name'].startsWith(query))
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]['name']),
          onTap: () {
            query = suggestions[index]['name'];
            showResults(context);
          },
        );
      },
    );
  }
}

Map<String, Color> typeColors = {
  'water': Color(0xFF4169E1), // RoyalBlue
  'steel': Colors.grey,
  'bug': Color(0xFF9ACD32), // YellowGreen
  'dragon': Colors.indigo,
  'electric': Colors.yellow,
  'ghost': Colors.purple,
  'fire': Colors.red,
  'fairy': Colors.pink,
  'ice': Colors.cyan,
  'fighting': Colors.brown,
  'normal': Colors.grey,
  'grass': Colors.green,
  'psychic': Colors.pink,
  'rock': Colors.brown,
  'dark': Colors.brown,
  'ground': Colors.brown,
  'poison': Colors.purple,
};
