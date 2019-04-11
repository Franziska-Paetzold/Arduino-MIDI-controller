#include <LcdBarGraphX.h>

#include <Wire.h>

int potPin = 0;
int val=0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

}

void loop() {
   val = analogRead(potPin);
  Serial.println(val);
  delay(500);

}
