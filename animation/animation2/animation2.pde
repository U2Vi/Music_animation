ArrayList<Cercle> test;

void setup() {
  size(800, 600);
  test = new ArrayList();
  colorMode(HSB);
  
  for (int i = 0; i < 50; i++) {
    
    float x = random(200, 600);
    float y = random(200, 400);
    
    color remplissage = color(random(255), 255, 255, 100);
    color contour = color(0, 0, 0, 1);
    
    test.add(new Cercle(x, y, 50, remplissage, contour));
  }
}


void draw() {

  background(0);
  
  for(Cercle c : test){
    
    c.affiche();
  }
  
  println(frameRate);
}


class Cercle {

  PVector position;
  float diametre;
  float phaseAleatoire;
  int nbPoints;
  float amplitude;
  int temps;
  color remplissage;
  color contour;


  Cercle(float x, float y, float diametre, color remplissage, color contour) {

    position = new PVector(x, y);
    this.diametre = diametre;
    phaseAleatoire = random(1000);
    nbPoints = 100;
    amplitude = 1;
    this.remplissage = remplissage;
    this.contour = contour;
  }


  void affiche() {

    fill(remplissage);
    stroke(contour);

    beginShape();

    PVector coordPoint;

    temps = millis();

    for (int i = 0; i < nbPoints; i++) {

      coordPoint = coordonneePoint(i);
      vertex(coordPoint.x, coordPoint.y);
    }

    endShape(CLOSE);
  }


  PVector coordonneePoint(int i) {

    float angle = (float)i / nbPoints * (2 * PI);

    float tmpX = sin(angle) * .5 + 1;
    float tmpY = cos(angle) * .5 + 1;

    float distance = diametre + (noise(tmpX, tmpY, phaseAleatoire + temps / 700.0) - .5) * diametre * amplitude;

    float x = sin(angle) * distance + position.x;
    float y = cos(angle) * distance + position.y;

    return new PVector(x, y);
  }
}