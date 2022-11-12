import 'package:flutter/material.dart';
import 'package:azure_cosmosdb/azure_cosmosdb.dart' as cosmosdb;
import 'tournament.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'root', home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final _tournaments = <Tournament>[];
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  void initState() {
    super.initState();
    fetchCosmos();
  }

  void fetchCosmos() async {
    final cosmosDB = cosmosdb.Server(
        'https://beachvolleycosmos.documents.azure.com:443/',
        masterKey: 'insert here');
    final database = await cosmosDB.databases.openOrCreate('Beachvolley');
    final todoCollection = await database.collections
        .openOrCreate('Tournaments', partitionKeys: ['/year']);

    todoCollection.registerBuilder<Tournament>(Tournament.fromJson);

    print("fetching tournaments");

    // query the collection
    final tournaments = await todoCollection.query<Tournament>(cosmosdb.Query(
        'SELECT * FROM c WHERE c.Year = @year',
        params: {'@year': 2022}));

    print(tournaments);

    setState(() {
      for (var tournament in tournaments) {
        _tournaments.add(tournament);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image.asset(
        "resources/sand.png",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
          appBar: AppBar(
            title: const Text("Säsongskalendern"),
          ),
          backgroundColor: Colors.transparent,
          body: ListView.builder(
              itemCount: _tournaments.length,
              padding: const EdgeInsets.all(0.0),
              itemBuilder: (context, i) {
                if (i.isOdd) return const Divider(color: Colors.blueGrey);
                return ListTile(
                    title: Text(_tournaments[i].name, style: _biggerFont),
                    onTap: () => setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TournamentView(_tournaments[i])),
                          );
                        }));
              }))
    ]);
  }
}
