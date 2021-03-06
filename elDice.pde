import processing.serial.*;
import com.rngtng.rainbowduino.*;

import javax.media.opengl.*;
import processing.opengl.*;
import picking.*;

RainbowduinoCubeDevice cube;

Picker picker;

PGraphics pg = null;

Sphere[] spheres;

int a = 30;  //cube side length
int q = a / 3; //distance between two LEDs
float a2 = a / 2.0;

float rotX;
float min_rotX = 2 * a;
float max_rotX = 5 * a;

float rotY;

float distance;
float min_distance = 2 * a;
float max_distance = 4 * a;

void mouseDragged() {
  rotY += radians(mouseX - pmouseX);
  rotX += radians(mouseY - pmouseY);
}


void setup() {
  //RainbowduinoDetector.start(this);
  cube = new RainbowduinoCubeDevice();
  distance = max_distance;

  size(1000, 500, OPENGL);

  picker = new Picker(this);

  noFill();
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      mouseWheel(evt.getWheelRotation());
    }
  }
  );

  int id = 0;
  spheres = new Sphere[64];
  for(int x = 0; x < 4; x++) {
    for(int y = 0; y < 4; y++) {
      for(int z = 0; z < 4; z++) {
        spheres[id++] = new Sphere(x, y, z, q);
      }
    }
  }
}

void draw() {
  hint(ENABLE_DEPTH_TEST);
  
  background(120);
  lights();
  smooth();

  camera( a2,  a2, distance, // eyeX, eyeY, eyeZ
          a2,  a2,  a2,
         0.0, 1.0, 0.0); // centerX, centerY, centerZ

  translate( a2, 0, a2);
  rotateY(rotY);
  translate( -a2, 0, -a2);

  translate( 0, a2, a2);
  rotateX(-rotX);
  translate( 0, -a2, -a2);
  
  // Basement 
  pushMatrix();
  translate( a2, a2,  float(a) / -6.0);
  fill(#666666);
  noStroke();
  box (a* 1.5, a * 1.5, 1.5);
  popMatrix();
  
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

  hint(DISABLE_DEPTH_TEST);
  camera();

  stroke(#FFFFFF);
  rectMode(CORNER);
  rect(0, 0, 30, 30);
  text("TEST", 100, 100);
}

void mouseClicked() {
  int id = picker.get(mouseX, mouseY);
  if (id > -1) {
    spheres[id].changeColor();
    cube.update(spheres);
  }
}

void mouseWheel(int delta) {
  distance -= delta * 0.5;
  if (distance > max_distance) {
    distance = max_distance;
  } else if ( distance < min_distance) {
     distance = min_distance;
  }
}


class Sphere {

  int x, y, z, scale;
  color c;
  byte r, g, b;

  Sphere(int x, int y, int z, int scale) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.scale = scale;
    this.r = 0;
    this.g = 0;
    this.b = 0;
    this.c = color(this.r * 255, this.g * 255, this.b * 255);
  }

  void changeColor() {
    if(this.b == 1) {
      this.g = invert(this.g);
      if(this.g == 1) this.r = invert(this.r);
    }
    this.b = invert(this.b);
    c = color(this.r * 255, this.g * 255, this.b * 255);
  }

  byte invert(byte v) {
    return (byte) (1 - v);
  }

  void display() {
    fill(c);
    pushMatrix();
    translate(x*scale, y*scale, z*scale);
    box(2);
    popMatrix();
  }
}

class RainbowduinoCubeDevice {

   Rainbowduino rainbowduino;
   int frame;

   RainbowduinoCubeDevice() {
     this.frame = 0;
   }

   void init(Rainbowduino _rainbowduino) {
     this.rainbowduino = _rainbowduino;
     this.rainbowduino.reset();
     this.rainbowduino.stop();
   }

   void brightnessSet(int brightness) {
     if( this.rainbowduino == null ) return;
     this.rainbowduino.brightnessSet(brightness);
   }

   void update(Sphere[] spheres) {
     if( this.rainbowduino == null ) return;

     int[] frameData = new int[24];
     for(int i = 0; i < 64; i++) {
           int x = spheres[i].y + 4 - (2 * spheres[i].y + 1) * ((spheres[i].x + 1) % 2);
           int y = spheres[i].z + 4 - (int) (Math.floor(4 * (spheres[i].x / 2)));
           frameData[3*y + 0] |= ((spheres[i].r) & 1) << x;
           frameData[3*y + 1] |= ((spheres[i].b) & 1) << x;
           frameData[3*y + 2] |= ((spheres[i].g) & 1) << x;
     }
     this.rainbowduino.bufferSetAt(this.frame, frameData);
   }

}

//callback funtion to register new rainbowduinos
void rainbowduinoAvailable(Rainbowduino _rainbowduino) {
  cube.init(_rainbowduino);
  cube.update(spheres);
  cube.brightnessSet(16);
}
