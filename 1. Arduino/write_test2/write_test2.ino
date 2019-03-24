void setup() {
  // put your setup code here, to run once:

}

void loop() {
  int val1 = 10;
  // put your main code here, to run repeatedly:
  //read first sensor
  String s = String(val1) + "/";
  writeString(s);
}

void writeString(String stringData) { // Used to serially push out a String with Serial.write()

  for (int i = 0; i < stringData.length(); i++)
  {
    Serial.write(stringData[i]);   // Push each char 1 by 1 on each loop pass
  }

}// end writeString 
