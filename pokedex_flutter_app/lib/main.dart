import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex Gen 7',
      home: PokedexPage(),
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
                  return PokemonCard(
                      name: pokemonList[index]['name'],
                      number: (index + 722).toString());
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
