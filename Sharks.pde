class Sharks {
  ArrayList<Shark> sharks; // An ArrayList for all the boids

  Sharks() {
    sharks = new ArrayList<Shark>(); // Initialize the ArrayList
  }

  void run() {
    for (int i = sharks.size()-1; i >= 0; i--) {
      Shark s= sharks.get(i);
      s.run(sharks, flock.boids);  
    }
  }

  void addShark(Shark s) {
    sharks.add(s);
  }

}
