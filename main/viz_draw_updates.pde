//add to global variables
float circleHue = 0;                                              
boolean isPaused() {
    return !file.isPlaying();
}
//add to setup
  fft.logAverages(22,3);
  smoothCircle = new float[fft.specSize()];

//add to draw to get visuals to pause with audio
  if (!isPaused()) {
    updateAudioAnalysis();
    updateCircleData();
  }
  renderVisuals();

//add-this came out of draw
void renderVisuals() {                                                             //moved out of draw to allow for pausing with audio
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
}
//add this
void updateAudioAnalysis() {
  if (isPaused()) return;
  fft.forward(out.mix);
  beat.detect(out.mix);
}
//overwrite current drawFFT
void drawFFT() {
  background(0);
  int bars = 40;  
  int binW = max(1,fft.avgSize() / bars);
  float barWidth = width / (float) bars;
  int index = 0;
  for (int i = 0; i < fft.avgSize(); i += binW) {
    float avg = 0;
    for (int j = i; j < i + binW; j++) {
      avg += fft.getAvg(j);
    }
    avg /= binW;
    float x = fileLauncherEndX +index * barWidth;
    float h = avg * 6;
    float freq = fft.getAverageCenterFrequency(i);
    if (freq < 100) fill(0, 0, 255);                                                      // bass
    else if (freq < 200) fill(0, 127, 255);                                               //split up bass for more diversity
    else if (freq < 500) fill(0, 255, 127);                                               // low mids
    else if (freq < 2000) fill(128, 255, 0);                                              // mids
    else if (freq < 5000) fill(255, 255, 0);                                              // high mids
    else fill(255, 127, 0);                                                               // highs
    noStroke();
    strokeWeight(2);
    rect(x, mainsectionY+main.h, barWidth - 2, -h);
    index++;
  }
}
//add 
void updateCircleData() {
  if (isPaused()) return;

  for (int i = 0; i < fft.specSize(); i++) {
    smoothCircle[i] = lerp(smoothCircle[i], fft.getBand(i), 0.15);
  }
}
//overwrite current drawCircle
void drawCircle() {
  pushStyle();
  colorMode(HSB, 255);                                          
  fill(circleHue, 255, 40, 40);                                         //load in brighter colors
  noStroke();
  rect(fileLauncherEndX,mainsectionY, main.w, main.h);                  //colors background to match circle with a soft glow
  pushMatrix();                                                         //begin design for circle
  translate(fileLauncherEndX+main.w/2, mainsectionY+main.h/2);                    //move (0,0) to center of main window
  float bass = getBass();                                               //detect bass
  scale(1 + bass * 0.0005);
  float rotator = isPaused() ? 0 : frameCount * .002;                   //pauses rotation
  rotate(rotator);                                                      //rotates circle
  circleHue += 0.3;                                                     //gradually change hue over time 
  if (circleHue > 255) {                                                //resets hue to 0 at end of cycle
    circleHue = 0;
  }
  stroke(circleHue, 255, 255, 40);                                      // glow layer
  strokeWeight(12);
  fill(circleHue, 255, 255, 80);
  beginShape();
  for (int i = 0; i < fft.specSize(); i += 2) {
    float radian = map(i, 0, fft.specSize(), 0, TWO_PI);
    float r = 75 + smoothCircle[i] * 2;
    float x = cos(radian) * r;
    float y = sin(radian) * r;
    curveVertex(x, y);
  }
  endShape(CLOSE);

  stroke(circleHue, 255, 255);                                          //edge circle- same cirlce not opaque and a sharper edge
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < fft.specSize(); i += 2) {
    float radian = map(i, 0, fft.specSize(), 0, TWO_PI);
    float r = 75 + smoothCircle[i] * 2;
    float x = cos(radian) * r;
    float y = sin(radian) * r;
    curveVertex(x, y);
  }
  endShape(CLOSE);
  colorMode(RGB, 255);                                                //switch color mode back
  popMatrix();
  popStyle();
}
//overwrite drawBeat
void drawBeat() {
  background(0);
  float target = 0;                                                 //set target to build flash up to 
  if (beat.isKick()) {
    target = 255;
  }
  beatFlash = lerp(beatFlash, target, 0.2);                         //lerp towards target and not leap  
  beatFlash *= 0.95;                                                //fades out flash
  background(beatFlash, 0, 0);
}

//add
float getBass() {
  float bass = 0;
  int bassBands = 10;
  for (int i = 0; i < bassBands; i++) {
    bass += fft.getBand(i);
  }
  return bass/bassBands;
}


