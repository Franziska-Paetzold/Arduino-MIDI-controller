int trigger=7; 
int echo=6; 

//nc = trigger
//sig = echo j

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
  delay(5); 
  digitalWrite(trigger, HIGH); 
  delay(10);
  digitalWrite(trigger, LOW);
  duration = pulseIn(echo, HIGH); 
  distance = (duration/2) * 0.03432; 
  

  Serial.write(distance); 
  delay(1000); 
}
