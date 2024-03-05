import 'package:flutter/material.dart';

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

class PokedexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex - Generation 7'),
      ),
      body: ListView(
        children: <Widget>[
          PokemonCard(name: 'Decidueye', number: '724'),
          PokemonCard(name: 'Incineroar', number: '727'),
          PokemonCard(name: 'Primarina', number: '730'),
          // Add more Pokemon cards here
        ],
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
    return Card(
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
        subtitle: Text(
          'Pokemon #$number',
          style: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
        ),
        trailing: Icon(
          Icons.search,
          color: Color(0xFF6ABCFF),
        ),
      ),
    );
  }
}
