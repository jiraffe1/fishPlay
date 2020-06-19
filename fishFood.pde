class fishFood {
  float nutrition = 5;
  float x;
  float y;
  
  fishFood(float x_, float y_) {
    this.x = x_;
    this.y = y_;
  }
  
  void display() {
    strokeWeight(0.3);
    fill(0,130,0);
    ellipse(this.x, this.y, 4,4);
  }
}
