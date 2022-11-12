import 'package:flutter/material.dart';
import 'models.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TournamentView extends StatefulWidget {
  final Tournament tournament;

  const TournamentView(this.tournament, {super.key});

  @override
  State<TournamentView> createState() => TournamentViewState();
}

class TournamentViewState extends State<TournamentView> {
  TournamentViewState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
      ),
      body: WebView(
          initialUrl: 'https://www.profixio.com/fx/${widget.tournament.link}'),
    );
  }
}
