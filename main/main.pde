/**
  TODO
  -------------------
  * change buttons to work off of the overButton helper function 
    remember to change the cursor(HAND || ARROW) when overButton
  * change the playControls to fit its section




*/
float mainX, mainY, fileLauncherEndX;
Section main, progress, right, bottom, corner;
SliderH totalVol, lowVol, midVol, highVol; // total, low frequency, mid frequency, and high frequency volume
SliderH speed, totalReverb, lowReverb, midReverb, highReverb;
Button mode1, mode2, mode3, mode4, mode5;
PFont font;
String active;
float progressStart, progressEnd, progressY;
float duration;
float t, scrubVal;
FileLauncherUI fileLauncher;
Theme colorTheme;
PImage openFolder;
PFont headerFont, roboto;
AudioController ac;

Minim minim;
AudioOutput out;
AudioPlayer player;
FilePlayer file;
FFT fft;
BeatDetect beat;
int vizMode = 5;
int waveAmp = 200;
int beatFlash = 0;//to capture beats and fade the flash out
float[] save;
float[] allsave;
int totalamount = 0;
boolean paused = false;
boolean layout = false;
boolean mousepress = false;
boolean start = false;
int count = 1000;
float secondTime = 0;
int movecursor = 0;
int x = 0;
float startX = 0.0,endX = 0.0;
boolean click = true;
float mainsectionY = 0.0;


void setup() {
  size(1600, 1000);
  surface.setResizable(true);
  //fullScreen();
  mainX = width * .8;
  mainY = height * .75;
  // text setup
  headerFont = createFont("Jersey10Charted-Regular.ttf", 18);
  roboto = createFont("RobotoMono-VariableFont_wght.ttf", 14);
  textAlign(CENTER);
  paused = false;
  fileLauncherEndX = 300;
  
  
  openFolder = loadImage("folderOpen.png");
  colorTheme = new Theme();
  fileLauncher = new FileLauncherUI(0, 0, fileLauncherEndX, height, color(40,40,40), 1, 1 );
  main = new Section(fileLauncherEndX, 0, mainX, mainY - 80, color(255, 0, 0), 1, 1);
  progress = new Section(fileLauncherEndX, main.endY, mainX, mainY, color(0), 1, 1);
  right = new Section(mainX, 0, width, progress.endY, color(0, 255, 0), 1, 5);
  bottom = new Section(fileLauncherEndX, mainY, width, height, color(0, 0, 255), 5, 2);
  
  int progressBuffer = int(progress.w * .1);
  progressStart = progress.startX + progressBuffer;
  progressEnd = progress.endX -progressBuffer;
  progressY = progress.startY + progress.h * .3;
  
  // top row of bottom section
  totalVol = new SliderH("Total Volume", 0, 100, 0, 0, bottom, 5);
  lowVol = new SliderH("Low Frequency Volume", 0, 100, 1, 0, bottom, 5);
  midVol = new SliderH("Mid Frequency Volume", 0, 100, 2, 0, bottom, 10);
  highVol = new SliderH("High Frequency Volume", 0, 100, 3, 0, bottom, 20);
  speed = new SliderH("Play Speed", .1, 2, 4, 0, bottom, .1);
  speed.slideX = 1; // start with speed at 1 instead of middle of slider
  
  // bottom row of bottom section
  totalReverb = new SliderH("Total Reverb", 0, 10, 0, 1, bottom, 1);
  lowReverb = new SliderH("Low Frequency Reverb", 0, 10, 1, 1, bottom, 1);
  midReverb = new SliderH("Mid Frequency Reverb", 0, 10, 2, 1, bottom, 1);
  highReverb = new SliderH("High Frequency Reverb", 0, 10, 3, 1, bottom, 1);
  
  // buttons in right section
  mode1 = new Button("Wave", 0, 0, right);
  mode2 = new Button("WaveDraw", 0, 1, right);
  mode3 = new Button("FFT", 0, 2, right);
  mode4 = new Button("Circle", 0, 3, right);
  mode5 = new Button("Beat", 0, 4, right);
  
  font = createFont("Arial", 18);
  textFont(font);
  
  

  t = 20;
  scrubVal = 5000;  // amount to scrub by with forward and backward buttons


  
}

void draw() {
  
  fileLauncher.display();
  right.display();
  bottom.display();
  progress.display();
  
  totalVol.display();
  lowVol.display();
  midVol.display();
  highVol.display();
  
  speed.display();
  
  mode1.display();
  mode2.display();
  mode3.display();
  mode4.display();
  mode5.display();
  
   fill(color(0,0,0));
    rectMode(CORNER);
    rect(fileLauncherEndX,0,mainX - 300,mainsectionY);
  if(start)
  {
    
    fft.forward(out.mix);
    beat.detect(out.mix);
    t = file.position();
    t = ac.get_time();
    switch(vizMode) {
      case 0:
       if(layout)
        {
          file.pause();
          displayWave();
          if(click)show();
        }
        else if(paused)
        {
          file.pause();
          pauseWave();
        }
        else{
          drawWave();
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
  }
  //playPause.display();

 
  
  if (mousePressed) {
    if (totalVol.mouseIn()  && active == "totalVol") {
      totalVol.move(mouseX);
      float val = map(totalVol.slideX, totalVol.min, totalVol.max, 0, 1);
      println("total", val);
      ac.masterGain(val);
    }
    if (lowVol.mouseIn() && active == "lowVol") {
      lowVol.move(mouseX);
      lowVol.move(mouseX);
      float val = map(lowVol.slideX, lowVol.min, lowVol.max, 0, 1);
      println("low", val);
      ac.lowGain(val);
    }
    if (midVol.mouseIn() && active == "midVol") {
      midVol.move(mouseX);
      midVol.move(mouseX);
      float val = map(midVol.slideX, midVol.min, midVol.max, 0, 1);
      println("mid", val);
      ac.midGain(val);
    }
    if (highVol.mouseIn() && active == "highlVol") {
      highVol.move(mouseX);
      highVol.move(mouseX);
      float val = map(highVol.slideX, highVol.min, highVol.max, 0, 1);
      println("high", val);
      ac.highGain(val);
    }
    if (speed.mouseIn() && active == "speed") {
      speed.move(mouseX);
      float val = map(speed.slideX, speed.min, speed.max, 0, 2);
      println("speed", val);
      ac.set_speed(val);
    }
    // if (pitch.mouseIn() && active == "pitch") {
    //   pitch.move(mouseX);
    // }
    if (totalReverb.mouseIn() && active == "totalReverb") {
      totalReverb.move(mouseX);
      float val = map(totalReverb.slideX, totalReverb.min, totalReverb.max, 0, 1);
      println("totalReverb", val);
      ac.masterReverb(val);
    }
    if (lowReverb.mouseIn() && active == "lowReverb") {
      lowReverb.move(mouseX);
      float val = map(lowReverb.slideX, lowReverb.min, lowReverb.max, 0, 1);
      println("lowReverb", val);
      ac.lowReverb(val);
    }
    if (midReverb.mouseIn() && active == "midReverb") {
      midReverb.move(mouseX);
      float val = map(midReverb.slideX, midReverb.min, midReverb.max, 0, 1);
      println("midReverb", val);
      ac.midReverb(val);
    }
    if (highReverb.mouseIn() && active == "highReverb") {
      highReverb.move(mouseX);
      float val = map(highReverb.slideX, highReverb.min, highReverb.max, 0, 1);
      println("highReverb", val);
      ac.highReverb(val);
    }
  }
  
  textAlign(CENTER);
  fill(255);
  //text("Bottom", bottom.centerX, bottom.centerY);
  
  // progress bar
  stroke(150);
  strokeWeight(3);
  line(progressStart, progressY, progressEnd, progressY);

  
  // progress controls
  fill(255);
  noStroke();
  if (paused) {
    triangle(progress.centerX - 10, progressY + 10, progress.centerX - 10, progressY + 35, progress.centerX + 11, progressY + 22.5);
  } else {
    rectMode(CORNER);
    rect(progress.centerX - 10, progressY + 10, 5, 25);
    rect(progress.centerX + 5, progressY + 10, 5, 25);
  }
  
  // skip forward
  triangle(progress.centerX + 25, progressY + 15, progress.centerX + 25, progressY + 30, progress.centerX + 35, progressY + 22.5);
  triangle(progress.centerX + 35, progressY + 15, progress.centerX + 35, progressY + 30, progress.centerX + 45, progressY + 22.5);
  // skip backward
  triangle(progress.centerX - 25, progressY + 15, progress.centerX - 25, progressY + 30, progress.centerX - 35, progressY + 22.5);
  triangle(progress.centerX - 35, progressY + 15, progress.centerX - 35, progressY + 30, progress.centerX - 45, progressY + 22.5);
  
  // progress bar text
  text("0:00", progressStart, progressY + 20);
  text(timeString(duration/1000), progressEnd, progressY + 20);
  if (inProgress()) {
    float mouseT = map(mouseX, progressStart, progressEnd, 0, duration);
    text(timeString(mouseT/1000), mouseX, progressY - 5);
    stroke(200);
    strokeWeight(3);
    line(progressStart, progressY, mouseX, progressY);
  } else text(timeString(t/1000), map(t, 0, duration, progressStart, progressEnd), progressY - 5);
  
  // current progress line
  stroke(255);
  line(progressStart, progressY, map(t, 0, duration, progressStart, progressEnd), progressY);
  
  // reset stroke and stroke weight
  stroke(0);
  strokeWeight(1);
  
}

String timeString(float t) {
  int minutes = int(t / 60);
  int seconds = int(t % 60);
  return minutes + ":" + nf(seconds, 2);
}

Boolean inProgress() {
  return (mouseX >= progressStart && mouseX <= progressEnd && mouseY >= progressY - 4 && mouseY <= progressY + 4);
}

Boolean inPause() {
  return (mouseX <= progress.centerX + 10 && mouseX >= progress.centerX - 10 && mouseY <= progressY + 35 && mouseY >= progressY + 10);
}

Boolean inForward() {
  return (mouseX <= progress.centerX + 45 && mouseX >= progress.centerX + 25 && mouseY <= progressY + 30 && mouseY >= progressY + 15);
}

Boolean inBackward() {
  return (mouseX >= progress.centerX - 45 && mouseX <= progress.centerX - 25 && mouseY <= progressY + 30 && mouseY >= progressY + 15);
}

/**
  @brief helper function to determine if the user is hovering over a button
  @param int left this is the box's starting x 
  @param int top this is the box's starting y
  @param int diameter the diameter of a circle button initialized to -1 if it is a rect button
  @param int boxLength this is the width of the box set to -1 if circle
  @param int boxHeight this is the box height set to -1 if circle
*/
boolean overButton(int left, int top, int diameter, int boxLength, int boxHeight) {
        float disX = left - mouseX;
        float disY = top - mouseY;
        if(boxLength == -1){
            if (sqrt(sq(disX) + sq(disY)) < diameter/2) {
              return true;
            
            }else return false;
        }else {
            if(mouseX >= left && mouseX <= left + boxLength){
            if(mouseY >= top && mouseY <= top + boxHeight) {
              return true;

            }else return false;
            } else return false;
        }
  
}

void mouseReleased() {

  // pause button
  if (inPause() && active == "pause") {
    if (paused) {
      paused = !paused;
      file.play();
      ac.pause();
    } else {
      ac.pause();
      paused = !paused;
    }
  }
  if (mode1.mouseIn()) {
     vizMode = 0;
  }
  if(mode3.mouseIn()){
    vizMode =1;
  }
  if(mode4.mouseIn()){
    vizMode =2;
  }
  if(mode5.mouseIn()){
    vizMode =3;
  }
  if(mode2.mouseIn()){
    vizMode = 0;
    if(!paused){
      ac.pause();
    }
    layout = !layout;
    if(!layout) {
      file.play();
    }
  }
  
  if(overButton(fileLauncher.currentButtonX, fileLauncher.currentButtonY, -1, fileLauncher.currentButtonWidth, fileLauncher.currentButtonHeight)){
            switch(fileLauncher.currentButton) {
                case("open file button"):
                  println("you are selecting a new folder");
                  fileLauncher.selectFunction();
                  break;
                case("new project"):
                  println("opening new project");
                  fileLauncher.selectFunction();
                  break;
                case("individual file"):
                  fileLauncher.currentFile = fileLauncher.potentialCurrentFile;
                  println("current file: " + fileLauncher.currentFile.getAbsolutePath());
                  if(start)
                  {
                    file.close();
                    minim.stop();
                    minim.stop();
                    
                  }
                  mainsectionY = mainY - 80;
                  minim = new Minim(this);
 
                  frameRate(60);
                  out = minim.getLineOut();
                  file = new FilePlayer(minim.loadFileStream(fileLauncher.currentFile.getAbsolutePath()));
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
                  vizMode = 0;
                  duration = floor(file.length() - 12000);
                  start = true;
                  Gain mute = new Gain(-60);
                  file.patch(mute);
                  ac = new AudioController(this);
                  ac.loadSong(fileLauncher.currentFile.getAbsolutePath());
                  ac.masterReverb(0);
                  ac.lowReverb(0);
                  ac.midReverb(0);
                  ac.highReverb(0);
                  duration = ac.get_duration();  // replace with actual audio duration
                  break;
                  
            }
        }
  
  // progress bar
  if (inProgress() && active == "progress") { 

    
    float time = map(mouseX, progressStart, progressEnd, 0, file.length());
    x = floor(map(mouseX, progressStart, progressEnd, 0, totalamount));
    file.cue(int(time));
    ac.jump(time);
    
  } 
  
  if (inForward() && active == "forward") { 
    //t = constrain(t + scrubVal, 0, duration);
    ac.offset_time((int)scrubVal);
  } 
  
  if (inBackward() && active == "backward") { 
    //t = constrain(t - scrubVal, 0, duration);
    println("t", t);
    ac.offset_time((int)-scrubVal);
  } 
  
  active = "";
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
    ac.pause();
    paused = !paused;
    if(!paused) file.play();
  }
  if(key == 'v'){
    if(!paused){
      ac.pause();
    }
    layout = !layout;
    if(!layout) {
      file.play();
    }
  }
    if (key == 'd') {
    count += 10000;
    if(count > allsave.length) count = allsave.length -10000;
  }
  if (key == 'a') {
    count -= 10000;
    if(count < 0) count = 0;
  }
}
void mousePressed() {
  // to ensure that dragging mouse across screen while pressed does not continue to activate other controls
  if (totalVol.mouseIn()) active = "totalVol";
  if (lowVol.mouseIn()) active = "lowVol";
  if (midVol.mouseIn()) active = "midVol";
  if (highVol.mouseIn()) active = "highlVol";
  if (speed.mouseIn()) active = "speed";
  if (inPause()) active = "pause";
  if (inProgress()) active = "progress";
  if (inForward()) active = "forward";
  if (inBackward()) active = "backward";
}
/*
void fileSelected(File selection) {
        if(selection == null) {
            println("Window has closed or the user hit cancel.");
        } else{
          fileLauncher.currentFile = selection.getAbsolutePath();
            println("User selected" + selection.getAbsolutePath());
        }
    }
*/
void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    // set the accessableFiles array
    fileLauncher.setAccessableFiles(fileLauncher.getFolderContents(selection));
    // set currentFolder path to selection.getAbsoulutePath
    fileLauncher.currentFolder = selection;
    // grab all audio files from within the folder
  }
}

/**

*/
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  // if mouse is over the fileLauncher UI then allow manipulation of mouseWheel
  
  // if mouse current scroll position is within bounds of array then allow manipulation
  fileLauncher.scroll(e);
  // if
}
void drawWave() {
  stroke(255);
  strokeWeight(2);
  noFill();
  if(!file.isPlaying()) x=0;
  for (int i = 0; i < out.bufferSize() -1; i++) {
    float x1 = map(i, 0, out.bufferSize(),fileLauncherEndX,  mainX);
    float x2 = map(i+1, 0, out.bufferSize(), fileLauncherEndX,  mainX);
    float y1 = mainsectionY/2 + out.left.get(i) * waveAmp;
    float y2 = mainsectionY/2 + out.left.get(i+1) * waveAmp;
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
  for (int i = 0; i < out.bufferSize() -1; i++) {
    float x1 = map(i, 0, out.bufferSize(), fileLauncherEndX,  mainX);
    float x2 = map(i+1, 0, out.bufferSize(),fileLauncherEndX,  mainX);
    float y1 = mainsectionY/2 + allsave[count + i] * waveAmp;
    float y2 = mainsectionY/2 + allsave[count + i+1] * waveAmp;
    line(x1, y1, x2, y2);
  }
}
void pauseWave(){
  stroke(255);
  strokeWeight(2);
  noFill();
   for (int i = 0; i < out.bufferSize() -1; i++) {
    float x1 = map(i, 0, out.bufferSize(),fileLauncherEndX,  mainX);
    float x2 = map(i+1, 0, out.bufferSize(), fileLauncherEndX,  mainX);
    float y1 = mainsectionY/2 + save[i] * waveAmp;
    float y2 = mainsectionY/2 + save[i+1] * waveAmp;
    line(x1, y1, x2, y2);
   }
}

void show()
{
  fill(color(255));
  rectMode(CORNER);
  rect(fileLauncherEndX, mainsectionY - 15,  mainX-300, 15);
  fill(color(255, 0, 0));
  fill(color(98,98,98));
  rect(movecursor + fileLauncherEndX ,mainsectionY-15,20,15);
  if (mousePressed)
  {
    if (mouseY >= (mainsectionY-15) && mouseY <= mainsectionY && mouseX >= fileLauncherEndX && mouseX <=  mainX-20)
    {
      click = true;
      movecursor = mouseX - int(fileLauncherEndX) ;
      int check = (allsave.length/int(mainX-300))*movecursor;
      if(check < 0) 
      {
      count =0;
      }
      else if(check > allsave.length)
      {
        count = allsave.length -20000;
      }
      else {
      count = check;
      }
    }
  }
  /*
  if(layout && mousepress)
  {
    noFill();
    stroke(255,0,0);
    rect(startX,0,endX,mainsectionY);
    println(startX,endX);
  }
  */
}
void drawFFT() {
  stroke(255);
  for (int i = 0; i < fft.specSize(); i++) {                              //fft.specSize returns the length of the array of the FFT out.mix
    float x = map(i, 0, fft.specSize(),fileLauncherEndX ,  mainX);
    float h = fft.getBand(i) * 50;
    line(x, mainsectionY, x, mainsectionY -h);
  }
}

void drawCircle() {
  pushMatrix();
  translate( mainX/2, mainsectionY/2);
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
