import ddf.minim.*;
import ddf.minim.analysis.*;

//aucune idée de ce que c'est un minim ... mais on est obligé d'en déclarer un pour charger des musiquesb
Minim minim;
//un Audioplayer, c'est un son pour faire simple (ou une musique bien sur)
AudioPlayer song;
//le FFT, objet contenant le tableau des amplitudes des fréquences
FFT fft;


/*
minim = new Minim(this);    //A faire dans le setup pour ensuite pouvoir charger des musiques
song = minim.loadFile("kaaris_charge.mp3");    //charge une musique depuis le sketch

song.length();    //retourne la longueur (en millisecondes) de la musique
song.cue(*temps*);    //va a un temps donné en paramètre (en millisecondes) dans la musique
song.position();    //retourne la position de la lecture de la musique (toujours en millisecondes)
song.isPlaying();    //booléen retournant true si la musique joue
song.play(*temps*);    //joue la musique a partir
song.play()    //joue la musique a partir du début - reprends la musique après l'avoir mise en pause
song.pause();    //pause la musique
song.mix.level();    //retourne le miveau sonore de la musique

fft = new FFT(1024, song.sampleRate());    //créer le fft, a faire des qu'une musique est chargée
fft.forward(song.mix);    //actualise le tableau des fréquences sur la musique
fft.specSize();    //taille du tableau des fréquences
fft.getBand(*index*);    //retourne la valeur a l'indice donné en paramètre dans le tableau des fréquences
*/


//example
void setup(){
  
  size(800, 600);
  
  minim = new Minim(this);
  song = minim.loadFile("kaaris_charge.mp3");
  fft = new FFT(1024, song.sampleRate());
  
  song.play();
  
  stroke(255);
}

void draw(){
  
  background(0);
  
  fft.forward(song.mix);
  
  for(int i = 0; i < fft.specSize(); i++){
    
    line((float)i / fft.specSize() * width, height, (float)i / fft.specSize() * width, height - fft.getBand(i));
  }
}