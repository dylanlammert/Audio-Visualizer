import ddf.minim.ugens.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioOutput out;
FilePlayer file;
FFT fft;
BeatDetect beat;
int vizMode = 0;
int waveAmp = 200;
int beatFlash = 0;                                          //to capture beats and fade the flash out

void setup() {
  size(640,360);
  minim = new Minim(this);
  out = minim.getLineOut();
  file = new FilePlayer(minim.loadFileStream("Clocks - Coldplay.mp3"));
  file.patch(out);                                           //sends audio to out stream for audio analyzing/hearing
  file.loop();
  fft = new FFT(out.bufferSize(), out.sampleRate());         //sets up fft to match the forward(out.mix) to eliminate errors 
  beat = new BeatDetect(out.bufferSize(), out.sampleRate());
  beat.setSensitivity(300);                                     //increase sensitivity to beats recommend 200-500
}

void draw() {
  background(0);
  fft.forward(out.mix);
  beat.detect(out.mix);
  
  switch(vizMode) {
    case 0:
      drawWave();
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
}
    
