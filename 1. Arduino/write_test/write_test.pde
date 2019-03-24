import processing.serial.*;

//for physical data
Serial myPort; 
String  myString;

void setup() 
{
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  
}

void draw()
{
 
  // If data is available:
  if ( myPort.available() > 0) 
  {  
    //10 is ASCCII for \n
    myString = myPort.readStringUntil(10);
    println(myString);
  }  
  
}
