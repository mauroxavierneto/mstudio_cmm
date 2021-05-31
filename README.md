# mstudio_cmm
Studio for Colour Maximite 1 and 2

This is a studio that you can create sprites and maps for your Colour Maximite and listen to some chiptunes (for the CMM1 additional hardware is required).

The version for the Colour Maximite 2 is in development and soon will be uploaded to this repository.


-- THIS PART IS ONLY ABOUT THE CMM1 VERSION --

Rename the mstudio_cmm folder in a PC to MSTUDIO.

The program must be in the B:\MSTUDIO folder.

Expect many bugs as the MStudio for the CMM1 isn't update since 2019 (sorry).

IMPORTANTE NOTICE ABOUT THE CMM1 ADDITIONAL HARDWARE:

I'M NOT ASSUME ANY RESPONSABILIY IN THE INFORMATION ON THIS DOCUMENT.
IF YOU FRY YOUR COLOUR MAXIMITE OR ANY OTHER THINGS, IT'S YOURS RESPONSABILITY!

RECOMENDATIONS:

* On clock I recommend about 3.57 MHZ, do not pass 4 Mhz!
* On the SN76489 datasheet, the data pins are inverted, don't worry and use
  this readme instead
* Use a resistor about 500 ohms in each sound out from the chips before
  the sound line from your CMM.
* You can use only one SN76489, but you need to mix the mono sound using
  resistors or other way you want, otherwise all your other sounds turn
  mono with incorrect volume
* You can connect the three chips together without any problems (ex: D0-D8)

GENERAL PINOUTS TO MAKE YOUR SOUND BOARDS ON ARDUINO CONNECTOR
AND SOUND OUT IN YOUR COLOUR MAXIMITE 1 (open it in a notepad)

CMM     SN76489    PIN       AY-3-8910   PIN
                             (Or YM2149)

SND L   PSG 1 AO     7       AY CH AB    2 And 3
SND R   PSG 2 AO     7       AY CH C     38
D0      PSG 1&2 D0  10       AY D0       37
D1      PSG 1&2 D1  11       AY D1       36
D2      PSG 1&2 D2  12       AY D2       35
D3      PSG 1&2 D3  13       AY D3       34
D4      PSG 1&2 D4  15       AY D4       33
D5      PSG 1&2 D5   1       AY D5       32
D6      PSG 1&2 D6   2       AY D6       31
D7      PSG 1&2 D7   3       AY D7       30
D8      PSG 1&2 WE   5       AY BC1      29
D10     PSG 1 CE     6
D11     PSG 2 CE     6
D12                          AY RESET    23
D13                          YM SEL      26 (YM2149 Only!, In AY Leave N/C)
GND     PSG GND      8       AY GND       1
GND                          AY A9       24
VCC 5V  PSG VCC     16       AY VCC      40
VCC 5V                       AY BDIR     27
VCC 5V                       AY BC2      28
CLK     PSG CLOCK   14       AY CLOCK    22
