int bombtime;
int CurrentMillis;
int trailCount;
float trailLength;
float trailSpacing;
float trailX;
float trailY;
float ground = 630;
boolean start = false;

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
        // collision condition goes here
        }
    }

    void render() {
        if (!exploded) {
            fill(255);
            ellipse(x, y, 10, 10);
        } else {
            //explosion of antimissile, currently not in use
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
}

void draw() {
    if (start) {
        background(0);
        stroke(255, 0, 0);
        strokeWeight(1);
        line(0, ground, width, ground);
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
            rect(cityX - 15, cityY - 30, 30, 30); // adjust the city dimensions
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
    // calculate the size and position of the destroyed city based on the intact city
    float cityX = width / 7 * (cityIndex + 1);
    float cityY = ground - 30; 

    // draw a black square that covers the intact city
    fill(0);
    rect(cityX - 15, cityY - 30, 30, 60); // adjust the city dimensions to cover the blue square completely
}

// if mouse click, start game and also handles shooting the ABM
void mousePressed() {
    if (!start) {
        start = true;
    } else {
         antimissiles.add(new Antimissile(mouseX, mouseY));
    }
}
