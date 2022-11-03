class Musique{
  String titre;
  String artiste;
  String imagePath;
  String urlSong;
  //Les variables peuvent signaler des erreurs puisque non initialisées mais dès qu'on fait le constructeur l'erreur est reglée
  Musique(this.titre, this.artiste, this.imagePath, this.urlSong);
}