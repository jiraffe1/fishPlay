int[] generations = new int[50];
Flock flock;
Sharks sharkSwarm;
ArrayList<fishFood> theFood;


void setup() {
  size(1600, 1000);
  flock = new Flock();
  sharkSwarm = new Sharks();
  theFood = new ArrayList<fishFood>();

  // Add an initial set of fish
  for (int i = 0; i < 1; i++) {
    flock.addBoid(new Boid(width/2, height/2, 1));
  }

  for ( int i = 0; i < 500; i++) {
    theFood.add(new fishFood(random(width), random(height)));
  }
}

void draw() {
  background(70, 170, 255);
  flock.run();
  sharkSwarm.run();

  for (fishFood f : theFood) {
    f.display();
  }

  while (theFood.size() < 500) {
    theFood.add(new fishFood(random(width), random(height)));
  }
  
  while(flock.boids.size() == 0) {
    flock.boids.add(new Boid(random(width), random(height), 1));
  }
  
  stroke(0);
  fill(0);
  
  textSize(12);
  text("FishPlay v1.1.3", width/2, 20);
  text("Current fish population: "+ flock.boids.size(), 20, 20);
  text("Current sharks population: "+ sharkSwarm.sharks.size(), 20, 40);
  text("Oldest generation of fish: Gen " + getMinGen(), 20, 60);
  text("Newest generation of fish: Gen " + getMaxGen(), 20, 80);
  text("Main fish in use : Gen "+getDominantGen()+ " ,amount : " + dominantGenAmount() , 20, 100);
  text("Average generation size :" + flock.boids.size()/getMaxGen(), 20, 120);
  text("Fish stats explained: (generation/children had/ID)", 20, 140);
  text("Click Anywhere to create a SHARK!!!",20,160);
  text(frameRate, width-20,20);
}

// release a new shark into the ocean!!!
void mousePressed() {
  sharkSwarm.addShark(new Shark(mouseX, mouseY, 1));
}

int getMaxGen() {
  for (int i = 49; i >= 0; i--) {
    if (generations[i] != 0) {
      return i;
    }
  }
  return 0;
}

int getMinGen() {
  for (int i = 1; i <= 49; i++) {
    if (generations[i] != 0) {
      return i;
    }
  }
  return 0;
}

int dominantGenAmount() {
  int maxValue = 0;
  for (int i = 49; i >=0; i--) {
    if (generations[i] > maxValue) {
      maxValue = generations[i];
    }
  }
  return maxValue;
}


int getDominantGen() {
  int maxValue = 0;
  int maxIndex = 0;
  for (int i = 49; i >=0; i--) {
    if (generations[i] > maxValue) {
      maxValue = generations[i];
      maxIndex = i;
    }
  }
  return maxIndex;
}
