import themidibus.*;
import processing.serial.*;

//for physical data
Serial myPort;  
int currVal;    
int previousVal;
int[] currDataPair = new int[2];
int[] previousDataPair = new int[2];

//for MIDI
MidiBus myBus;
int channel = 0;


void setup() 
{
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  
  // List all available Midi devices on STDOUT. This will show each device's index and name.
  MidiBus.list();
}

void draw()
{
     
  // If data is available:
  if ( myPort.available() > 0) 
  {  
    previousVal = currVal;
    currVal = myPort.read();
  }  
  
  checkData(previousVal, currVal);
}

//checks that first value is the sensor index and second value is the distance
void checkData(int previousVal, int currVal)
{
  //previousval = sensorIndex, currVal = distance
  if ((previousVal >= 200) && (currVal < 30))
  {
    //###### try for "interpolation" ########
    previousDataPair = currDataPair;
    currDataPair[0] = previousVal;
    currDataPair[1] = currVal;
    
    if (previousDataPair[0] == currDataPair[0]+1)
    {
       switch(previousDataPair[0]) 
       {
        case 202: 
          playNote(205);
          break;
        case 203: 
          playNote(206); 
          break;
       }
    }        
    //########################################
    
    //control pitch
    playNote(previousVal);
    
    //control volume alias cc7
    int mappedVal = mapOneByte(currVal, 30);
    controllerChange(channel, 7, mappedVal);
  }  
}

int mapOneByte(int val, int max)
{
  float processedVal = map(val, 0, max, 0, 255);
  return int(processedVal);
}

void playNote(int sensorIndex)
{
   int velocity = 127;
   int pitch = 0;
   switch(sensorIndex) 
   {
    case 200: 
    //C4
      pitch = 60;
      break;
    case 201: 
      pitch = 62;  
      break;
    case 202:
      pitch = 64;
      break;
    case 203:
      pitch = 67;
    case 204:
      pitch =71;
      
    case 205:
      pitch =65;
    case 206:
      pitch =69;
  }
   myBus.sendNoteOn(channel, pitch, velocity); 
   delay(200);
   myBus.sendNoteOff(channel, pitch, velocity); 
 
}

//form the themidibus basic example

void noteOn(int channel, int pitch, int velocity) 
{
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void noteOff(int channel, int pitch, int velocity) 
{
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void controllerChange(int channel, int number, int value) 
{
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}

void delay(int time) 
{
  int current = millis();
  while (millis () < current+time) Thread.yield();
}
