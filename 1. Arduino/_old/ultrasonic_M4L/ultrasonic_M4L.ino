int trigger=7; 
int echo=6;  

int maxRange = 20;
int minRange = 0;

long duration=0; 
long distance=0;


void setup()
{
  Serial.begin (9600); 
  pinMode(trigger, OUTPUT); 
  pinMode(echo, INPUT); 
}

void loop()
{
  digitalWrite(trigger, LOW); 
  delayMicroseconds(2); 
  
  digitalWrite(trigger, HIGH); 
  delayMicroseconds(10);
  
  digitalWrite(trigger, LOW);
  duration = pulseIn(echo, HIGH); 
  
  distance = (duration/2) * 0.03432; 

  //error handling
  if (distance >= maxRange || distance <= minRange) 
  {
    Serial.println("-1"); 
  }
  else 
  {
    Serial.println(distance); 
  //  Serial.println(" cm"); 
  }

  //good practice to not overloa port
  delay(50); 
}
