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
      println("new: " + inBuffer);
      distances = serialStringtoIntArray(inBuffer);
      distances = setBoundaries(distances, maxDistance);
      if (distances != null)
      {
       // playNotes(distances);
       chromaticScaleAndVolume(distances);
      }
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
      //ToDO
      
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
  int[] x = new int[12];
  for (int i=0; i<x.length; i++)
  {
    int currY=0;
    x[i]=y.length/12*i;
    
    //interpolate between sensors via functional equations to set volume
    currY  = getY(x,y,i);
    
    //sent MIDIs
    changeVolume(currY);
    if (x[i]>0)
    {
      noteOn(x[i]);
    }
    else
    {
      noteOff(x[i]);
    }
  }
}

int getY(int[] x, int[] y, int i)
{
  int currY = 0;
  if(x[i]>=x[0] && x[i]<x[1])
  {
    currY = calcFunctionalEquation(x[0], y[0], x[1], y[1], x[i]);
  }
  if(x[i]>=x[1] && x[i]<x[2])
  {
    currY = calcFunctionalEquation(x[0], y[0], x[1], y[1], x[i]);
  }
  if(x[i]>=x[2] && x[i]<x[3])
  {
    currY = calcFunctionalEquation(x[0], y[0], x[1], y[1], x[i]);
  }
  if(x[i]>=x[3] && x[i]<=x[4])
  {
    currY = calcFunctionalEquation(x[0], y[0], x[1], y[1], x[i]);
  }
  return currY;
}

int calcFunctionalEquation(int x1, int y1, int x2, int y2, int currX)
{
  int currY = 0;
  int n=0;
  int m=0;
  
  try 
  {
     m = (y2 - y1)/x2-x1;
  } 
  catch (ArithmeticException e) 
  {
    e.printStackTrace();
    print(x2, x1);
    return currY;
  }
  
 
  n =y2-m*x2;
  //calculate current y 
  currY = m*currX+n;
  return currY;
}

void changeVolume(int data)
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

int mapOneByte(int val, int max)
{
  float processedVal = map(val, 0, max, 0, 255);
  return int(processedVal);
}
