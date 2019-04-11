#include <Ultrasonic.h>

//potentiometer
int pot =0; //green, yellow
int potValue =0;

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
    ultrasonic_normal(triggerA, echoA, "A");
    ultrasonic_grove(sigB, "B");
    ultrasonic_normal(triggerC, echoC, "C");
    ultrasonic_normal(triggerD, echoD, "D");
    ultrasonic_grove(sigE, "E");
    
    Serial.print("Poti: "); 
    potValue = analogRead(pot);
    Serial.println(potValue);
}

//works for HC-SR05s
void ultrasonic_normal(int trigger,int echo,String indexLetter)
{
  digitalWrite(trigger, LOW); 
  delay(5); 
  digitalWrite(trigger, HIGH); 
  delay(10);
  digitalWrite(trigger, LOW);
  duration = pulseIn(echo, HIGH); 
  distance = (duration/2) * 0.03432; 
  
  if (distance == -1 or distance == 0 ) 
  {
    Serial.print(indexLetter); 
    Serial.println(" not working: no value");
  }
  else 
  {
    Serial.print(indexLetter);
    Serial.print(" works: "); 
    Serial.print(distance);
    Serial.println(" cm"); 
  }
  delay(500); 
}

void ultrasonic_grove(Ultrasonic ultrasonic, String indexLetter)
{
  distance = ultrasonic.MeasureInCentimeters(); 
  if (distance == -1 or distance == 0 ) 
  {
    Serial.print(indexLetter); 
    Serial.println(" not working: no value");
  }
  else 
  {
    Serial.print(indexLetter);
    Serial.print(" works: "); 
    Serial.print(distance);
    Serial.println(" cm"); 
  }
  delay(500); 
}
