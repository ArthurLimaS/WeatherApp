import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pag = 0;
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum('Recife');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (pag == 0){
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30,),
                  const Text(
                    "Digite o nome da cidade",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: TextField(
                      onSubmitted: (value) {
                        setState(() {
                          pag = 1;
                          futureAlbum = fetchAlbum(value);
                        });
                      },
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Digite aqui',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                ],
              )
            );
          } else {
            return FutureBuilder<Album>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 30,),
                        Text(
                          'Cidade: ${snapshot.data!.cidade}',
                          style: const TextStyle( 
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                        const SizedBox(height: 30,),
                        Text(
                          'Pais: ${snapshot.data!.country}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                        const SizedBox(height: 30,),
                        Text(
                          'Clima: ${snapshot.data!.clima}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                        const SizedBox(height: 30,),
                        Text(
                          'Temperatura: ${snapshot.data!.temperatura}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                      ],
                    ),
                  );
                  
                  
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            pag = 0;
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.arrow_back),
      )
    );
  }
}

class Album {
  final cidade;
  final temperatura;
  final clima;
  final country;

  const Album({
    required this.cidade,
    required this.temperatura,
    required this.clima,
    required this.country
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    String cid = json['name'];

    Map<String, dynamic> main = json['main'];
    double tem = main['temp'];

    List<dynamic> weather = json['weather'];
    var weather_2 = weather[0];
    String cli = weather_2['main'];
    
    Map<String, dynamic> sys = json['sys'];
    String cou = sys['country'];

    return Album(
      //userId: json['userId'],
      //id: json['id'],
      //title: json['title'],
      cidade: cid,
      temperatura: tem,
      clima: cli,
      country: cou
    );
  }
}

Future<Album> fetchAlbum(String city) async {
  final response = await http
      .get(Uri.parse('https://weather.contrateumdev.com.br/api/weather/city/?city=$city'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}