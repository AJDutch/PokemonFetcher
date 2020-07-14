import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home : MyHomePage()
      )
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int generationIndex = 0;
  static int pokemonIndex = 0;
  String dropdownValue = 'One';
  List<String> pokemonDropDownList = ['One', 'Two', 'Free', 'Four','Seven'];
  String generationDropDownValue = 'One';
  List<String> generationDropDownList = ['One', 'Two', 'Free', 'Four','Seven'];
  Map<String,dynamic> pokemonDataFromGeneration;
  Map<String,dynamic> generationData;
  SplayTreeMap<int,String> pokemonDataSorted = new SplayTreeMap<int,String>();
  String pokemonImageURL;


  @override
  void initState() {
    super.initState();
    setState(() {
      getGenerationdata();
      LoadImage(pokemonIndex);
    });
  }

  Future<String> getGenerationdata() async {
    var response = await http.get(
        Uri.encodeFull("https://pokeapi.co/api/v2/generation"),
        headers: {
          "Accept" : "application/json"
        }
    );
    generationData = json.decode(response.body);
    setState(() {
      updateGenerationDropdown(generationData);
    });
  }

  void loadGeneration()
  {
    setState(() {
      getPokemonData(generationData["results"][generationIndex]["url"]);
    });
  }

  Future<String> getPokemonData(String sGeneration) async {
    var response = await http.get(
        Uri.encodeFull(sGeneration),
        headers: {
          "Accept" : "application/json"
        }
    );
    setState(() {
      pokemonDataFromGeneration = json.decode(response.body);
      updateDropdown(pokemonDataFromGeneration);
    });
  }

  updateDropdown(Map<String,dynamic> data) {
    pokemonDropDownList.clear();
    pokemonDataSorted.clear();
    List<String> bleh;
    for(int i = 0; i < (data["pokemon_species"]).length; i++){
      String temp = data["pokemon_species"][i]["url"];
      bleh = temp.split('/');
      pokemonDataSorted.putIfAbsent(int.parse(bleh.asMap()[6]), () => (bleh.asMap()[6]) + " " + data["pokemon_species"][i]["name"]);

    }
    setState(() {
      pokemonDataSorted.forEach((key, value) {
        pokemonDropDownList.add(value);
      });
      dropdownValue = pokemonDropDownList[pokemonIndex];
      LoadImage(pokemonDataSorted.firstKey());
    });

  }
  updateGenerationDropdown(Map<String,dynamic> data) {
    generationDropDownList.clear();
    for(int i = 0; i < (data["results"]).length ; i++){
      generationDropDownList.add(data["results"][i]["name"]);
    }
    generationDropDownValue = generationDropDownList[generationIndex];
    setState(() {
    getPokemonData(data["results"][generationIndex]["url"]);
    LoadImage(generationIndex);
    });
  }


  void LoadImage(int index) {
//    data[]
  setState(() {
    pokemonImageURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" + (index).toString() + ".png";
  });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose that Pokemon", textDirection: TextDirection.ltr,),
      ),
      body:
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children : [
                    DropdownButton<String>(
                      value: generationDropDownValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          generationDropDownValue = newValue;
                          generationIndex = generationDropDownList.indexOf(newValue);
                          pokemonIndex = 0;
                          loadGeneration();
                        });
                      },
                      items: generationDropDownList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;

                          pokemonDataSorted.forEach((key, value) {
                            if (value == newValue){
                              pokemonIndex = key;
                            }
                          });
                          LoadImage(pokemonIndex);
                        });
                      },
                      items: pokemonDropDownList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),



                    ]
                ),
                ],
              ),
              Image.network(
                pokemonImageURL,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),

            ],
          )
          );
      // This trailing comma makes auto-formatting nicer for build methods.
  }
}
