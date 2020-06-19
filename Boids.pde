// FISH yes.

class Boid {
  boolean IDset = false;
  int id;
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  int gen;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int foodForChild = round(random(1, 3));
  int currentFood;
  int kidsHad = 0;

  Boid(float x, float y, int gen_) {
    acceleration = new PVector(0, 0);
    currentFood = 0;
    this.gen = gen_;
    generations[this.gen]++;  
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    r = 1.0;
    maxspeed = 2;
    maxforce = 0.03;
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }


  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids); 
    PVector getAway = runAwayFromSharks(sharkSwarm.sharks);
    // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    getAway.mult(1.8);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(getAway);
    eatMyFood(theFood);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }


  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);


    fill(255, 0, 0);
    stroke(255, 0, 0);
    strokeWeight(0.5);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(QUAD);
    fill(255, 0, 0);
    vertex(r, -r*2);

    vertex(-r, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);

    endShape();
    beginShape(TRIANGLES);
    vertex(-r, -r*2);
    vertex(r, -r*2);
    vertex(0, -r*4);
    endShape();
    beginShape(TRIANGLES);
    vertex(-r, r*5);
    vertex(r, r*5);
    vertex(0, r*2);
    endShape();
    fill(0);
    stroke(255);
    fill(255);
    strokeWeight(1.7*r);

    point(0, -r*2.5);
    stroke(0);
    fill(0);
    strokeWeight(0.75*r);
    point(0, -r*2.5);


    popMatrix();
    textSize(6+(this.kidsHad/2));
    textMode(CENTER);
    stroke(0);
    text(" g:"+this.gen+"/"+kidsHad + "/id: " + (this.id+1), this.position.x, this.position.y);
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  PVector runAwayFromSharks (ArrayList<Shark> predators) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Shark other : predators) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {

      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {

      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // boids will try to omve in the same direction as other boids
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }

  void eatMyFood(ArrayList<fishFood> food) {
    for (int i = food.size() -1; i >= 0; i--) {
      fishFood myLunch = food.get(i);
      if (dist(myLunch.x, myLunch.y, this.position.x, this.position.y) < this.r*3) {
        food.remove(myLunch);
        currentFood++;
        if (r <= 3) {
          r++;
        }
        if (currentFood >= foodForChild) {
          for (int j = 0; j < round(random(8)); j++) {
            flock.boids.add(new Boid(this.position.x, this.position.y, this.gen+1));
            kidsHad++;
          }
          currentFood = 0;
        }
      }
    }
  }
}
