#include <Ultrasonic.h>

//potentiometer
int pot =0; //green, yellow
int potValue =0;

//sensors from left to right, information for the colors of the wires behind
int triggerA=13;  //yellow, yellow
int echoA=12; //white white

Ultrasonic sigB(10); //white, white

int triggerC=9; //yellow, yellow
int echoC=8; //white,white

int triggerD=7; //green,green
int echoD=6; //grey, grey

Ultrasonic sigE(4);  //white, whihte

long duration=0; 
long distance=0; 

String outputString = "";

void setup()
{
  Serial.begin (9600); 

  //just the HC-SR05s
  pinMode(triggerA, OUTPUT); 
  pinMode(echoA, INPUT);
  pinMode(triggerC, OUTPUT); 
  pinMode(echoC, INPUT);
  pinMode(triggerD, OUTPUT); 
  pinMode(echoD, INPUT);
}

void loop()
{   
    //poti value
    potValue = analogRead(pot);
    outputString += String(potValue);
    outputString += "/";
    
    //get distance 
    ultrasonic_normal(triggerA, echoA);
    ultrasonic_grove(sigB);
    ultrasonic_normal(triggerC, echoC);
    ultrasonic_normal(triggerD, echoD);
    ultrasonic_grove(sigE); 

    //line break after every sensor is has checked for an obstacle once 
    outputString += "\n";
    //Serial.write() for the whole string
    writeString(outputString);
    
    delay(500); 
}

//works for HC-SR05s
void ultrasonic_normal(int trigger,int echo)
{
  digitalWrite(trigger, LOW); 
  delay(5); 
  digitalWrite(trigger, HIGH); 
  delay(10);
  digitalWrite(trigger, LOW);
  duration = pulseIn(echo, HIGH); 
  distance = (duration/2) * 0.03432; 

  outputString += String(distance) + "/";
}

void ultrasonic_grove(Ultrasonic ultrasonic)
{
  distance = ultrasonic.MeasureInCentimeters(); 
  outputString += String(distance) + "/";
}

// Used to serially push out a String with Serial.write()
void writeString(String stringData) 
{ 
  for (int i = 0; i < stringData.length(); i++)
  {
    // Push each char 1 by 1 on each loop pass
    Serial.write(stringData[i]);   
  } 
  outputString = "";
}
