#include <MIDI.h>

 // Created and binds the MIDI interface to the default hardware Serial port
 MIDI_CREATE_DEFAULT_INSTANCE();

 void setup()
 {
     MIDI.begin();  
     Serial.begin(115200);
 }

 void loop()
 {
     // Send note 42 with velocity 127 on channel 1
     MIDI.sendNoteOn(42, 127, 1);

     delay(1000);
     MIDI.sendNoteOn(42,0, 1);
     delay(1000);

     // Read incoming message
 }
