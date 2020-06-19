class Shark {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int foodForChild = 10;
  int currentFood = 0;
  int gen;
  
  Shark(float x, float y, int gen_) {
    acceleration = new PVector(0, 0);
    this.gen = gen_;
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    r = 1.0;
    maxspeed = 3;
    maxforce = 0.03;
  }

  void run(ArrayList<Shark> sharks, ArrayList<Boid> prey) {
    swarm(sharks, prey);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M#
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void swarm(ArrayList<Shark> sharks, ArrayList<Boid> prey) {
    PVector sep = separate(prey);
    PVector dontCrash = avoid(sharks); // Separation
    PVector ali = align(sharks);      // Alignment
    PVector coh = cohesion(sharks);
    PVector preyHunt = alignToPrey(prey);
    PVector preyEat = huntPrey(prey);
    // Cohesion
    // Arbitrarily weight these forces
    sep.mult(-1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    preyHunt.mult(20);
    preyEat.mult(20);
    dontCrash.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(preyHunt);
    applyForce(preyEat);
    applyForce(dontCrash);
    eatFood(prey);
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

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  
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
    stroke(0, 0, 0);
    strokeWeight(0.5);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(QUAD);
    fill(130);
    vertex(r, -r*2);

    vertex(-r, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);

    endShape();
    strokeWeight(0.5);
    beginShape(TRIANGLES);
    vertex(r,-r*2);
    vertex(r*2.5,r);
    vertex(r,r);
    endShape();
    strokeWeight(0.5);
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
    strokeWeight(1.7*r);
    stroke(255);
    fill(255);
    point(0, -r*2.5);
    stroke(0);
    fill(0);
    strokeWeight(0.75*r);
    point(0, -r*2.5);
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby shark and steers away
  PVector separate (ArrayList<Boid> fish) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every shark in the system, check if it's too close
    for (Boid other : fish) {
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

  PVector avoid (ArrayList<Shark> buddies) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every shark in the system, check if it's too close
    for (Shark other : buddies) {
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
  // sharks will try to omve in the same direction as other sharks
  PVector align (ArrayList<Shark> sharks) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Shark other : sharks) {
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

  PVector alignToPrey (ArrayList<Boid> fish) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : fish) {
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
  // For the average position  of all nearby sharks, calculate steering vector towards that position
  PVector cohesion (ArrayList<Shark> sharks) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Shark other : sharks) {
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

  PVector huntPrey (ArrayList<Boid> fish) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : fish) {
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

  void eatFood(ArrayList<Boid> food) {
    for (int i = food.size() -1; i >= 0; i--) {
      Boid myLunch = food.get(i);
      if (dist(myLunch.position.x, myLunch.position.y, this.position.x, this.position.y) < this.r*3 && myLunch.r <= this.r) {
        maxforce = 0.02+((r-2)/25);
        maxspeed = 2.0+(r-2);
        generations[myLunch.gen]--;
        food.remove(myLunch);
                currentFood++;
        if(r <= 3) {
          r++;
        }
        if(currentFood >= foodForChild) {
          for(int j = 0; j < round(random(2)); j++) {
          sharkSwarm.sharks.add(new Shark(this.position.x, this.position.y, this.gen+1));
          }
          currentFood = 0;
          
        }
      }
    }
  }
}
