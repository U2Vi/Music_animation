/*
To use this code, you'll have to create a "Music" file in your sketch, and put at least one music in it.
You'll have to put an image in the sketch, and put the name of the file in the "loadImage(...)" line 331.
The image will be projected on a disk in the center of the window, with a little animation
It can be used to simply play music, and get an animation reacting to it.
You also need to download the minim library from processing by ""sketch">"import library">"add a library",
then type "Minim" and click install.
*/

//loads the minim library
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
AudioMetaData meta;
FFT fft;

int trackNb = 0;    //The number of the track being played
String fileNames[];    //the names of the music files
boolean canClick;    //Boolean indicating if the click has already been counted when mousePressed is true
float readerHeight = 20;    //The height of the reader on the bottow of the window
String title;    //The title of the track being played
String author;    //The author of the track being played
PImage play;    //Image of the play button
PImage pause;    //Image of the pause button
int disapearTime = 2000;    //Time at which the UI will disapear if there's no mouse mouvement
boolean isClickedOnReader;    //Boolean indicating if the user is clicking on the reader
boolean isPaused = true;    //Boolean indicating if the song is paused

button previous;    //Previous track button
button next;    //next track button
button playPause;    //Play-pause track button

Animation animation;    //Animation with the disk made out of points


void setup() {

  size(800, 600, P3D);

  imageMode(CENTER);

  minim = new Minim(this); 

  File file = new File(sketchPath() + "/Music");
  if (file.isDirectory()) fileNames = file.list();    //Lists the names of the files in the "Music" directory

  loadSong(trackNb);    //Loads the first song

  play = loadImage("playbutton.png");
  pause = loadImage("pausebutton.png");

  //Creates the three buttons you see on the bottom of the window
  previous = new button(-150, loadImage("backwardbutton.png"));
  next = new button(150, loadImage("forwardbutton.png"));
  playPause = new button(0, play);

  animation = new Animation();
}


void draw() {

  animation.draw();    //Draws the animation of the disk made out of points

  boolean isMoving = pmouseX != mouseX || pmouseY != mouseY;    //Is the mouse moving
  boolean isOnButton = previous.isUnderCursor() || playPause.isUnderCursor() || next.isUnderCursor();    //Is the mouse on a button

  if (isMoving || isOnButton) {    //If the mouse is moving or on a button, the disapear time is reset to two seconds afterward

    disapearTime = millis() + 2000;
  }

  drawUI();    //Draws the IU

  if (!song.isPlaying() && !isPaused) {    //If the song is finished...

    if (trackNb == fileNames.length - 1) {    //...And the end of the music list is reached..

      pauseSong();    //...then pause the song...
    } else {

      loadNextSong();    //...else load the next song
    }
  }

  println(frameRate);    //Prints the frame rate, just too keep an eye on it
}


//Loads the song at the 'i'th position
void loadSong(int i) {

  if (song != null) {    //If a song is already loaded...

    if (!isPaused) {    //...and isn't paused pause the song, change it, and play it...

      song.pause();
      song = minim.loadFile("Music/" + fileNames[i]);
      song.play();
    } else {    //...else just load the song and leave it paused.

      song = minim.loadFile("Music/" + fileNames[i]);
    }
  } else {

    song = minim.loadFile("Music/" + fileNames[i]);
  }


  //Then load all the info ...
  fft = new FFT(1024, song.sampleRate());
  meta = song.getMetaData();
  title = meta.title();
  author = meta.author();
  if (title.equals("")) title = split(fileNames[i], '.')[0].replaceAll("_", " ");
  if (author.equals("")) author = "Unknown artist";
}


//Draws the UI (reader, buttons, foreground animation, title, author's name...)
void drawUI() {

  drawFFT();    //Draws the animation with the line moving to the music on the foreground
  drawPlayer();    //Draws the player at the bottom of the screen

  noStroke();
  fill(150, 150, 150, opacity());
  textSize(30);
  text(title, 10, 40);    //Prints the title on screen
  textSize(20);
  text(author, 10, 65);    //Prints the author's name on screen

  //Then draws the 3 buttons on screen
  translate(width/2, height/2);
  previous.draw();
  next.draw();
  playPause.draw();
}

//Draws the player at the bottom of the screen
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

//Draws the animation with the line moving to the music on the foreground
void drawFFT() {

  fill(255, 255, 255, 100);
  stroke(255);
  
  fft.forward(song.mix);    //Updates the FFT

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

//The class for the buttons
class button {

  float xPosition;
  PVector size;
  PImage image;
  float yDelta;    //Distance to the bottom of the screen

  button(float xPosition, PImage image) {

    this.xPosition = xPosition;
    this.size = new PVector(image.width, image.height);
    this.image = image;
    this.yDelta = size.y + readerHeight;
  }
  
  //Draws the button
  void draw() {

    tint(255, 255, 255, opacity());
    image(image, xPosition, yPosition(), size.x, size.y);
  }

  //Boolean indicating if the button is under the cursor
  boolean isUnderCursor() {

    //Square hitbox
    //boolean isInX = mouseX - width/2 >= xPosition - size.x/2 && mouseX - width/2 <= xPosition + size.x/2;
    //boolean isInY = mouseY - height/2 >= yPosition() - size.y/2 && mouseY - height/2 <= yPosition() + size.y/2;
    //return isInX && isInY

    //Round hitbox
    float distance = dist(mouseX - width/2, mouseY - height/2, xPosition, yPosition());
    return distance < size.x/2;
  }

  //Y coordinate depending on the window size, to keep it at the bottom of the window
  float yPosition() {

    return height/2 - yDelta;
  }
} 

//The opacity of the buttons and text on screen, so it can disapear when there's no activity
float opacity() {

  return constrain(disapearTime - millis(), 0, 255);
}

//Executed when the mouse is pressed
void mousePressed() {

  if (mouseButton == LEFT) {
    
    if (canClick) {
       
      if (playPause.isUnderCursor()) {    //If the user clicks on the play-pause button, it plays-pauses the music

        if (song.isPlaying()) {

          pauseSong();
        } else {

          playSong();
        }
      }
      if (previous.isUnderCursor()) {    //If the user clicks on the "previous" button, loads the previous song

        loadPreviousSong();
      }
      if (next.isUnderCursor()) {    //If the user clicks on the "next" button, loads the next song

        loadNextSong();
      }
      canClick = false;    //Clicks only once when the left button is pressed
    }

    if (mouseY > height - readerHeight) {    //If the user clicks on the reader, sets the boolean isClickedOnReader to true

      isClickedOnReader = true;
    }
  }
}


//Pause the current music
void pauseSong() {

  song.pause();
  playPause.image = play;
  isPaused = true;
}

//Play the current music
void playSong() {

  song.play();
  playPause.image = pause;
  isPaused = false;
}

//Loads the previous song
void loadPreviousSong() {

  if (trackNb > 0) {    //Does nothing if it's the first song

    trackNb--;
    loadSong(trackNb);
  }
}

//Loads the next song
void loadNextSong() {

  if (trackNb < fileNames.length - 1) {    //Does nothing if it's the last song

    trackNb++;
    loadSong(trackNb);
  }
}

//Executed when a mouse button is released
void mouseReleased() {

  if (isClickedOnReader) {    //If the user clicked on the reader to jump somewhere in the music, the jump is done when the mouse is released

    int nextPosition = round((float)mouseX / width * song.length());
    song.cue(nextPosition);
    isClickedOnReader = false;
  }

  canClick = true;
}


//This class does the animation with the disk made out of points
class Animation {

  int nbPoints;    //number of points the disk will be made of
  PVector[] points;
  color[] colors;
  PImage image;    //The image pojected on the disk
  float radiusCenter;    //the radius of the hole in the center of the disk

  Animation() {

    nbPoints = 4000;    //The disk will be made out of 4000 points
    points = new PVector[nbPoints];
    colors = new color[nbPoints];
    image = loadImage("Wooden_Tower.png");    //The image placed on the disk, if this creates an error, verify that you got an image of the same name and type in the sketch data
    radiusCenter = 400;    //Sets the radius of the hole in the center to 400

    setPointPositions();
    setPointColors();
  }

  //Draws the animation
  void draw() {

    background(song.mix.level() * 50);    //Creates the flashing effect in the background

    hint(ENABLE_DEPTH_TEST);    //This command is necessary for this animation, else the points will get in front of the User Inerface

    drawPoints();

    hint(DISABLE_DEPTH_TEST);
  }

  //Sets the position for each point in a 2D plan, the third (z) coordonate will vary with the sound level
  void setPointPositions() {

    float radius;
    float angle;

    for (int i = 0; i < nbPoints; i++) {

      angle = (i + radiusCenter) * 137.35;
      radius = sqrt(i + radiusCenter);

      float x = radius * cos(radians(angle));
      float y = radius * sin(radians(angle));

      points[i] = new PVector(x, y);
    }
  }

  //Sets the color of each point according to the image that will be on the disk
  void setPointColors() {

    image.loadPixels();

    float radius = sqrt(nbPoints + radiusCenter);    //radius of the disk

    float ratio;    //Ratio between the disk diameter and the size of the image
    if (image.width < image.height) {

      ratio = image.width / 2 / radius;
    } else {

      ratio = image.height / 2 / radius;
    }

    for (int i = 0; i < nbPoints; i++) {

      int x = int(image.width / 2 + points[i].x * ratio);
      int y = int(image.height / 2 + points[i].y * ratio);

      colors[i] = image.pixels[x + y * image.width];    //Sets the color of the point to a pixel in the image
    }
  }


  //Draws the disk made out of points
  void drawPoints() {

    pushMatrix();

    float zoom = (float)height / 150;    //The zoom varies with the height of the window
    float angleX = HALF_PI * (1 - noise(trackNb, song.position() / 7000.0));
    float angleZ = song.position() / 1000.0;    //The rotation of the disk, here one turn each ~6,3 seconds

    scale(zoom);
    translate(width/2 / zoom, height/2 / zoom);
    rotateX(angleX);
    rotateZ(angleZ);

    beginShape(POINTS);

    float amplitude = 50;

    for (int i = 0; i < nbPoints; i++) {

      points[i].z = amplitude * noise((float)i/2000, millis() * 0.001) * song.mix.level();

      stroke(colors[i]);
      vertex(points[i].x, points[i].y, points[i].z);
    }

    endShape();

    popMatrix();
  }
}
