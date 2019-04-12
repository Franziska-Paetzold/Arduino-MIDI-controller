# MIDI Microcontroller 

The MMD is a tool to make sound via a self-made MIDI device. There are different modes offered to adjust your sound file or creating sounds.

Impression: https://youtu.be/YaeJ_txb2Yo

Jump dicectly to:
- [documentation](#How-to-use-it-(documentation))
- [play the controller](#Play)
- [build your own controller](#DIY-MIDI-Microcontrolller)

## How to use it (documentation)

### Play
 
1. Choose the mode via the potentiometer on the right side of the prototype. There are the following modes:
(First one is always x-axis, second one the y-axis alias distance to the sensors)
- chromatic scale (from C4 to B4 ) and volume 
- diatonic scale (from C3 to B3) and volume
- accord (dis3, g3, ais3, C4, D4 - a major 7 accord) and volume 
- accord and octaves
- manual mode 

`Hint: The first four modes work only with a synthesizer that recognizes CC7 (interpretation als volume change). If you are choosing the manual mode you can map any functionalily.`

2. Use one or more hands to play. The distance range is from the sensors up to 50cm. 

## DIY MIDI Microcontrolller

You want to build your own MIDI controller?
Cool, let's get started!

### Build the hardware

#### What you need for the hardware component 

- Arduino Uno
- lots of jumper wires
- bread borad
- 5 ultrosonic sensores

optional:
- potentiometer, to switch modes
- cardboard, to craft a case

#### Biuld a case
Let creativity run free, but here is a little help to cut the gaps for the ultrasonic sensors.

![build_a_case](https://user-images.githubusercontent.com/22836416/55933780-cf703880-5c2e-11e9-884c-be663f515e7c.png)

For boths kinds of sensors the distance from A to D is 5cm and the radius is 0,8cm.

Measurements for the Grove ones:
- A-B: 1,4cm
- A-C: 3,4cm

Measurements for HC-SR05s:
- A-B: 1,3cm
- A-C: 3,9cm

### Run the software 

#### Preperation for  the software component

- Please clone the repo (in case you don't know how, find help [here](https://help.github.com/en/articles/cloning-a-repository))

-  Make sure you have the following things ready and installed on your maschine:
  - the hardware (alias the MIDI Microcontroller)
  - [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html)
  - [Aduino IDE](https://www.arduino.cc/en/main/software)
    - Ultrasonic library is you are using for example the Grove ultrasonic sensors
  - [Processing](https://processing.org/download/)
    - [The MIDI bus library](http://www.smallbutdigital.com/projects/themidibus/)
  - DAW + Sythesizer of your choice (This tutorial guides you through [Ableton Live](https://www.ableton.com/de/trial/))

#### Setup

- Start the Arduino IDE. Optionally open the check_all_Sensors.ino, uploaded to your Arduino and read out the serial monitor. After that, close the monitor and open the physicalDataToSerialMonitor.ino. Upload it (attention: this time you have to make sure, that the serial monitor is not opened). You can close the Arduino IDE now.

`Hint: This works without issues for the original prototype. If you buildt your own one, plpease make sure to make some adjustments in the code at this point. Implement the correct way for the kind of ultrasonic sensor, that you are using.`

- Open loopMIDI add a virtual port by typing a name in the input field and selecting the +-button. You can close loopMIDI now.

- Open processing, please. Run the serialMonitorToMIDI.pde.

- Open your DAW. In Ableton Live, make sure in your preferences (option>preferences>link MIDI) ... your port is "on".

- Choose or install  a plugin, that recognizes CC7, for instance [prophet](https://www.arturia.com/products/analog-classics/prophet-v).

- If you want to use the manual mapping mode, click the "MIDI" button in the upper right corner. Now everything you can map is purple. Map functionality you want to by choosing a purple highlighted tool and using the controller in one direction.


#### Have fun. 
Now, just follow the [documentation](#How-to-use-it-(documentation)), have fun and be creative!
