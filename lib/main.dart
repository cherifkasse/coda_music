import 'dart:async';

import 'package:flutter/material.dart';
//Import de la classe Musique
import 'musique.dart';
//importation de audioplayer apres installation
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}
//Installation audioplayer
    //methode 1
// partir sur https://pub.dev/packages/audioplayers
//copier la ligne pour l'installation et le coller sur pubspec.yaml section dependencies
    //methode 2
//taper la commande :flutter pub add audioplayers
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Music App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Creer une liste de musique
  List<Musique> maListeDeMusiques = [
    new Musique("Theme son 1", "Modou", "images/un.jpg", "https://codabee.com/wp-content/uploads/2018/06/un.mp3"),
    new Musique("Theme son 2", "Aicha", "images/deux.jpg", "https://codabee.com/wp-content/uploads/2018/06/deux.mp3"),

  ];

   //AudioPlayer
  late AudioPlayer audioPlayer ;
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  //creer un objet Musique pour le son en cours
  late Musique maMusiqueActuelle;
  //A utiliser pour le slider
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;

  //Pour le forward
  int index = 0;

  //override initState :quand le widget sera initialisé
  @override
  void initState(){
    super.initState();
    //maMusiqueActuelle= maListeDeMusiques[0];
    maMusiqueActuelle= maListeDeMusiques[index];
    configAudioPlayer();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      //Couleur du Scaffold
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          //Changer le center en SpaceEvently
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //Texte et images
            new Card(
              elevation: 9.0,
              child:new Container(
                width: MediaQuery.of(context).size.height /2.5,
                child: new Image.asset(
                  maMusiqueActuelle.imagePath
                  //Apres cela faut arreter l'app et la relancer à cause du initState
                ),
                
              ) ,
            ),
            textAvecStyle(maMusiqueActuelle.titre, 1.5),
            textAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(
                //On cree un enum en bas pour contenir les action:play,pause...
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                boutton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                boutton((statut == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 45.0, (statut == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                boutton(Icons.fast_forward, 30.0, ActionMusic.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //textAvecStyle("0:00", 0.8),
                textAvecStyle(fromDuration(position), 0.8),
                //textAvecStyle("0:22", 0.8),
                textAvecStyle(fromDuration(duree), 0.8),
              ],

            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d){
                  setState(() {
                    Duration nouvelleDuration = new Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                    audioPlayer.seek(Duration(seconds: d.toInt()));
                  });

                }
            ),
          ],
        ),
      ),
    );
  }

  IconButton boutton(IconData icone,double taille,ActionMusic action){
    return new IconButton(
      iconSize: taille,
      color: Colors.white,
      icon: new Icon(icone),
      onPressed: () {
        switch(action){
          case ActionMusic.play:
            play();
            break;
          case ActionMusic.pause:
            pause();
            break;
          case ActionMusic.rewind:
            rewind();
            break;
          case ActionMusic.forward:
            forward();
            break;

        }

      },

    );
  }
  Text textAvecStyle(String data, double scale){
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );

  }

  void configAudioPlayer(){
    audioPlayer= new AudioPlayer();
    positionSub= audioPlayer.onPositionChanged.listen(
        (pos) => setState(() => position = pos )
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen(
        (state){
          if(state == PlayerState.playing){
            setState(() {

                duree=audioPlayer.getDuration() as Duration;


            });
          }
          else if(state == PlayerState.stopped){
            setState(() {
              statut = PlayerState.stopped;
            });
          }
        },onError: (message){
          print("Erreur: $message");
          setState(() {
            statut = PlayerState.stopped;
            duree =  new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
    }
    );

  }

  Future play() async{
    Source source = new UrlSource(maMusiqueActuelle.urlSong);
    //await audioPlayer.setSourceUrl(maMusiqueActuelle.urlSong);
    await audioPlayer.play(source);


    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async{
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward(){
    if(index == maListeDeMusiques.length - 1){
      index = 0;
    }
    else{
      index++;
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();

  }

  void rewind(){
    if(position > Duration(seconds: 3)){
      audioPlayer.seek(Duration(seconds: 0));
    }
    else{
      if(index == 0){
        index = maListeDeMusiques.length - 1;
      }else{
        index--;
      }
      maMusiqueActuelle = maListeDeMusiques[index];
      audioPlayer.stop();
      configAudioPlayer();
      play();

    }
  }
  String fromDuration(Duration duree){
    //print(duree);
    //Exemple de duree 0:00:00.145895
    return duree.toString().split('.').first;
  }
}

enum ActionMusic{
  play,
  pause,
  rewind,
  forward
}

enum EtatAudio{
  playing,
  stopped,
  paused
}
