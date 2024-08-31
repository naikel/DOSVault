# DOSVault

DOSVault is a port of *[eXoDOS](https://www.retro-exo.com/exodos.html)* that's optimized for the Steam Deck but it can also be run on any Linux distro. It uses [Pegasus](https://pegasus-frontend.org/) as a frontend.

DOSVault behaves like the eXoDOS Lite version, and the games are installed on-demand. To install DOSVault, you need at least 12 GB free. After DOSVault is installed and deletes the installation files it will go down to around 5 GB.

## Quick Guide
If you're installing DOSVault on a Steam Deck you have to switch to *desktop mode* first.

Download and install the .flatpak file:

    sudo flatpak install --reinstall com.yappari.DOSVault.flatpak

Load Steam and click on the *Add a Game* link on the bottom, and select *Add a Non-Steam Game...* and look for DOSVault.

That's it! Enjoy!
## Controls
The default mapping for the gamepad is like this:

 - **Right Analog Trigger**: Exit game
 - **Select**: DOSBox Mapper Editor
 - **Start**: DOSBox Configuration Tool
 - **L1**: Alt key 
 - **R1**: Ctrl key
 - **Y**: Escape key
 - **X**: Enter key
 - **A**: Joystick button 1
 - **B**: Joystick button 2

Pressing and holding the **Left Analog Trigger** you get these:

 - **L1**: Previous save slot
 - **R1**: Next save slot
 - **Y**: Capture mouse
 - **X**: Normal emulation speed
 - **A**: Save to slot
 - **B**: Load from slot

Playing a DOS game without a keyboard can be challenging! That's why you're encouraged to change the mapping of your games using the _DOSBox Mapper Editor_ pressing the **Select** button. Each game will have a different mapping.

Also there's 100 save slots per game!

If you're playing a game that use the mouse and the mouse feels erratic, press  **Left Analog Trigger** + **Y** to capture the mouse. 

If you feel like the game is lagging, press **Left Analog Trigger** + **X** to reset the emulation speed.
## Tips & Tricks
The following are tips & tricks I personally suggest. You can start from there, but at the end of the day you can reconfigure everything as you want!

* Configure your **Rear Buttons** or **Back Grips** on your Steam Deck! They will help you a lot! Edit your button layout. If you have no idea what to put there, here's a suggestion:
   * **L4**: Regular Press: 1, Long Press: Y
   * **R4**: Regular Press: 2, Long Press: N
   * **L5**: Regular Press: 3
   * **R5**: Regular Press: 4
*  Configure your **Right Trackpad** as a mouse:
   * **Click**: Left Mouse Click
   * **Touch Double Press**: Right Mouse Click
* If your game uses a mouse and is being erratically press  **Left Analog Trigger** + **Y** to capture the mouse. 


## Bugs & Limitations
* If you connect the Steam Deck to an external monitor, the native mouse can only reach 1280x800. This is a bug in the game mode of the Steam Deck. This will cause problems in the DOSBox-X Configuration Tool window, where you won't be able to reach some buttons. Some workarounds are:
   * Perform your configuration using the native Steam Deck screen, and then connect it to an external screen when you want to play a game.
   * Map the "Toggle Fullscreen" action to a button and play the game in fullscreen. This will play the game at 1280x800 and you won't notice the difference. You can clearly notice the difference in the DOS prompt. 
*  If your screen is flashing for whatever reason, press **Left Analog Trigger** + **Y** to re-capture the mouse, it usually fixes everything (it's a DOSBox-X bug).
