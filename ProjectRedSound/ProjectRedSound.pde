
import processing.sound.*;
String fname = "18 - P.T. Adamczyk - Never Fade Away (SAMURAI Cover) - feat. Olga Jankowska.mp3";
boolean paused = false;
boolean play = false;
int x = 0;
SoundFile sample;
Waveform waveform;
int count = 0;
int samples = 100;
float[] save;
float[] allsave;
int totalamount = 0;
int movecursor = 0;
public void setup()
{
  size(640, 360);
  background(255);
  save =  new float[(samples)];

  sample = new SoundFile(this, fname);
  sample.play();

  waveform = new Waveform(this, samples);
  waveform.input(sample);
  frameRate(30);
  totalamount = 30 * int(ceil(sample.duration()));
  allsave = new float[int(totalamount)];
}

public void draw()
{
  if (paused) {
    vertexpuase();
  } else if (play) {
    vertexSave();
    show();
  } else {
    vertexload();
    moveVideo();
  }
}

void vertexSave() {
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  
  beginShape();
for (int i = 0; i < samples; i++)
    {
     vertex(
       map(i, 0, samples, 0, width),
       map(allsave[i+count], -1, 1, 0, height)
       );
    }
  endShape();
}
void vertexpuase() {
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();

  beginShape();
  for (int i = 0; i < samples; i++)
  {
    vertex(
      map(i, 0, samples, 0, width),
      map(save[i], -1, 1, 0, height)
      );
  }
  endShape();
}
void vertexload() {
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  sample.rate(1);
  sample.amp(1.0);

  waveform.analyze();
  float t = sample.position();
  if (t != 0)
  {
    beginShape();
    for (int i = 0; i < samples; i++)
    {
      vertex(
        map(i, 0, samples, 0, width),
        map(waveform.data[i], -1, 1, 0, height)
        );
      allsave[x] = waveform.data[i];
      save[i] = waveform.data[i];
    }
    x++;
    println(x);
    endShape();
    println(t);
  } else
  {
  }
}
void moveVideo()
{
  noFill();
  noStroke();
  fill(color(0));
  rect(0, height-15, width, width);
  fill(color(255, 0, 0));
  float t = sample.position();
  float calcuation = (width / sample.duration())*t;
  rect(0, height-15, calcuation, width);
  if (mousePressed)
  if (mouseY >= height-15)
  {
    float timejump = floor((sample.duration()/width)*mouseX);
    x = floor((totalamount/width)*mouseX);
    sample.jump(timejump);
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
      println(count);
    }
  }
}
void keyReleased() {
  if (key == 'p') {
    if (paused) {
      paused = false;
      sample.play();
    } else {
      sample.pause();
      paused = true;
    }
  }
  if (key == 'v') {
    if (paused) {
      play = false;
      sample.pause();
      x=0;
    } else {
      play = true;
    }
  }
  if (key == 'd') {
    count += 10;
    println(count);
  }
  if (key == 'a') {
    count -= 10;
  }
  if(key == 'w'){
    if(samples == 500)
    {
      samples = 500;
    }
    else{
      samples += 100;
    }
  }
  if(key== 's'){
    if(samples == 0){
      samples = 0;
    }
    else{
    samples -= 100;
    }
  }
}
