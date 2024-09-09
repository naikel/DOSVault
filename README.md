# DOSVault

![Steam Deck running DOSVault](https://raw.githubusercontent.com/naikel/DOSVault/master/screenshots/SteamDeckCanvas.png)
DOSVault is an unofficial port of *[eXoDOS](https://www.retro-exo.com/exodos.html)* that's optimized for the Steam Deck but it can also be run on any Linux distro. It uses [Pegasus](https://pegasus-frontend.org/) as a frontend and [DOSBox-X](https://dosbox-x.com/) as the emulator. It's basically a group of scripts that will allow you to have an eXoDOS-like installation in your Steam Deck/Linux box.

DOSVault behaves like the eXoDOS Lite version, and the games are installed on-demand. To install DOSVault, you need at least 12 GB free. After DOSVault is installed and deletes the installation files it will go down to around 5 GB.

## Screenshots
You can some screenshots [here](screenshots/README.md).

## Quick Guide
If you're installing DOSVault on a Steam Deck you have to switch to *desktop mode* first.

Download and install the .flatpak file:

    wget https://github.com/naikel/DOSVault/releases/download/latest/com.yappari.DOSVault.flatpak
    sudo flatpak install --reinstall com.yappari.DOSVault.flatpak

Load Steam and click on the *Add a Game* link on the bottom, and select *Add a Non-Steam Game...* and look for DOSVault.

To exit a game: press the **Right Analog Trigger**!

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

## Limitations
Compared to eXoDOS that uses LaunchBox, this project only does a tiny amount of what eXoDOS is capable. eXoDOS is a huge catalog that not only includes the games, but the user manuals, art, magazines, lots of extras, etc. Also eXoDOS supports several emulators, including SCUMMVM, and different versions of DOSBox.

DOSVault will launch every game using DOSBox-X at this time (but all of them should work!).

While in most of the games you can choose the graphics card, a few games will be forced to MCGA/VGA. This is because some eXoDOS games have external .bat files that only work on Windows to choose the graphics card. Most games have a _run.bat_ file that runs inside the emulator that let you choose graphics and sound cards and those work fine.

Single player games should work fine, but multiplayer games that rely on network will probably fail.


## Bugs
* If you connect the Steam Deck to an external monitor, the native mouse can only reach 1280x800. This is a bug in the game mode of the Steam Deck. This will cause problems in the DOSBox-X Configuration Tool and the Button Mapper windows, where you won't be able to reach some buttons. Some workarounds are:
   * Perform your configuration using the native Steam Deck screen, and then connect it to an external screen when you are ready to play a game.
   * Map the "Toggle Fullscreen" action to a button and play the game in fullscreen. This will play the game at 1280x800 and hopefully you won't notice the difference. You can clearly notice the difference in the DOS prompt. 
*  If your screen is flashing for whatever reason, press **Left Analog Trigger** + **Y** to re-capture the mouse, it usually fixes everything (it's a DOSBox-X bug).

## Building
If you want to build DOSVault yourself, you will need to install these packages:

 - git
 - flatpak
 - flatpak-builder

Clone this repository using _git clone_, and then just issue the command:

    ./build.sh [build-dir]
    
The _build-dir_ parameter is optional and points to a directory for the build. If you don't include it, the build directory will be:

    $HOME/DOSVault-build

At the end of the build process you will have a *com.yappari.DOSVault.flatpak* file in the build directory.

## Patches
Both Pegasus and DOSBox-X have been patched to look/work better on a Steam Deck. Patches included are:
* **Pegasus**
   * Ability to run commands inside the same flatpak (this allows the emulator to be executed).
   * Assigned UNIX signal SIGHUP to rescan the database.
* **DOSBox-X**
   * Simple notifications were implemented (so the user knows when he changes slots and saves to/loads from them).
   * Changed Button Mapper resolution from 640x480 to 1280x800 (because it was too tiny on the Deck).



