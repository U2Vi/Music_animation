import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;

Point fog[] = new Point[3500];

//coordonées de la camera
float camX;
float camY;
float camZ;
float fovY;
float fovX;


void setup(){
  
  size(1600, 850, P3D);
  
  //coordonées par défaut de la camera
  camX = width/2;
  camY = height/2;
  camZ = (height/2) / tan(PI/6);
  fovY = PI/3;
  fovX = 2 * atan(width/2 / camZ);
  
  minim = new Minim(this);
  song = minim.loadFile("kaaris_charge.mp3");
  song.play();
  
  
  for(int i = 0; i < fog.length; i++){
    
    fog[i] = new Point(random(camZ));
  }
  
}

void draw(){
  
  background(0);
  
  for(Point p : fog){
    
    float d = dist(p.x, p.y, p.z, camX, camY, camZ);    //la distance du point a la camera
    
    strokeWeight(1000 / (tan(fovY) * d));    //l'épaisseur du point en fonction de la distance a la camera
    
    stroke(p.couleur);
    point(p.x, p.y, p.z);
    
    p.z += song.mix.level() * 20;    //On fait avancer le point dans la coordonnée Z (vers la camera) en fonction du niveau sonore
    p.x += .5 * (noise(2, p.phase + millis() / 1000.0) - .5);
    p.y += .5 * (noise(3, p.phase + millis() / 1000.0) - .5);
    
    //Calcul des angles en X et Y entre la caméra et le points pour déterminer s'il est dans le champ de vision
    float angleX = atan((p.x-camX) / (p.z-camZ));
    float angleY = atan((p.y-camY) / (p.z-camZ));
    
    if(abs(angleY) > fovY/2 || abs(angleX) > fovX/2 || p.z > camZ){    //Si un point est en dehors du champ de vision, alors il est supprimé et un autre point est crée
      
      p.reset();
    }
  }
  
  println(frameRate);
}


class Point{
  
  float x;
  float y;
  float z;
  color couleur;
  float phase;    //Phase aléatoire dont sera déduite la vitesse du point
  
  Point(float z){
    
    x = random(width);
    y = random(height);
    this.z = z;
    couleur = color(255, random(50, 200), 0, 255);    //couleur dans les tons chauds (orange-jaunatre)
    phase = random(100);
  }
  
  void reset(){
    
    x = random(width);
    y = random(height);
    z = 0;
  }
}
