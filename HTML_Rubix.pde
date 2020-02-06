import peasy.*;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.lang.*;


  PeasyCam cam;
  
  int dim = 3;
  Cubie [] cubes = new Cubie[dim*dim*dim];
  long startTime = 0;
  long elapsedTime = 0;
  int index = 0;
  int counter = 0; //for shufUnshuff
  
  //variables for turning the cube while moving
  float viewRotateSpeedX = 0;//-0.001;
  float viewRotateSpeedY = 0;//0.001;
  float rotateX = -0.37;
  float rotateY = 0.37;
  
  
  Move currentMove;
  ArrayList<Move> seq = new ArrayList<Move>();
  
  Move[] allMoves = new Move[]{
    new Move(0, 0, 1, 1), 
    new Move(0, 0, 1, -1), 
    new Move(0, 0, -1, -1), 
    new Move(0, 0, -1, 1), //front and back sides rotation
  
    new Move(0, -1, 0, 1), 
    new Move(0, -1, 0, -1), 
    new Move(0, 1, 0, -1), 
    new Move(0, 1, 0, 1), //up and down (top and bottom rotation)
  
    new Move(-1, 0, 0, -1), 
    new Move(-1, 0, 0, 1), 
    new Move(1, 0, 0, 1), 
    new Move(1, 0, 0, -1), //left and right sides rotation
    
    
    new Move(0, 0, 0, 1)//fake no move
  
  
  };
  
  
  void setup() {
    size(600, 600, P3D);
    cam = new PeasyCam(this, 400);
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          PMatrix3D matrix = new PMatrix3D();
          matrix.translate(x, y, z);
          cubes[index] = new Cubie(matrix, x, y, z, index);
          index++;
        }
      }
    }
    shufGen();
    currentMove = seq.get(counter);
  }
  
  int times = 300; //makes 'times' number of turns then undoes them
  float turnSpeed = HALF_PI/5;
  
  void draw() {
    rotateX(rotateX);
    rotateY(rotateY);
    background(73);
    textSize(24);
    if (counter == times*2 || counter == times*2+1 || counter == times*2-1 ) text("Done", -100, -120, -80); 
    else {
      if (counter < times) text("#" + (counter), -100, -120, -80);
      else text("Unshuf #" + (times*2-counter), -100, -120, -80);
    }
  
    scale(50);
    currentMove.update();
    if (currentMove.finished && counter < seq.size()-1) {//does and undoes the moves in seq
      if (counter == 0) startTime = System.currentTimeMillis();
      counter++;
      currentMove = seq.get(counter);
      currentMove.start();
    }
    if (counter==seq.size()-1 && elapsedTime == 0) {
      elapsedTime = System.currentTimeMillis() - startTime;
      println("\nMilliseconds total:", elapsedTime);
      println("Moves:", seq.size());
      println("Milliseconds per turn:", (elapsedTime/seq.size()));
      shufGen();//make a new shuffle
    }
  
    for (int i = 0; i<cubes.length; i++) {
      push();
      if (abs(cubes[i].z) > 0 && cubes[i].z == currentMove.z) rotateZ(currentMove.angle);
      else if (abs(cubes[i].x) > 0 && cubes[i].x == currentMove.x) rotateX(currentMove.angle);
      else if (abs(cubes[i].y) > 0 && cubes[i].y == currentMove.y) rotateY(-currentMove.angle);
      cubes[i].show();
      pop();
    }
  }
  
  void resetAll() {//used to reset whole cube
    index = 0;
    startTime = 0;
    elapsedTime = 0;
    currentMove.finished = true;
    currentMove.animating = false;
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          PMatrix3D matrix = new PMatrix3D();
          matrix.translate(x, y, z);
          cubes[index] = new Cubie(matrix, x, y, z, index);
          index++;
        }
      }
    }
  }
  
  void shufGen() { //makes the shuffled generation
    seq = new ArrayList<Move>();
    for (int i = 0; i < times; i++) {
      Move m = allMoves[int(random(allMoves.length))];
      m.setSpeed(turnSpeed);
      seq.add(m);
    }
    for (int i = times-1; i >= 0; i--) {
      Move m = seq.get(i).reverse();
      m.setSpeed(turnSpeed);
      seq.add(m);
    }
  }
  
  
  
  class Cubie {
  PMatrix3D matrix;
  int y = 0;
  int x = 0;
  int z = 0;

  //Face blue = new Face(new PVector(0, 0, -1), color(0, 255, 0));//black
  //Face green = new Face(new PVector(0, 0, 1), color(0,255, 0));//green
  //Face white = new Face(new PVector(0, 1, 0), color(0, 255, 0));//white
  //Face yellow = new Face(new PVector(0, -1, 0), color(0, 255, 0));//yellow
  //Face orange = new Face(new PVector(1, 0, 0), color(0,255, 0));//orange
  //Face red = new Face(new PVector(-1, 0, 0), color(0, 255, 0));//red

  Face blue = new Face(new PVector(0, 0, -1), color(1, 12, 163));//blue
  Face green = new Face(new PVector(0, 0, 1), color(3, 186, 0));//green
  Face white = new Face(new PVector(0, 1, 0), color(239, 234, 234));//white
  Face yellow = new Face(new PVector(0, -1, 0), color(221, 214, 0));//yellow
  Face orange = new Face(new PVector(1, 0, 0), color(255, 114, 0));//orange
  Face red = new Face(new PVector(-1, 0, 0), color(255, 12, 12));//red


  boolean high = false;
  Face[] faces;

  Cubie(PMatrix3D m, int x, int y, int z, int pos_) {
    matrix = m;
    this.x = x;
    this.y = y;
    this.z = z;
    faces = faceDetermine(pos_);
  }

  void turnFacesZ(int dir) {
    for (Face f : faces) f.turnZ(dir*HALF_PI);
  }

  void turnFacesX(int dir) {
    for (Face f : faces) f.turnX(dir*HALF_PI);
  }

  void turnFacesY(int dir) {
    for (Face f : faces) f.turnY(dir*HALF_PI);
  }

  void update(int x, int y, int z) {
    matrix.reset();
    matrix.translate(x, y, z);
    this.x = x;
    this.y = y;
    this.z = z;
  }


  void show() {  
    fill(0);
    stroke(0);
    strokeWeight(0.12);
    pushMatrix();
    applyMatrix(matrix);
    box(1);
    for (Face f : faces) f.show();
    popMatrix();
  }


  Face[] faceDetermine(int pos) {
    if (pos == 0) return new Face[] {red, blue, yellow};
    else if (pos == 1) return new Face[] {red, yellow};
    else if (pos == 2) return new Face[] {red, yellow, green};
    else if (pos == 3) return new Face[] {red, blue};
    else if (pos == 4) return new Face[] {red};
    else if (pos == 5) return new Face[] {red, green};
    else if (pos == 6) return new Face[] {red, blue, white};
    else if (pos == 7) return new Face[] {red, white};
    else if (pos == 8) return new Face[] {red, white, green};
    else if (pos == 9) return new Face[] {blue, yellow};
    else if (pos == 10) return new Face[] {yellow};
    else if (pos == 11) return new Face[] {green, yellow};
    else if (pos == 12) return new Face[] {blue};
    //no 13 because that is center cube
    else if (pos == 14) return new Face[] {green};
    else if (pos == 15) return new Face[] {blue, white};
    else if (pos == 16) return new Face[] {white};
    else if (pos == 17) return new Face[] {green, white};
    else if (pos == 18) return new Face[] {orange, blue, yellow};
    else if (pos == 19) return new Face[] {orange, yellow};
    else if (pos == 20) return new Face[] {orange, green, yellow};
    else if (pos == 21) return new Face[] {blue, orange};
    else if (pos == 22) return new Face[] {orange};
    else if (pos == 23) return new Face[] {green, orange};
    else if (pos == 24) return new Face[] {white, blue, orange};
    else if (pos == 25) return new Face[] {white, orange};
    else if (pos == 26) return new Face[] {white, green, orange};
    else return new Face[]{};
  }
}








  class Face {
  PVector normal;
  color c;

  Face(PVector normal, color c) {
    this.normal = normal;
    this.c = c;
  }

  void show() {
    pushMatrix();
    fill(c);
    noStroke();
    rectMode(CENTER);
    translate(0.501 * normal.x, 0.501 * normal.y, 0.501 * normal.z);//times 0.501 so that color pop just barely past cube edges
    if (abs(normal.y) > 0) {
      rotateX(HALF_PI);
    } else if (abs(normal.x) > 0) {
      rotateY(HALF_PI);
    }

    square(0, 0, 1);
    popMatrix();
  }


  void turnX(float angle) {
    PVector v2 = new PVector();
    v2.y = round(normal.y * cos(angle) - normal.z * sin(angle));
    v2.z = round(normal.y * sin(angle) + normal.z * cos(angle));
    v2.x = round(normal.x);
    normal = v2;
  }

  void turnY(float angle) {
    PVector v2 = new PVector();
    v2.x = round(normal.x * cos(angle) - normal.z * sin(angle));
    v2.z = round(normal.x * sin(angle) + normal.z * cos(angle));
    v2.y = round(normal.y);
    normal = v2;
  }

  void turnZ(float angle) {
    PVector v2 = new PVector();
    v2.x = round(normal.x * cos(angle) - normal.y * sin(angle));
    v2.y = round(normal.x * sin(angle) + normal.y * cos(angle));
    v2.z = round(normal.z);
    normal = v2;
  }
}


class Move {
  int x = 0;
  int y = 0;
  int z = 0;
  int dir = 0;
  float angle = 0;
  float speed = 0.15;
  boolean animating = false;
  boolean finished = false;

  Move(int x, int y, int z, int dir) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.dir = dir;
  }
  void start() {
    animating = true;
    finished = false;
  }

  void setSpeed(float f) {
    speed = f;
  }

  Move reverse() {
    return new Move(x, y, z, dir*-1);
  }

  void update() {
    if (animating) {
      angle += dir * speed;
      if (abs(angle) > HALF_PI) {
        angle = 0;
        animating = false;
        finished = true;
        if (abs(z) > 0) turnZ(z, dir);
        else if (abs(x) > 0) turnX(x, dir);
        else if (abs(y) > 0) turnY(y, dir);
      }
    }
  }
}







void turnZ(int ind, int dir) {
  for (int i = 0; i<cubes.length; i++) {
    Cubie qb = cubes[i];
    if (qb.z == ind)
    {
      PMatrix2D matrix = new PMatrix2D();
      matrix.rotate(dir*HALF_PI);
      matrix.translate(qb.x, qb.y);
      qb.update(round(matrix.m02), round(matrix.m12), qb.z);
      qb.turnFacesZ(dir);
    }
  }
}

void turnY(int ind, int dir) {
  for (int i = 0; i<cubes.length; i++) {
    Cubie qb = cubes[i];
    if (qb.y == ind)
    {
      PMatrix2D matrix = new PMatrix2D();
      matrix.rotate(dir*HALF_PI);
      matrix.translate(qb.x, qb.z);
      qb.update(round(matrix.m02), qb.y, round(matrix.m12));
      qb.turnFacesY(dir);
    }
  }
}
void turnX(int ind, int dir) {
  for (int i = 0; i<cubes.length; i++) {
    Cubie qb = cubes[i];
    if (qb.x == ind)
    {
      PMatrix2D matrix = new PMatrix2D();
      matrix.rotate(dir*HALF_PI);
      matrix.translate(qb.y, qb.z);
      qb.update(qb.x, round(matrix.m02), round(matrix.m12));
      qb.turnFacesX(dir);
    }
  }
}






void keyPressed() {
  if (key == ' ') {
    if (currentMove.finished || counter == 0 || counter == (times*2)) {
      resetAll();
      counter = 0;
      currentMove = seq.get(0);
      currentMove.start();
    }
  } else if (key == '-') {
    counter = (times*2);
  } else  RotMove(key);
}

void RotMove(char move) {
  if (currentMove.finished || counter == 0 || counter == times*2) {
    if (keyCode == LEFT) rotateY -= 4.712;
    if (keyCode == RIGHT) rotateY += 4.712;
    switch(move) {
    case 'q':
      currentMove = allMoves[4];
      break;
    case 'w':
      currentMove = allMoves[5];
      break;
    case 'z':
      currentMove = allMoves[7];
      break;
    case 'x':
      currentMove = allMoves[6];
      break;
    case 'a':
      currentMove = allMoves[rotHelp(rotateY, true)];
      break;
    case 's':
      currentMove = allMoves[rotHelp(rotateY, false)];
      break;
    default:
      currentMove = allMoves[12];
    }
    currentMove.setSpeed(turnSpeed);
    currentMove.start();
    counter = seq.size()+1;
  }
}


int rotHelp(float rot, boolean che) {
  if (rot < 0) rot -= 0.45;
  int num = (int)(rot/4.712);
  num = num % 4;
  if (num<0) num = 4 - Math.abs(num);
  if (num == 0 && che) return 1;
  if (num == 1 && che) return 11;
  if (num == 2 && che) return 3;
  if (num == 3 && che) return 9;
  if (num == 0 && !che) return 0;
  if (num == 1 && !che) return 10;
  if (num == 2 && !che) return 2;
  if (num == 3 && !che) return 8;
  else return 12;
}

void NumMove(char move) {
  if (currentMove.finished || counter == 0 || counter == times*2) {
    switch(move) {
    case '1':
      currentMove = allMoves[0];
      break;
    case '2':
      currentMove = allMoves[1];
      break;
    case '3':
      currentMove = allMoves[2];
      break;
    case '4':
      currentMove = allMoves[3];
      break;
    case '5':
      currentMove = allMoves[4];
      break;
    case '6':
      currentMove = allMoves[5];
      break;
    case '7':
      currentMove = allMoves[6];
      break;
    case '8':
      currentMove = allMoves[7];
      break;
    case '9':
      currentMove = allMoves[8];
      break;
    case '0':
      currentMove = allMoves[9];
      break;
    case '-':
      currentMove = allMoves[10];
      break;
    case '=':
      currentMove = allMoves[11];
      break;
    default:
      currentMove = allMoves[12];
    }
    currentMove.setSpeed(turnSpeed);
    currentMove.start();
    counter = seq.size()+1;
  }
}

void ColorMove(char move) {
  if (currentMove.finished || counter == 0 || counter == times*2) {
    int x = 0;
    if (Character.isUpperCase(move)) {
      println("ok");
    }
    switch(move) {
    case 'g':
      currentMove = allMoves[0+x];
      break; 
    case 'b':
      currentMove = allMoves[2+x];
      break;
    case 'y':
      currentMove = allMoves[4+x];
      break;
    case 'w':
      currentMove = allMoves[6+x];
      break;
    case 'r':
      currentMove = allMoves[8+x];
      break;
    case 'o':
      currentMove = allMoves[10+x];
      break;
    default:
      currentMove = allMoves[12];
    }
    currentMove.setSpeed(turnSpeed);
    currentMove.start();
    counter = seq.size()+1;
  }
}
