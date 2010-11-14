import processing.opengl.*;
import picking.*;

import damkjer.ocd.*;


Camera camera1;
Camera camera2;

Picker picker;

Sphere[] spheres;

float camX = width / 2;
float camY = height / 2;
int a = 30;
int q = a / 3;

void mouseDragged() {
  //camX += pmouseX*0.1; //(float)mouseX / (float)width * 2* (float)a;
  //camY += pmouseY*0.1; //(float)mouseY / (float)height * 2* (float)a;
  camera1.tumble( -1.0 * radians(mouseX - pmouseX), -1.0 * radians(mouseY - pmouseY));
}


void setup() {
  size(640, 360, OPENGL);

  picker = new Picker(this);

  noFill();
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
    }
  }
  ); 

//  camera1 = new Camera(this, width/2.0, height/2.0, (height/2.0) / tan((PI*60.0) / 360.0), 0, 1, 0);

  camera1 = new Camera( this, a * 2.0, a * 2.0, 220.0, // eyeX, eyeY, eyeZ
  (float)(a/2.0), (float)(a/2.0), (float)(a/2.0), // centerX, centerY, centerZ
  0.0, 1.0, 0.0);
  
  float poi = 0; //height / 2.0;
  camera2 = new Camera( this,0, poi, 400.0, // eyeX, eyeY, eyeZ
 0,poi,0, // centerX, centerY, centerZ
  0.0, 1.0, 0.0);
  
  int id = 0;
  spheres = new Sphere[64];
  for(int x = 0; x < 4; x++) {
    for(int y = 0; y < 4; y++) {
      for(int z = 0; z < 4; z++) {
        spheres[id++] = new Sphere(x*q, y*q, z*q);
      }
    }
  }
}

void draw() {
  background(120);
  lights();
  smooth();
  
  camera1.feed();
 
  // Change height of the camera with mouseY

  for (int dim = 0; dim < 3; dim++) {
    stroke(100,100,100);
    for(int i = 0; i < 4; i++ ) {
      for(int j = 0; j < 4; j++ ) {
        line((i*q), (j*q), 0, (i*q), (j*q), a);
      }
    }
    rotateX(PI/2);
    rotateY(PI/2);
  }


  noStroke();
  fill(255);

  for(int x = 0; x < 64; x++) {
    picker.start(x);
    spheres[x].display();
  }
  
  noFill();
  /*--- 0 == white ---*/
  stroke(255,255,255);
  box(4);


  /*--- x == red ---*/
  translate(a,0,0);
  stroke(255,0,0);
  box(7);
  translate(-a,0,0);

  /*--- y == green ---*/
  translate(0,a,0);
  stroke(0,255,0);
  box(7);
  translate(0,-a,0);

  /*--- z == blue ---*/
  translate(0,0,a);
  stroke(0,0,255);
  box(7);
  translate(0,0,-a);
   
  camera2.feed();
   
  stroke(#FFFFFF);
  rectMode(CORNER);
  rect(0,0, 230, 230);
 
}

void mouseClicked() {

  int id = picker.get(mouseX, mouseY);
  if (id > -1) {
    spheres[id].changeColor();
  }
}

void mouseWheel(int delta) {
  camera1.zoom(delta*0.03);
}


class Sphere {

  int x, y, z;
  color c;
  boolean r, g, b;

  Sphere(int x, int y, int z) {
    this.x = x; 
    this.y = y; 
    this.z = z;
    this.r = false;
    this.g = false;
    this.b = false;
    this.changeColor();
  }

  void changeColor() {
    c = color(this.r ? 255: 0, this.g ? 255: 0, this.b ? 255: 0);
    this.b = !this.b;
    if(this.b) { 
      this.g = !this.g;
      if(this.g) this.r = !this.r;
    }
  }

  void display() {
    fill(c);
    pushMatrix();
    translate(x, y, z);
    sphere(2);
    popMatrix();
  }
}

