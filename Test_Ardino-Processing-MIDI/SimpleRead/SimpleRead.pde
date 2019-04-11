import themidibus.*;


//proessing to daw
// signal --> string --> int
// then intapolation
// the midi bus library no midi loop 

import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

void setup() 
{
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

void draw()
{
  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.read();
    println(val);// read it and store it in val
  }
}
