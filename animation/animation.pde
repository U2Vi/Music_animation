PVector foyer1 = new PVector(100, 300);
PVector foyer2 = new PVector(700, 300);


void setup() {
  size(800, 600);
  background(0);
  loadPixels();
  colorMode(HSB);
}


void draw() {

  for ( int x = 0; x < width; x++) {
    
    for (int y = 0; y < height; y++) {
      
      PVector position = new PVector(x, y);

      float distance = dist(foyer1.x, foyer1.y, position.x, position.y) + dist(foyer2.x, foyer2.y, position.x, position.y);

      if (distance < 700) {

        pixels[int(position.y * width + position.x)] = color(noise(position.x / 10, position.y / 10, millis() / 3000.0) * 255, 255, 255);
      }
    }
  }
  updatePixels();
}