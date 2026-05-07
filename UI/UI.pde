/**
  TODO
  -------------------
  * change buttons to work off of the overButton helper function 
    remember to change the cursor(HAND || ARROW) when overButton
  * change the playControls to fit its section




*/
float mainX, mainY, fileLauncherEndX;
Boolean paused;
Section main, progress, right, bottom, corner;
SliderH totalVol, lowVol, midVol, highVol; // total, low frequency, mid frequency, and high frequency volume
SliderH speed, pitch, reverb;
PFont font;
String active;
float progressStart, progressEnd, progressY;
float duration;
float t, scrubVal;
FileLauncherUI fileLauncher;
Theme colorTheme;
PImage openFolder;

void setup() {
  size(1600, 1000);
  surface.setResizable(true);
  //fullScreen();
  mainX = width * .8;
  mainY = height * .75;
  textAlign(CENTER);
  paused = true;
  fileLauncherEndX = 300;
  
  openFolder = loadImage("folderOpen.png");
  colorTheme = new Theme();
  fileLauncher = new FileLauncherUI(0, 0, fileLauncherEndX, height, color(40,40,40), 1, 1 );
  main = new Section(fileLauncherEndX, 0, mainX, mainY - 80, color(255, 0, 0), 1, 1);
  progress = new Section(fileLauncherEndX, main.endY, mainX, mainY, color(0), 1, 1);
  right = new Section(mainX, 0, width, height, color(0, 255, 0), 2, 2);
  bottom = new Section(fileLauncherEndX, mainY, mainX, height, color(0, 0, 255), 4, 2);
  
  progressStart = progress.endX * .2;
  progressEnd = progress.endX * .8;
  progressY = progress.startY + progress.h * .3;
  
  // top row of bottom section
  totalVol = new SliderH("Total Volume", 0, 100, 0, 0, bottom, 5);
  lowVol = new SliderH("Low Frequency Volume", 0, 100, 1, 0, bottom, 5);
  midVol = new SliderH("Mid Frequency Volume", 0, 100, 2, 0, bottom, 10);
  highVol = new SliderH("High Frequency Volume", 0, 100, 3, 0, bottom, 20);
  
  // bottom row of bottom section
  speed = new SliderH("Play Speed", .1, 2, 0, 1, bottom, .1);
  speed.slideX = 1; // start with speed at 1 instead of middle of slider
  pitch = new SliderH("Pitch", 0, 10, 1, 1, bottom, .5);
  reverb = new SliderH("Reverb", 0, 10, 2, 1, bottom, 5);
  
  duration = 120;  // replace with actual audio duration
  
  font = createFont("Arial", 18);
  textFont(font);
  
  t = 20;
  scrubVal = 10;  // amount to scrub by with forward and backward buttons
}

void draw() {
  
  fileLauncher.display();
  main.display();
  right.display();
  bottom.display();
  progress.display();
  
  totalVol.display();
  lowVol.display();
  midVol.display();
  highVol.display();
  
  speed.display();
  pitch.display();
  reverb.display();
  
  //playPause.display();
  
  if (mousePressed) {
    if (totalVol.mouseIn()  && active == "totalVol") {
      totalVol.move(mouseX);
    }
    if (lowVol.mouseIn() && active == "lowVol") {
      lowVol.move(mouseX);
    }
    if (midVol.mouseIn() && active == "midVol") {
      midVol.move(mouseX);
    }
    if (highVol.mouseIn() && active == "highlVol") {
      highVol.move(mouseX);
    }
    if (speed.mouseIn() && active == "speed") {
      speed.move(mouseX);
    }
    if (pitch.mouseIn() && active == "pitch") {
      pitch.move(mouseX);
    }
    if (reverb.mouseIn() && active == "reverb") {
      reverb.move(mouseX);
    }
  }
  
  textAlign(CENTER);
  fill(255);
  text("Main", main.centerX, main.centerY);
  text("Right", right.centerX, right.centerY);
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
  text(timeString(duration), progressEnd, progressY + 20);
  if (inProgress()) {
    float mouseT = map(mouseX, progressStart, progressEnd, 0, duration);
    text(timeString(mouseT), mouseX, progressY - 5);
    stroke(200);
    strokeWeight(3);
    line(progressStart, progressY, mouseX, progressY);
  } else text(timeString(t), map(t, 0, duration, progressStart, progressEnd), progressY - 5);
  
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
    } else {
      paused = !paused;
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
            }
        }
  
  // progress bar
  if (inProgress() && active == "progress") { 
    float mouseT = map(mouseX, progressStart, progressEnd, 0, duration);
    t = mouseT;
  } 
  
  if (inForward() && active == "forward") { 
    t = constrain(t + scrubVal, 0, duration);
  } 
  
  if (inBackward() && active == "backward") { 
    t = constrain(t - scrubVal, 0, duration);
  } 
  
  active = "";
}

void mousePressed() {
  // to ensure that dragging mouse across screen while pressed does not continue to activate other controls
  if (totalVol.mouseIn()) active = "totalVol";
  if (lowVol.mouseIn()) active = "lowVol";
  if (midVol.mouseIn()) active = "midVol";
  if (highVol.mouseIn()) active = "highlVol";
  if (speed.mouseIn()) active = "speed";
  if (pitch.mouseIn()) active = "pitch";
  if (reverb.mouseIn()) active = "reverb";
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