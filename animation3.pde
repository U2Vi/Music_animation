Point fog[] = new Point[1000];

Cercle mesCercles[];

String[] valeurs;

int temps = 0;

String[] lignes;
int specSize;

//coordonées de la camera
float camX;
float camY;
float camZ;
float fovY;
float fovX;


void setup() {

  size(1920, 1080, P3D);

  //coordonées par défaut de la camera
  camX = width/2;
  camY = height/2;
  camZ = (height/2) / tan(PI/6);
  fovY = PI/3;
  fovX = 2 * atan(width/2 / camZ);

  for (int i = 0; i < fog.length; i++) {

    fog[i] = new Point(random(camZ));
  }

  mesCercles = new Cercle[100];

  for (int i = 0; i < mesCercles.length; i++) {

    float x = width/2;
    float y = height/2;
    color remplissage = color(255, map(i, 0, mesCercles.length-1, 0, 200), 0, 100);

    int band = (int)map(i, 0, mesCercles.length-1, 0, 100);

    mesCercles[i] = new Cercle(x, y, 50, remplissage, band);
  }

  lignes = loadStrings("FFT_kaaris_charge.txt");

  frameRate(60);

  specSize = split(lignes[0], '/').length;
}

void draw() {

  int frame = frameCount;

  if (frame < lignes.length) {

    valeurs = split(lignes[frame], '/');

    background(0);

    for (Point p : fog) {

      float d = dist(p.x, p.y, p.z, camX, camY, camZ);    //la distance du point a la camera

      strokeWeight(2000 / (tan(fovY) * d));    //l'épaisseur du point en fonction de la distance a la camera

      stroke(p.couleur);
      point(p.x, p.y, p.z);

      p.z += parseFloat(valeurs[0]) / 10000;    //On fait avancer le point dans la coordonnée Z (vers la camera) en fonction du niveau sonore
      p.x += .5 * (noise(2, p.phase + temps / 1000.0) - .5);
      p.y += .5 * (noise(3, p.phase + temps / 1000.0) - .5);

      //Calcul des angles en X et Y entre la caméra et le points pour déterminer s'il est dans le champ de vision
      float angleX = atan((p.x-camX) / (p.z-camZ));
      float angleY = atan((p.y-camY) / (p.z-camZ));

      if (abs(angleY) > fovY/2 || abs(angleX) > fovX/2 || p.z > camZ) {    //Si un point est en dehors du champ de vision, alors il est supprimé et un autre point est crée

        p.reset();
      }
    }

    hint(DISABLE_DEPTH_TEST);

    noStroke();
    
    temps ++;
    for (Cercle c : mesCercles) {

      c.affiche();
    }

    fill(0);
    ellipse(camX, camY, 100, 100);

    println(frameRate);

    hint(ENABLE_DEPTH_TEST);

    println(frameRate);

    saveFrame("movie/frame-########.tif");
    
  } else {
    
    exit();
  }
}


class Point {

  float x;
  float y;
  float z;
  color couleur;
  float phase;    //Phase aléatoire dont sera déduite la vitesse du point

  Point(float z) {

    x = random(width);
    y = random(height);
    this.z = z;
    couleur = color(255, random(50, 200), 0, 255);    //couleur dans les tons chauds (orange-jaunatre)
    phase = random(100);
  }

  void reset() {

    x = random(width);
    y = random(height);
    z = 0;
  }
}


class Cercle {

  PVector position;
  float diametre;
  float phaseAleatoire;
  int nbPoints;
  color remplissage;
  int band;
  float smooth;
  float amplitude;

  Cercle(float x, float y, float diametre, color remplissage, int band) {
    
    position = new PVector(x, y);
    this.diametre = diametre;
    phaseAleatoire = random(100);
    nbPoints = 500;
    this.remplissage = remplissage;
    this.band = band;
    smooth = 20;
    amplitude = .05;
  }


  void affiche() {

    fill(remplissage);

    beginShape();

    PVector coordPoint;

    for (int i = 0; i < nbPoints; i++) {

      coordPoint = coordonneePoint(i);
      vertex(coordPoint.x, coordPoint.y);
    }

    endShape();
  }


  PVector coordonneePoint(int i) {

    float angle = (float)i / nbPoints * TWO_PI;

    float tmpX = sin(angle) * smooth + 1;
    float tmpY = cos(angle) * smooth + 1;

    float distance = diametre + noise(tmpX, tmpY, phaseAleatoire + temps / 10000.0) * diametre * parseFloat(valeurs[band]) / 1000 * amplitude;

    float x = sin(angle) * distance + position.x;
    float y = cos(angle) * distance + position.y;

    return new PVector(x, y);
  }
}