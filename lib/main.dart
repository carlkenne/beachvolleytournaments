import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:azure_cosmosdb/azure_cosmosdb.dart' as cosmosdb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Startup name gen', home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _tournaments = <Tournament>[];
  final _biggerFont = const TextStyle(fontSize: 18);

  // experimental code for query cosmos db
  @override
  void initState() {
    super.initState();
    fetchCosmos();
  }

  void fetchCosmos() async {
    final cosmosDB = cosmosdb.Server(
        'https://beachvolleycosmos.documents.azure.com:443/', // update this
        masterKey:
            'EH4SqiJoCbpEP812IPnymBdl6CyXoLtpliE0y3R5tuGTqXeEtx8KowB2zf11PvoEpGZ4c5rjN6ETTGBPeBL7ag=='); // and update this
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

  // end experiment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Säsongskalendern"),
        ),
        body: ListView.builder(
            itemCount: _tournaments.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              return ListTile(
                  title: Text(_tournaments[i].name, style: _biggerFont),
                  trailing: Icon(Icons.favorite_outline_rounded,
                      semanticLabel: "save"),
                  onTap: () => setState(() {}));
            }));
  }
}

// change this to match cosmos tournament
class Tournament extends cosmosdb.BaseDocument {
  Tournament(this.id, this.name, this.year);

  @override
  final String id;
  String name;
  int year;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
      };

  static Tournament fromJson(Map json) {
    var dueDate = json['due-date'];
    if (dueDate != null) {
      dueDate = DateTime.parse(dueDate).toLocal();
    }
    final tournament =
        Tournament(json['Id'].toString(), json['Name'], json['Year']);

    return tournament;
  }
}
