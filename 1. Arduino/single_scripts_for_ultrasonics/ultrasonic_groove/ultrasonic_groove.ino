#include <Ultrasonic.h>

Ultrasonic ultrasonic(8);
void setup()
{
    Serial.begin(9600);
}
void loop()
{
    long RangeInCentimeters;

    RangeInCentimeters = ultrasonic.MeasureInCentimeters(); // two measurements should keep an interval
    Serial.write(RangeInCentimeters);//0~400cm
    delay(500);
}
