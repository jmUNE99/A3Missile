int bombtime;
int ntime;
int trailCount;
float trailLength;
float trailSpacing;
float trailX;
float trailY;
float ground = 600;
boolean start = false;

//this section is generation of antimissile WIP
class Antimissile {
  float x, y; // position 
  float velax, velay; // velocity 
  boolean exploded;
  int etime;
  // set antimissile velocity and starting point
  Antimissile(float targetX, float targetY) {
    x = 400;
    y = ground;
    float dx = targetX - x;
    float dy = targetY - y;
    float distance = sqrt(dx * dx + dy * dy);
    float speed = distance / 120;
    velax = dx / distance * speed;
    velay = dy / distance * speed;

    exploded = false;
    etime = 0;
  }

  void move() {
    if (!exploded) {
      x += velax;
      y += velay;

      if (dist(x, y, mouseX, mouseY) <= 5) {
        explode();
      }
    }
  }
  
  void render() {
    if (!exploded) {
      fill(255);
      ellipse(x, y, 10, 10);
    } else {
      noStroke();
      int fadeTime = 500;
      int fadingTime = millis() - etime;
      int alpha = int(map(fadingTime, 0, fadeTime, 255, 0));
      fill(255, 0, 0, alpha);
      ellipse(x, y, 30, 30);
    }
  }

  void explode() {
    exploded = true;
    etime = millis();
  }
}

Antimissile ABM;
//generation of enemy bombs
class Bomb {
  float x, y; // position of the enemy bomb
  float velx, vely; // velocity of the enemy bomb
  boolean exploded;
  int explosionTime;
  // set bomb pos & vel
  Bomb() {
    x = random(800);
    y = 0;
    velx = random(1) < 0.5 ? -1 : 1;
    vely = 2;
    exploded = false;
  }
  // enemy bombs pos when moving
  void advance() {
    if (!exploded) {
      x += velx;
      y += vely;
      if (x < 0 || x > 800) {
        velx = velx * -1;
      }
      if (y >= ground) {
        exploded = true;
        explosionTime = millis();
      }
    }
  }
  //drawing the bombs and their trails
  void render() {
    if (!exploded) {
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
    } else {
      //explosion
      noStroke();
      int fadeTime = 500;
      int fadingTime = millis() - explosionTime;
      int alpha = int(map(fadingTime, 0, fadeTime, 255, 0));
      fill(255, 243, 166, alpha);
      circle(x, y, 30);
    }
  }
}

Bomb[] bombs = new Bomb[10];

void setup() {
  size(800, 800);
  bombtime = millis();
  ABM = null;
}

void draw() {
  if (start) {
    background(0);
    stroke(255, 0, 0);
    strokeWeight(1);
    line(0, ground, width, ground);
    //bombs added every 3 sec
    ntime = millis();
    if (ntime - bombtime > 3000) {
      for (int i = 0; i < bombs.length; i++) {
        if (bombs[i] == null) {
          bombs[i] = new Bomb();
          break;
        }
      }
      bombtime = ntime;
    } else if (bombtime == 0) {
      bombs[0] = new Bomb();
      bombtime = ntime;
    }

    for (int i = 0; i < bombs.length; i++) {
      if (bombs[i] != null) {
        bombs[i].advance();
        bombs[i].render();
      }
    }

    if (ABM != null) {
      ABM.move();
      ABM.render();
    }
  } else {
    //start screen
    background(0);
    textSize(40);
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    text("Click to Start", width / 2, height / 2);
    text("Missile Command", width / 2, 350);
  }
}
//if mouse click, start game and also handles shooting the ABM
void mousePressed() {
  if (!start) {
    start = true;
  } else {
    if (ABM == null) {
      ABM = new Antimissile(mouseX, mouseY);
    }
  }
}
