import ddf.minim.ugens.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioOutput out;
AudioPlayer player;
FilePlayer file;
FFT fft;
BeatDetect beat;
int vizMode = 0;
int waveAmp = 200;
int beatFlash = 0;//to capture beats and fade the flash out
float[] save;
float[] allsave;
int totalamount = 0;
boolean paused = false;
boolean layout = false;
int count = 1000;
float secondTime = 0;
int movecursor = 0;
int x = 0;


void setup() {
  size(640,360);
  minim = new Minim(this);
      frameRate(60);
  out = minim.getLineOut();
  file = new FilePlayer(minim.loadFileStream("18 - P.T. Adamczyk - Never Fade Away (SAMURAI Cover) - feat. Olga Jankowska.mp3"));
  file.patch(out);                                           //sends audio to out stream for audio analyzing/hearing
  file.loop();

  fft = new FFT(out.bufferSize(), out.sampleRate());         //sets up fft to match the forward(out.mix) to eliminate errors 
  beat = new BeatDetect(out.bufferSize(), out.sampleRate());
  beat.setSensitivity(300);    //increase sensitivity to beats recommend 200-500
  secondTime = file.length()/1000.00;
  totalamount = 60*out.bufferSize() * int(ceil(secondTime));
  save = new float[out.bufferSize()];
  allsave = new float[int(totalamount)];
  x=0;
}

void draw() {
  background(0);
  fft.forward(out.mix);
  beat.detect(out.mix);
  
  switch(vizMode) {
    case 0:
      if(paused)
      {
        file.pause();
        pauseWave();
      }
      else if(layout)
      {
        file.pause();
        displayWave();
        show();
      }
      else{
        drawWave();
        moveVideo();
      }
      break;
    case 1:
      drawFFT();
      break;
    case 2:
      drawCircle();
      break;
    case 3:
      drawBeat();
      break;
  }
  //put in something to show mode selected
}

void drawWave() {
  stroke(255);
  strokeWeight(2);
  noFill();
  for (int i = 0; i < out.bufferSize() -1; i++) {
    float x1 = map(i, 0, out.bufferSize(), 0, width);
    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
    float y1 = height/2 + out.left.get(i) * waveAmp;
    float y2 = height/2 + out.left.get(i+1) * waveAmp;
    line(x1, y1, x2, y2);
    save[i] = out.left.get(i);
    allsave[x] = out.left.get(i);
    x++;
  }
   
}
void displayWave() {
  stroke(255);
  strokeWeight(2);
  noFill();
  //println(file.position());
  for (int i = 0; i < out.bufferSize() -1; i++) {
    float x1 = map(i, 0, out.bufferSize(), 0, width);
    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
    float y1 = height/2 + allsave[count + i] * waveAmp;
    float y2 = height/2 + allsave[count + i+1] * waveAmp;
    line(x1, y1, x2, y2);
  }
}
void pauseWave(){
  stroke(255);
  strokeWeight(2);
  noFill();
   for (int i = 0; i < out.bufferSize() -1; i++) {
    float x1 = map(i, 0, out.bufferSize(), 0, width);
    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
    float y1 = height/2 + save[i] * waveAmp;
    float y2 = height/2 + save[i+1] * waveAmp;
    line(x1, y1, x2, y2);
   }
}
void moveVideo()//Show video display
{
  noFill();
  noStroke();
  fill(color(0));
  rect(0, height-15, width, width);
  fill(color(255, 0, 0));
  float t = file.position()/1000.00;
  if(!file.isPlaying()) x=0;
  println(x);  float calcuation = (width / secondTime)*t;
  rect(0, height-15, calcuation, width);
  if (mousePressed)
  if (mouseY >= height-15)
  {
    int timejump = floor((secondTime/width)*mouseX) * 1000;
    //x = floor((totalamount/width)*mouseX);
    file.cue(timejump);
  }
}
void show()
{
  fill(color(255));
  rect(0, height-45, width, 15);
  fill(color(255, 0, 0));
  fill(color(98,98,98));
  rect(movecursor,height-45,10,15);
  if (mousePressed)
  {
    if (mouseY >= (height-45) && mouseY <= height-25 && mouseX >= 0 && mouseX <= width)
    {
      movecursor = mouseX;
      count = (allsave.length/width)*movecursor;
    }
  }
}
void drawFFT() {
  stroke(255);
  for (int i = 0; i < fft.specSize(); i++) {                              //fft.specSize returns the length of the array of the FFT out.mix
    float x = map(i, 0, fft.specSize(), 0, width);
    float h = fft.getBand(i) * 50;
    line(x, height, x, height -h);
  }
}

void drawCircle() {
  pushMatrix();
  translate(width/2, height/2);
  for (int i = 0; i <fft.specSize(); i++) {
    float radian = map(i, 0, fft.specSize(), 0, TWO_PI);                  //set up radian circle to draw on
    float r = 100 + fft.getBand(i) * 2;                                   //retrieves amplitude of the frequency band
    float x = cos(radian) * r;
    float y = sin(radian) * r;
    stroke(255);
    line(0, 0, x, y);
  }
  popMatrix();
}

void drawBeat() {
  if (beat.isKick()) {
    beatFlash = 255;
  } else if (beat.isSnare()) {
    beatFlash = 255;
  } else {
    background(beatFlash, 0, 0);
    beatFlash *= 0.9;                                                 // fade out to be able to visualize it 
  }
}

void keyPressed() {
  if (key == '0') {
    vizMode = 0;
  }else if (key == '1') {
    vizMode = 1;
  }else if (key == '2') {
    vizMode = 2;
  }else if (key == '3') {
    vizMode = 3;
  }
  if(key == 'p'){
    paused = !paused;
    if(!paused) file.play();
  }
  if(key == 'v'){
    layout = !layout;
  }
    if (key == 'd') {
    count += 10000;
    if(count > allsave.length) count -= allsave.length;
  }
  if (key == 'a') {
    count -= 10000;
    if(count < 0) count = 0;
  }
}
    
