import themidibus.*;
import processing.serial.*;

//for physical data
Serial myPort; 
String portName;


//for MIDI
MidiBus myBus;
int channel = 0;

//for procrssing data
int[] data = new int[6];
int[] distances = new int[5];
int maxDistance = 50;
int potValue =0;
int mode ;

//MIDI note numbers from C4 to B4 
int[] chromaticScale={72,73,74,75,76,77,78,79,80,81,82,83};
//MIDI note numbers from C3 to B3 
int[] diatonicScale={60,62,64,65,67,69,71};
//MIDI dis 3, g 3, ais 3, c 3, d4 
int[] accord={63,67,70,72,74};


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
      data = serialStringtoIntArray(inBuffer);
      potValue = data[0];
      //add distances to distance array
      distances = subset(data, 1);
      distances = setBoundaries(distances, maxDistance); //<>//
      //println("new and edited:" + distances[0], distances[1], distances[2], distances[3], distances[4]);
      if (distances != null)
      {
        mode = setMode(potValue);
        switch(mode) 
        {
          case 0: 
            chromaticScaleAndVolume(distances);
            break;
          case 1: 
            diatonicAndVolume(distances);
            break;
          case 2: 
            accordAndVolume(distances);
            break;
          case 3: 
            accordAndOctave(distances);
            break;
          case 4: 
            manualMapping(distances);
            break;
          default:            
            accordAndVolume(distances);   
            break;
        }
      }
      distances = null;
    }
  }  
  
}

//##################################################################################################################################
//##################################################################################################################################
//######################## functions to convert the physical, serial data into usable data #########################################
//##################################################################################################################################
//##################################################################################################################################

int[] serialStringtoIntArray(String string)
{ 
  int[] currData = new int[data.length];
  int indexCounter = 0;
  String distanceString ="";
  for (int i=0; i < string.length(); i++)
  {
    if(string.charAt(i) == '/')
    {      
      try 
      {
        currData[indexCounter] = int(distanceString);
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
  return currData;
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

//maps the distance to a value between 0 and 127
int mapOneByte(float val, int max)
{
  float processedVal = map(val, 0, max, 0, 127);
  return int(processedVal);
}

int setMode(int potValue)
{
  if(potValue >= 0 && potValue <=204)
  {
    mode = 0;
  }
  if(potValue >= 205 && potValue <=409)
  {
    mode = 1;
  }
  if(potValue >= 410 && potValue <=614)
  {
    mode = 2;
  }
  if(potValue >= 615 && potValue <=819)
  {
    mode = 3;
  }
  if(potValue >= 820 && potValue <=1023)
  {
    mode = 4;
  }
  
   return mode;
}

//##################################################################################################################################
//##################################################################################################################################
//###################################################### process data ##############################################################
//##################################################################################################################################
//##################################################################################################################################

//calculates 12 semitones and plays the volume depending on the distance to the sensors 
void chromaticScaleAndVolume(int[] distances)
{
  int[] y= distances;
  //stores positions on x axis
  float[] x = new float[12];
  //fill the array first
  for (int i=0; i<x.length; i++)
  {
    x[i]=y.length/12.0*float(i);
  }
  
  for (int i=0; i<x.length; i++)
  {
    float currY=0;
    
    //interpolate between sensors via functional equations to set volume
    currY  = getY(x,y,i);
    
    //sent MIDIs
    if(currY>0)
    {
      changeVolume(currY);
    }
    
    
    if (currY>0)
    {
       noteOn(chromaticScale[i]);
    }
    else
    {
      noteOff(chromaticScale[i]);
    } //<>//
  }
}

//TODO
void diatonicAndVolume(int[] distances)
{
  int[] y= distances;
  //stores positions on x axis
  float[] x = new float[7];
  //fill the array first
  for (int i=0; i<x.length; i++)
  {
    x[i]=y.length/7.0*float(i);
  }
  
  
  for (int i=0; i<x.length; i++)
  {
    float currY=0;
    
    //interpolate between sensors via functional equations to set volume
    currY  = getY(x,y,i);
    
    //sent MIDIs
    if(currY>0)
    {
      changeVolume(currY);
    }
    
    if (currY>0)
    {
       noteOn(diatonicScale[i]);
    }
    else
    {
      noteOff(diatonicScale[i]);
    }    
  }
}

void accordAndVolume(int[] distances)
{
  for (int i=0; i<distances.length; i++)
  {
    
    if(distances[i]>0)
      {
        changeVolume(distances[i]);
        noteOn(accord[i]);
      } 
    else
      {
        noteOff(accord[i]);
      }
  }
}

//TODO
void accordAndOctave(int[] distances)
{
  for (int i=0; i<distances.length; i++)
  {
  }
}

void manualMapping(int[] distances)
{  
  for (int i=0; i<distances.length; i++)
  {
    //TODO find free controller
    controllerChange(distances[i], 66);
    controllerChange(i, 67);
  }
}

//################################################# process data help functions #####################################################


//calculates y depending on bounderies (number of sensores)
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
    e.printStackTrace();
    print(x2, x1);
    return currY;
  }  
 
  n =y2-m*x2;
  //calculate current y 
  currY = m*currX+n;
  return currY;
}


//##################################################################################################################################
//################################################################################################################################## //<>//
//########################################### functions to send MIDI data ##########################################################
//##################################################################################################################################
//##################################################################################################################################

//notes 
void noteOn(int data)
{
  int pitch = data; 
  myBus.sendNoteOn(channel, pitch, 127); 
  //println("note played: "+pitch);
}

void noteOff(int data)
{
  int pitch = data;
  myBus.sendNoteOff(channel, pitch, 127);  
  //println("note off: "+pitch);
}

//controller changes
void changeVolume(float data)
{
  int mappedVal = mapOneByte(data, maxDistance);
  myBus.sendControllerChange(channel, 7, mappedVal);
  //println("changed volume to:" + mappedVal);
}

void controllerChange(int data, int controller)
{
  myBus.sendControllerChange(channel, controller, data);
}
