class Button {
  int xpos, ypos;  // center position of button
  int w, h;  // button width, button height
  String label;  // text for button
  color fillColor;
  color textColor;

  Button(String l, int x, int y, Section sec) {  // x is index of button, starting from 0, y is vertical index; secW is the section width
    w = 80;
    h = w / 2;
    label = l;
    xpos = int(sec.startX) + int(x * sec.controlW + sec.controlW/2);  // x pos of center of slider
    ypos = int(sec.startY + (y * sec.controlH + sec.controlH / 2));  // yposition of slider
 
    fillColor = color(150);
    textColor = color(255);
  }
  
  Boolean mouseIn() {
    if (mouseX <= xpos + w / 2 && mouseX >= xpos - w / 2) {
      if (mouseY <= ypos + h / 2 && mouseY >= ypos - h / 2) {
        return true;
      }
    } return false;
  }
  void display() {
    fill(fillColor);
    stroke(0);
    strokeWeight(1);
    rectMode(CENTER);
    textAlign(CENTER);
    rect(xpos, ypos, w, h, 10);
    fill(textColor);
    text(label, xpos, ypos + 4);
  }
}
