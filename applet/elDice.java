import processing.core.*; 
import processing.xml.*; 

import javax.media.opengl.*; 
import processing.opengl.*; 
import picking.*; 
import damkjer.ocd.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class elDice extends PApplet {








Camera camera1;
Camera camera2;

Picker picker;

Sphere[] spheres;

float camX = width / 2;
float camY = height / 2;
int a = 30;
int q = a / 3;

public void mouseDragged() {
  //camX += pmouseX*0.1; //(float)mouseX / (float)width * 2* (float)a;
  //camY += pmouseY*0.1; //(float)mouseY / (float)height * 2* (float)a;
  camera1.tumble( -1.0f * radians(mouseX - pmouseX), -1.0f * radians(mouseY - pmouseY));
}


public void setup() {
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

  camera1 = new Camera( this, a * 2.0f, a * 2.0f, 220.0f, // eyeX, eyeY, eyeZ
  (float)(a/2.0f), (float)(a/2.0f), (float)(a/2.0f), // centerX, centerY, centerZ
  0.0f, 1.0f, 0.0f);
  
  float poi = 0; //height / 2.0;
  camera2 = new Camera( this,0, poi, 400.0f, // eyeX, eyeY, eyeZ
 0,poi,0, // centerX, centerY, centerZ
  0.0f, 1.0f, 0.0f);
  
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

public void draw() {
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
   
  stroke(0xffFFFFFF);
  rectMode(CORNER);
  rect(0,0, 230, 230);
 
}

public void mouseClicked() {

  int id = picker.get(mouseX, mouseY);
  if (id > -1) {
    spheres[id].changeColor();
  }
}

public void mouseWheel(int delta) {
  camera1.zoom(delta*0.03f);
}


class Sphere {

  int x, y, z;
  int c;
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

  public void changeColor() {
    c = color(this.r ? 255: 0, this.g ? 255: 0, this.b ? 255: 0);
    this.b = !this.b;
    if(this.b) { 
      this.g = !this.g;
      if(this.g) this.r = !this.r;
    }
  }

  public void display() {
    fill(c);
    pushMatrix();
    translate(x, y, z);
    box(5);
    popMatrix();
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "elDice" });
  }
}
