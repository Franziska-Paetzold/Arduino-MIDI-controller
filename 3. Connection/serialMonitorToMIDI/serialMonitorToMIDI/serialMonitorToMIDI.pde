import themidibus.*;
import processing.serial.*;

//for physical data
Serial myPort; 
String portName;


//for MIDI
MidiBus myBus;
int channel = 0;

//for procrssing data
int[] distances = new int[5];
int maxDistance = 30;

//MIDI note numbers from C4 to B4 
int[] chromaticScale={60,61,62,63,64,65,66,67,68,69,70,71};
int[] diatonicScale={60,62,64,65,67,69,71};

boolean eIsPlaying = false;
boolean gIsPlaying = false;

//TODO: play note constantly till obstacle moves away 


void setup() 
{
  try 
  {
    portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);
  } 
  catch (ArrayIndexOutOfBoundsException e) 
  {
    e.printStackTrace();
    portName = null;
  }
  
  
  
  myBus = new MidiBus(this, -1, "arduinoToLive Port"); 
}

void draw()
{
  //if there is no microcontroller connection, program stops
  if (portName == null)
  {
    print("no microcontroller connection");
    noLoop();
    exit();
  }
  
  // If data is available:
  if ( myPort.available() > 0) 
  {  
    String inBuffer = myPort.readStringUntil(10);   
    if (inBuffer != null) {
     // println("new: " + inBuffer);
      distances = serialStringtoIntArray(inBuffer);
      distances = setBoundaries(distances, maxDistance);
      if (distances != null)
      {
       // playNotes(distances);
       chromaticScaleAndVolume(distances);
      }
      println("new and edited:" + distances[0], distances[1], distances[2], distances[3], distances[4]);
      distances = null;
    }
  }  
  
}

int[] serialStringtoIntArray(String string)
{
 
  int[] data = new int[5];
  int indexCounter = 0;
  String distanceString ="";
  for (int i=0; i < string.length(); i++)
  {
    if(string.charAt(i) == '/')
    {      
      try 
      {
        data[indexCounter] = int(distanceString);
      } 
      catch (IndexOutOfBoundsException e) 
      {
        e.printStackTrace();
        distanceString ="";
        break;
      }
      indexCounter++;
      distanceString ="";
    }
    else
    {
      distanceString += str(string.charAt(i));
    }
  }
  return data;
}

int[] setBoundaries (int[] array, int max)
{
   for (int i=0; i < array.length; i++)
  {
    if (array[i] > max)
    {
      array[i] = 0;
    }
  }
  return array;
}

/*

void playNotes(int[] array)
{
  int velocity = 127;
  int pitch = 0;
  
  //check for e 
  if  ((array[1] > 0) && (array[2] > 0))
  {
    eIsPlaying = true;
  }
  else
  {
    eIsPlaying = false;
  }
  
  //check for g
  if  ((array[2] > 0) && (array[3] > 0))
  {
    gIsPlaying = true;
  }
  else
  {
    gIsPlaying = false;
  }
  
  for (int i=0; i<array.length; i++)
  {
   switch(i) 
   {
    case 0: 
    //C4
      pitch = 60;
      break;
    case 1: 
      pitch = 62;  
      break;
    case 2:
      pitch = 65;
      break;
    case 3:
      pitch = 69;
    case 4:
      pitch =71;
      
    
   }
    
   //### volume change ###
   //control volume alias cc7
   int mappedVal = mapOneByte(array[i], maxDistance);
   myBus.sendControllerChange(channel, 7, mappedVal);
   //### volume change end ###
   
   //play note costantly till obstacle moves away
   if (array[i] > 0)
   {
     myBus.sendNoteOn(channel, pitch, velocity); 
   }
   else
   {
     myBus.sendNoteOff(channel, pitch, velocity); 
   }
   
  //play inbetweenies
   
   if (eIsPlaying)
   {
     myBus.sendNoteOn(channel, 64, velocity); 
   }
   else
   {
     myBus.sendNoteOff(channel, 64, velocity);
   }
   
   if (gIsPlaying)
   {
     myBus.sendNoteOn(channel, 67, velocity); 
   }
   else
   {
     myBus.sendNoteOff(channel, 67, velocity);
   }
   
  }
}
*/

//calculates 12 semitones and plays the volume depending on the distance to the sensors 
void chromaticScaleAndVolume(int[] data)
{

  int[] y= data;
  //stores positions on x axis
  float[] x = new float[12];
  //fill the array first
  for (int i=0; i<x.length; i++)
  {
    //todo, why always 0?
    x[i]=data.length/12.0*float(i);
  }
  
  println("x array: ");
  for (int i=0; i<x.length; i++)
  {
    print(x[i]);
  }
  
  for (int i=0; i<x.length; i++)
  {
    float currY=0;
    
    //interpolate between sensors via functional equations to set volume
    //currY  = getY(x,y,i);
    
    //sent MIDIs
    changeVolume(currY);
    if (i>0)
    {
      noteOn(i);
    }
    else
    {
      noteOff(i);
    }
  }
}

float getY(float[] x, int[] y, int i)
{
  float currY = 0;
  if(x[i]>=x[0] && x[i]<x[1])
  {
    currY = calcFunctionalEquation(x[0], y[0], x[1], y[1], x[i]);
  }
  if(x[i]>=x[1] && x[i]<x[2])
  {
    currY = calcFunctionalEquation(x[1], y[1], x[2], y[2], x[i]);
  }
  if(x[i]>=x[2] && x[i]<x[3])
  {
    currY = calcFunctionalEquation(x[2], y[2], x[3], y[3], x[i]);
  }
  if(x[i]>=x[3] && x[i]<=x[4])
  {
    currY = calcFunctionalEquation(x[3], y[3], x[4], y[4], x[i]);
  }
  return currY;
}

float calcFunctionalEquation(float x1, int y1, float x2, int y2, float currX)
{
  float currY = 0;
  float n=0;
  float m=0;
  
  try 
  {
     m = (y2 - y1)/x2-x1;
  } 
  catch (ArithmeticException e) 
  {
   // e.printStackTrace();
    print(x2, x1);
    return currY;
  }  
 
  n =y2-m*x2;
  //calculate current y 
  currY = m*currX+n;
  return currY;
}

void changeVolume(float data)
{
  int mappedVal = mapOneByte(data, maxDistance);
  myBus.sendControllerChange(channel, 7, mappedVal);
}

void noteOn(int data)
{
  int pitch = chromaticScale[data]; 
  myBus.sendNoteOn(channel, pitch, 127); 
}

void noteOff(int data)
{
  int pitch = chromaticScale[data]; 
  myBus.sendNoteOff(channel, pitch, 127); 
}

void delay(int time) 
{
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

int mapOneByte(float val, int max)
{
  print("val: "+ val);
  float processedVal = map(val, 0, max, 0, 255);
  return int(processedVal);
}
