import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
AudioMetaData meta;
FFT fft;

int trackNb = 0;
String fileNames[];
boolean canClick;
float readerHeight = 20;
String title;
String author;
PImage play;
PImage pause;

button previous;
button next;
button playPause;


void setup() {

  size(800, 600);

  imageMode(CENTER);

  minim = new Minim(this);

  File file = new File(sketchPath() + "/Musiques");
  if (file.isDirectory()) fileNames = file.list();

  loadSong(trackNb);

  play = loadImage("playbutton.png");
  pause = loadImage("pausebutton.png");

  previous = new button(-150, loadImage("backwardbutton.png"));
  next = new button(150, loadImage("forwardbutton.png"));
  playPause = new button(0, play);
}


void draw() {

  background(0); 

  drawUI();
}


void loadSong(int i) {
  
  if(song != null) {
    
    if(song.isPlaying()){
      
      song.pause();
      song = minim.loadFile("Musiques/" + fileNames[i]);
      song.play();
    } else {
       
      song = minim.loadFile("Musiques/" + fileNames[i]);
    }
  } else {
    
    song = minim.loadFile("Musiques/" + fileNames[i]);
  }
  
  fft = new FFT(1024, song.sampleRate());
  meta = song.getMetaData();
  title = meta.title();
  author = meta.author();
  if (title.equals("")) title = split(fileNames[i], '.')[0].replaceAll("_", " ");
  if (author.equals("")) author = "Unknown artist";
}


void drawUI() {
  
  drawFFT();
  drawPlayer();
  
  noStroke();
  fill(200);
  textSize(30);
  text(title, 10, 40);
  textSize(20);
  text(author, 10, 65);

  translate(width/2, height/2);
  previous.draw();
  next.draw();
  playPause.draw();
}

void drawPlayer(){
  
  fill(100, 100, 100, 100);
  noStroke();
  
  float readingPos = (float)song.position() / song.length() * width;
  rect(0, height, readingPos, -readerHeight);
  
  
}

void drawFFT() {
  
  fill(255, 255, 255, 100);
  stroke(255);
  if(song.isPlaying()) fft.forward(song.mix);
  
  beginShape();
  
  vertex(0, height - readerHeight);
  vertex(0, height - readerHeight - 2);
  
  for (int i = 0; i < fft.specSize()/4; i++){
    
    curveVertex( i * width/(fft.specSize()/4), height - readerHeight - 2 - fft.getBand(i));
  }
  
  vertex(width, height - readerHeight - 2);
  vertex(width, height - readerHeight);
  
  endShape(CLOSE);
}


class button {

  float xPosition;
  PVector size;
  PImage image;
  float yDelta;

  button(float xPosition, PImage image) {

    this.xPosition = xPosition;
    this.size = new PVector(image.width, image.height);
    this.image = image;
    this.yDelta = size.y + readerHeight;
  }

  void draw() {

    image(image, xPosition, yPosition(), size.x, size.y);
  }

  boolean isUnderCursor() {

    //boolean isInX = mouseX - width/2 >= xPosition - size.x/2 && mouseX - width/2 <= xPosition + size.x/2;
    //boolean isInY = mouseY - height/2 >= yPosition() - size.y/2 && mouseY - height/2 <= yPosition() + size.y/2;

    float distance = dist(mouseX - width/2, mouseY - height/2, xPosition, yPosition());
    return distance < size.x/2;
  }

  float yPosition() {

    return height/2 - yDelta;
  }
}

void mousePressed() {

  if (canClick) {
    if (playPause.isUnderCursor()) {
      
      if(song.isPlaying()){
        
        song.pause();
        playPause.image = play;
      } else {
        
        song.play();
        playPause.image = pause;
      }
    }
    if (previous.isUnderCursor()) {

      if (trackNb > 0) {

        trackNb--;
        loadSong(trackNb);
      }
    }
    if (next.isUnderCursor()) {

      if (trackNb < fileNames.length - 1) {

        trackNb++;
        loadSong(trackNb);
      }
    }
    canClick = false;
  }
}

void mouseReleased() {

  canClick = true;
}