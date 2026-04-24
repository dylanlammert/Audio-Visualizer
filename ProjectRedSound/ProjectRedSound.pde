/**
 * Processing Sound Library, Example 5
 *
 * This sketch shows how to use the FFT class to analyze a stream
 * of sound. Change the number of bands to get more spectral bands
 * (at the expense of more coarse-grained time resolution of the spectrum).
 *
 * Load this example with included sound files from the Processing Editor:
 * Examples > Libraries > Sound > Analysis > FFTSpectrum
 */

import processing.sound.*;

// Declare the sound source and FFT analyzer variables
String fname = "18 - P.T. Adamczyk - Never Fade Away (SAMURAI Cover) - feat. Olga Jankowska.mp3";
boolean paused = false;
boolean play = false;
int x = 0;
SoundFile sample;
Waveform waveform;

int samples = 100;
float[] save;
float[][] allsave;
public void setup()
{
  size(640, 360);
  background(255);
  save =  new float[(samples)];

  sample = new SoundFile(this, fname);
  sample.play();

  waveform = new Waveform(this, samples);
  waveform.input(sample);

  allsave = new float[60 * int(ceil(sample.duration()))][(samples)];
  println((samples * 60) * int(ceil(sample.duration())));
}

public void draw()
{
  if(paused){
    vertexdisplay();
  }
  else if(play){
    vertexSave();
  }
  else{
    vertexload();
    moveVideo();
  }
}

void vertexSave(){
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  sample.stop();
  sample.play();
  sample.rate(1);
  sample.amp(1.0);
  for(int x = 0; x < 60 * int(ceil(sample.duration()));x++)
  {
  for(int i = 0; i < samples; i++)
  {
       print(allsave[x][i]);
  }
  println("");
  }   
  for(int y = 0; x < 60 * int(ceil(sample.duration()));y++)
  {
  beginShape();
  for(int i = 0; i < samples; i++)
  {
    vertex(
      map(i, 0, samples, 0, width),
      map(allsave[y][i], -1, 1, 0, height)
    );
  }
  endShape();
  }
}
void vertexdisplay(){
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  
  beginShape();
  for(int i = 0; i < samples; i++)
  {
    vertex(
      map(i, 0, samples, 0, width),
      map(save[i], -1, 1, 0, height)
    );
  }
  endShape();
}
void vertexload(){
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  sample.rate(1);
  sample.amp(1.0);
  
  waveform.analyze();
  float t = sample.position();
  if(t == sample.duration())
  {
    x=0;
    sample.stop();
  }
   beginShape();
    for(int i = 0; i < samples; i++)
  {
    vertex(
      map(i, 0, samples, 0, width),
      map(waveform.data[i], -1, 1, 0, height)
    );
    allsave[x][i] = waveform.data[i];
  }
  x++;
  println(x);
    endShape();
}
void moveVideo()
{
  fill(color(0));
  rect(0, height-15, width, width);
  fill(color(255,0,0));
  float t = sample.position();
  float calcuation = (width / sample.duration())*t;
  rect(0, height-15, calcuation, width);
  if(mousePressed)
    if(mouseY >= height-15)
  {
      float timejump = (sample.duration()/width)*mouseX;
      sample.jump(timejump);
      sample.play();
  }
}
void keyReleased(){
  if (key == 'p') {
    if(paused) {
      paused = false;
      sample.play();
    } else {
      sample.pause();
      paused = true;
    }
  }
  if (key == 'v') {
    if(paused) {
      play = false;
      x=0;
    } else {
      play = true;
    }
  }
}
