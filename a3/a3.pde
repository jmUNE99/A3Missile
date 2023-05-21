int bombtime;
int CurrentMillis;
int trailCount;
float trailLength;
float trailSpacing;
float trailX;
float trailY;
float ground = 630;
boolean start = false;
int DeadBuildings = 0;
boolean[] destroyedCities = new boolean[6]; // Array to track the destroyed cities
boolean gameOver = false;
int score = 0; 


//this section is generation of antimissile WIP
class Antimissile {
    float x, y; // position 
    float velax, velay; // velocity 
    boolean exploded;
    int etime;
   
    // set antimissile velocity and starting point
    Antimissile(float targetX, float targetY) {
        x = width/2;
        y = ground;
        float dx = targetX - x;
        float dy = targetY - y;
        float distance = sqrt(dx * dx + dy * dy);
        float speed = 4;
        velax = dx / distance * speed;
        velay = dy / distance * speed;

        exploded = false;
        etime = 0;
    }

      void move() {
        if (!exploded) {
          x += velax;
          y += velay;
          for (Bomb bomb : bombs) {
            if (bomb != null && !bomb.exploded && collidesWithBomb(bomb)) {
              score++;
              explode();
              bomb.exploded = true;
              break;
            }
          }
        }
      }
      //calculate distance between bomb and anti missile
      boolean collidesWithBomb(Bomb bomb) {
        float distance = dist(x, y, bomb.x, bomb.y);
      if (distance <= 10) {
        return true; //collision
      }
      return false; // no collision
    }

    void render() {
        if (!exploded) {
            fill(255);
            ellipse(x, y, 10, 10);
        } else {
            //explosion of antimissile
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

//generation of enemy bombs
class Bomb {
    float x, y; // position of the enemy bomb
    float velx, vely; // velocity of the enemy bomb
    boolean exploded;
    int explosioCurrentMillis;
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
                explosioCurrentMillis = millis();
            }
        }
    }
    // drawing the bombs and their trails
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
            // explosion
            noStroke();
            int fadeTime = 500;
            int fadingTime = millis() - explosioCurrentMillis;
            int alpha = int(map(fadingTime, 0, fadeTime, 255, 0));
            fill(255, 243, 166, alpha);
            circle(x, y, 30);
        }
    }
}

ArrayList<Antimissile> antimissiles = new ArrayList<Antimissile>();  // array list to store antimissiles so more than 1 can shoot


Bomb[] bombs = new Bomb[10];

void setup() {
    size(800, 800);
    bombtime = millis();
    for (int i = 0; i < destroyedCities.length; i++) {
        destroyedCities[i] = false; // Initialize all cities as intact
  }
}
void draw() {
    if (start) { 
        background(0);
        stroke(255, 0, 0);
        strokeWeight(1);
        line(0, ground, width, ground);
        
          // Draw score in the top-right corner
        fill(255);
        textSize(24);
        textAlign(RIGHT, TOP);
        text("Score: " + score, width - 10, 10);
        
        if (gameOver) {
          gameOver();
          return;
        } else {

        // draw antimissile shape cover
        float shooterX = width/2;
        float shooterY = 610;
        fill(128, 128, 0);
        stroke(128, 128, 0);
        triangle(shooterX - 20, shooterY + 20, shooterX, shooterY - 20, shooterX + 20, shooterY + 20);
        
        // bombs added every 3 sec
        CurrentMillis = millis();
        if (CurrentMillis - bombtime > 3000) {
            for (int i = 0; i < bombs.length; i++) {
                if (bombs[i] == null) {
                    bombs[i] = new Bomb();
                    break;
                }
            }
            bombtime = CurrentMillis;
        } else if (bombtime == 0) {
            bombs[0] = new Bomb();
            bombtime = CurrentMillis;
        }

        // render intact cities
        fill(0, 0, 255);
        noStroke();
        for (int j = 0; j < 6; j++) {
            float cityX = width / 7 * (j + 1);
            float cityY = ground - 5; // position the cities exactly on the red line
            if (!destroyedCities[j]) {
            rect(cityX - 15, cityY - 30, 30, 30); // adjust the city dimensions
         }
        }

        for (int i = 0; i < bombs.length; i++) {
            if (bombs[i] != null) {
                bombs[i].advance();
                bombs[i].render();

                // check if bomb hits a city
                for (int j = 0; j < 6; j++) {
                    float cityX = width / 7 * (j + 1);
                    float cityY = ground - 30; 
                    if (bombs[i].y >= cityY && bombs[i].x >= cityX - 15 && bombs[i].x <= cityX + 15) {
                        destroyCity(j);
                        bombs[i].exploded = true; 
                        break;  
                    }
                }
            }
        }

       // Render antimissiles
        for (Antimissile antimissile : antimissiles) {
            antimissile.move();
            antimissile.render();

        // check if antimissile hits a bomb
          for (int i = 0; i < bombs.length; i++) {
            if (bombs[i] != null && antimissile.collidesWithBomb(bombs[i])) {
              antimissile.explode();
              bombs[i].exploded = true;
            }
          }
        }
      }
    } else {
        // start screen
        background(0);
        textSize(40);
        textAlign(CENTER, CENTER);
        fill(255, 0, 0);
        text("Click to Start", width / 2, height / 2);
        text("Missile Command", width / 2, 350);
    }
}


void destroyCity(int cityIndex) {
    if (!destroyedCities[cityIndex]) {
        destroyedCities[cityIndex] = true; // Mark the city as destroyed
        DeadBuildings++; //tracks destroyed buildings

        float cityX = width / 7 * (cityIndex + 1);
        float cityY = ground - 30;

        fill(0);
        rect(cityX - 15, cityY - 30, 30, 60);

        if (DeadBuildings >= 6) {
            gameOver = true; //game over screen
        }
    }
}
// display game over screen
void gameOver() {
  // game over
  background(0);
  textSize(50);
  textAlign(CENTER, CENTER);
  fill(255, 0, 0);
  text("Game Over", width/2, height/2);
}


// if mouse click, start game and also handles shooting the ABM
void mousePressed() {
    if (gameOver) {
      // Return to start screen when "Game Over" screen is clicked
      start = false;
      gameOver = false;
      for (int i = 0; i < destroyedCities.length; i++) {
        destroyedCities[i] = false; // reset the destroyed cities array
      }
    } else if (!start) {
        // Start the game
        start = true;
    } else {
        antimissiles.add(new Antimissile(mouseX, mouseY));
    }
}
