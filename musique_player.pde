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
int disapearTime = 3000;
boolean isClickedOnReader;
boolean isPaused = true;

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
  
  frameRate(400);
}


void draw() {

  background(0); 

  boolean isMoving = pmouseX != mouseX || pmouseY != mouseY;
  boolean isOnButton = previous.isUnderCursor() || playPause.isUnderCursor() || next.isUnderCursor();

  if (isMoving || isOnButton) {

    disapearTime = millis() + 2000;
  }
  drawUI();

  if (!song.isPlaying() && !isPaused) {

    if (trackNb == fileNames.length - 1) {

      pauseSong();
    } else {

      loadNextSong();
    }
  }
  
  println(frameRate);
}


void loadSong(int i) {

  if (song != null) {

    if (!isPaused) {

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
  fill(150, 150, 150, opacity());
  textSize(30);
  text(title, 10, 40);
  textSize(20);
  text(author, 10, 65);

  translate(width/2, height/2);
  previous.draw();
  next.draw();
  playPause.draw();
}

void drawPlayer() {

  fill(100, 100, 100, 100);
  noStroke();

  if (isClickedOnReader) {

    rect(0, height, mouseX, -readerHeight);
  } else {

    float readingPos = (float)song.position() / song.length() * width;
    rect(0, height, readingPos, -readerHeight);
  }
}

void drawFFT() {

  fill(255, 255, 255, 100);
  stroke(255);
  
  //if (song.isPlaying()) fft.forward(song.mix);
  fft.forward(song.mix);
  
  beginShape();

  vertex(0, height - readerHeight);
  vertex(0, height - readerHeight - 2);

  for (int i = 0; i < fft.specSize()/4; i++) {

    curveVertex( i * width/(fft.specSize()/4), height - readerHeight - 2 - fft.getBand(i));
  }

  vertex(width, height - readerHeight - 2);
  vertex(width, height - readerHeight);

  endShape();
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

    tint(255, 255, 255, opacity());
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

float opacity() {

  return constrain(disapearTime - millis(), 0, 255);
}

void mousePressed() {

  if (canClick) {
    if (playPause.isUnderCursor()) {

      if (song.isPlaying()) {

        pauseSong();
      } else {
        
        playSong();
      }
    }
    if (previous.isUnderCursor()) {

      loadPreviousSong();
    }
    if (next.isUnderCursor()) {

      loadNextSong();
    }
    canClick = false;
  }

  if (mouseY > height - readerHeight) {

    isClickedOnReader = true;
  }
}

void pauseSong() {

  song.pause();
  playPause.image = play;
  isPaused = true;
}

void playSong() {

  song.play();
  playPause.image = pause;
  isPaused = false;
}

void loadPreviousSong() {

  if (trackNb > 0) {

    trackNb--;
    loadSong(trackNb);
  }
}

void loadNextSong() {

  if (trackNb < fileNames.length - 1) {

    trackNb++;
    loadSong(trackNb);
  }
}

void mouseReleased() {

  if (isClickedOnReader) {

    int nextPosition = round((float)mouseX / width * song.length());
    song.cue(nextPosition);
    isClickedOnReader = false;
  }

  canClick = true;
}
