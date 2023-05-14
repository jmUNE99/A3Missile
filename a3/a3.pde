int bombtime;
int ntime;
int trailCount;
float trailLength;
float trailSpacing;
float trailX;
float trailY;

class bomb {
  float x, y; // position of the enemy bomb
  float velx, vely; // velocity of the enemy bomb
  
  // set bomb pos & velovcity
  bomb() {
    x = random(800);
    y = 0;
    velx = random(1) < 0.5 ? -1: 1; //randomly choose between 1 and -1 
    vely = 2;
  }
  
  //enemy bomb pos
  void advance() {
    if (y < ground) {  //currently bombs just stop at ground 
      x += velx;
      y += vely;
      if (x < 0 || x > 800) { //if bomb tries to go out of bounds it bounces back ideally some kind of targeting system may be better but idk how 
        velx = velx * -1;
      }
    }
  }
  
    // draw bombs
   void render() {
    stroke(255, 255, 0);
    strokeWeight(10);
    line(x, y, x - velx, y - vely);
    trailLength = 200;
    trailSpacing = 5;
    trailCount = int(trailLength / trailSpacing);
    for (int i = 1; i <= trailCount; i++) {
      float alpha = map(i, 1, trailCount, 255, 0);
      stroke(255, 0, 0, alpha);
      strokeWeight(10);
      trailX = x - velx * i * trailSpacing / vely;
      trailY = y - i * trailSpacing;
      line(trailX, trailY, trailX - velx, trailY - vely);
    }
  }
}

float ground = 600;

bomb[] bombs = new bomb[10];

void setup(){
  size(800,800);
  bombtime = millis();
}

void draw(){
  background(0);
  stroke(255,0,0);
  strokeWeight(1);
  line(0,ground,width,ground);
  //using time to add new bombs added every 3 seconds up until there have been 10 bombs
  ntime = millis(); 
  
  if (ntime - bombtime > 3000) {
    for (int i = 0; i < bombs.length; i++) {
      if (bombs[i] == null) {
        bombs[i] = new bomb();
        break;
      }
    }
    bombtime = ntime;
  }
  else if (bombtime == 0) {
    bombs[0] = new bomb();
    bombtime = ntime;
  }
  
  for (int i = 0; i < bombs.length; i++){
    if (bombs[i] != null) {
      bombs[i].advance();
      bombs[i].render();
    }
  }
}
