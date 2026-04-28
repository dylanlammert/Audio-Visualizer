
import processing.sound.*;

String fname = "18 - P.T. Adamczyk - Never Fade Away (SAMURAI Cover) - feat. Olga Jankowska.mp3";
boolean paused = false;
boolean play = false;
int x = 0;
SoundFile sample;
Waveform waveform;

int samples = 100;
float[] save;
float[][] allsave;
int totalamount = 0;
public void setup()
{
  size(640, 360);
  background(255);
  save =  new float[(samples)];

  sample = new SoundFile(this, fname);
  sample.play();

  waveform = new Waveform(this, samples);
  waveform.input(sample);
  totalamount = 60 * int(ceil(sample.duration()));
  allsave = new float[int(totalamount)][(samples)];
  println((samples * 60) * int(ceil(sample.duration())));
}

public void draw()
{
  if (paused) {
    vertexpuase();
  } else if (play) {
    vertexSave();
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
  sample.stop();
  sample.play();
  sample.rate(1);
  sample.amp(1.0);

  for (int y = 0; y < totalamount; y++)
  {
    beginShape();
    for (int i = 0; i < samples; i++)
    {
      vertex(
        map(i, 0, samples, 0, width),
        map(allsave[y][i], -1, 1, 0, height)
        );
    }
    endShape();
  }
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
      allsave[x][i] = waveform.data[i];
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
      x=0;
    } else {
      play = true;
    }
  }
}
