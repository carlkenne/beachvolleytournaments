import 'package:azure_cosmosdb/azure_cosmosdb.dart' as cosmosdb;

class Tournament extends cosmosdb.BaseDocument {
  Tournament(this.id, this.name, this.year, this.link);

  @override
  final String id;
  final String name;
  final String? link;
  final int year;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
        'link': link,
      };

  static Tournament fromJson(Map json) {
    var dueDate = json['due-date'];
    if (dueDate != null) {
      dueDate = DateTime.parse(dueDate).toLocal();
    }
    final tournament = Tournament(
        json['Id'].toString(), json['Name'], json['Year'], json['Link']);

    return tournament;
  }
}
