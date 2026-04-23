class Section {
  float startX, startY, endX, endY, centerX, centerY;
  float w, h, controlW, controlH; // controlW and controlH are based on the number of horizontal and vertical subsections
  color c;
  
  Section(float sx, float sy, float ex, float ey, color col, int x, int y) {  // x is number of horizontal sub-sections, y is number of vertical sub-sections
    startX = sx;
    startY = sy;
    endX = ex;
    endY = ey;
    
    w = endX - startX;
    h = endY - startY;
    
    controlW = w / x;
    controlH = h / y;
    
    centerX = startX + (w / 2);
    centerY = startY + (h / 2);
    
    c = col;
  }
  
  void display() {
    rectMode(CORNER);
    fill(c);
    rect(startX, startY, w, h);
  }
}
