class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (int i = boids.size() - 1; i >= 0; i--) {
      Boid b = boids.get(i);
      b.run(boids);
      if(!b.IDset) {
        b.id = i;
        b.IDset = true;
      }
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}
