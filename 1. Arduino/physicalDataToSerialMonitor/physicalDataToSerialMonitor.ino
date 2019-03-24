#include <Ultrasonic.h>

//sensors from left to right
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
    ultrasonic_normal(triggerA, echoA, 200);
    ultrasonic_grove(sigB, 201);
    ultrasonic_normal(triggerC, echoC, 202);
    ultrasonic_normal(triggerD, echoD, 203);
    ultrasonic_grove(sigE, 204);   
    delay(500); 
}

//works for HC-SR05s
void ultrasonic_normal(int trigger,int echo,int index)
{
  digitalWrite(trigger, LOW); 
  delay(5); 
  digitalWrite(trigger, HIGH); 
  delay(10);
  digitalWrite(trigger, LOW);
  duration = pulseIn(echo, HIGH); 
  distance = (duration/2) * 0.03432; 
  
  Serial.write(index); 
  if (distance < 100)
  {
    Serial.write(distance);
  }
}

void ultrasonic_grove(Ultrasonic ultrasonic, int index)
{
  distance = ultrasonic.MeasureInCentimeters(); 
  Serial.write(index);
  if (distance < 100)
  {
    Serial.write(distance);
  }
}
