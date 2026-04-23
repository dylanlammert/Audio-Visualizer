class SliderH {  // horizontal slider
  int xpos, ypos;  // center position of slider
  // slider width, slider height, x position of slider start, x position of slider end, height of slider ends
  int w, h, slideStart, slideEnd, slideW, slideH;
  String label;  // text for slider
  color fillColor;
  color textColor;
  float slideX;
  float min, max;  // min value, max value
  float step;  // step size

  SliderH(String l, float low, float high, int x, int y, Section sec, float stepSize) { // x is horizonal index of slider, starting from 0; y is vertical index
    min = low;
    max = high;
    w = int(sec.controlW * .8);
    slideStart = int(sec.startX + (x * sec.controlW) + (sec.controlW * .1));
    slideEnd = slideStart + w;
    slideW = 10;
    slideH = 20;
    h = 30;
    label = l;
    xpos = int(sec.startX) + int(x * sec.controlW + sec.controlW/2);  // x pos of center of slider
    ypos = int(sec.startY + (y * sec.controlH + sec.controlH / 2));  // yposition of slider
    slideX = (min + max) / 2.0;  // start slider in center
    fillColor = color(150);
    textColor = color(255);
    step = stepSize;
  }
  
  void move(int x) { 
    float raw = map(x, slideStart, slideEnd, min, max);
    if (step > 0) {
      raw = round(raw / step) * step;
    }
    slideX = constrain(raw, min, max);
  }
  
  Boolean mouseIn() {
    if (mouseX <= slideEnd + 5 && mouseX >= slideStart - 5) {
      if (mouseY <= ypos + slideH / 2 && mouseY >= ypos - slideH / 2) {
        return true;
      }
    } return false;
  }
  
  void display() { 
    fill(fillColor);
    stroke(255);
    strokeWeight(2);
    rectMode(CENTER);
    textAlign(CENTER);
    line(slideStart, ypos, slideEnd, ypos);  // main line
    line(slideStart, ypos - 10, slideStart, ypos + 10);  // left side
    line(slideEnd, ypos - 10, slideEnd, ypos + 10);  // right side
    strokeWeight(1);
    rect(map(slideX, min, max, slideStart, slideEnd), ypos, slideW, slideH);  // rectangle to slide
    fill(textColor);
    text(label, xpos, ypos - 18);  // label
    if (step < 1) text(nf(slideX, 1, 2), xpos, ypos + 28);  // slider value with 2 decimal places
    else text(nf(slideX, 1, 0), xpos, ypos + 28); // slider value with no decimal places
  }
}
