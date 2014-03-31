whopis
dan@hoverflytech.com

If this helps and you get somewhere with the crypto I would appreciate any help!


Usage:

Download firmware:

Use the propellent tool to load the image "ReadEEPROM5Mhz.eeprom" onto the badge (in ram only)

propellent.exe ReadEEPROM5Mhz.eeprom

When this runs, note the com port which the badge is attached to.


Then run the progam "PropHexReader.exe".

It will ask for the com port, the block (which 32kb block - looks like only block 0 has info), and the filename to save it to.




Upload firmware:

Use the propellent tool to load the image "WriteEEPROM5Mhz.eeprom" onto the badge (in ram only)

propellent.exe WriteEEPROM5Mhz.eeprom

Then run the program "PropHexWriter.exe" and supply it an eeprom file:

(for example)
PropHexWriter.exe virginbadge.eeprom

it will ask for the com port again.

It will write 256 pages of 128 bytes each to the eeprom then reboot the badge

