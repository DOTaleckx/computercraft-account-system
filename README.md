ComputerCraft Account System

This project was made for the [Valhelsia 6 modpack](https://www.curseforge.com/minecraft/modpacks/valhelsia-6) on CurseForge.
Special thanks to @OGabrieLima for their [LUA SHA-256 Hash Calculator](url) and ChatGPT for helping me figure out how to get it to work in ComputerCraft.

FEATURES:
- In-game account management database with flexible schema
- SHA-256 hashed 4-digit PIN numbers
- "lastSeen" property with in-game "day/time" tracking
- Option to set preferredName for users

REQUIRES:
- [CC:Tweaked](https://tweaked.cc/)
- [Advanced Peripherals](https://docs.advanced-peripherals.de/)
- Anything else Valhelsia 6 has that affects ComputerCraft

Really basic user registration and account database for CC:Tweaked + Advanced Peripherals.

To set this up, install these files into your ComputerCraft machine (I think in the same folder)
- users.db
- userdb.lua
- github.lua (poorly named, this file is what has the SHA-256 calculator)
- kiosk.lua

In my setup, I have a Player Detector from Advanced Peripherals on TOP of my in-game computer. Users must stand directly in front of the kiosk to be detected. There's certainly a better way to do this, that maybe I'll upload in a later version.

Once installed, you can run kiosk.lua from the command line to use.
Users who do not stand close enough will be instructed to move forward.
Users without an account in users.db will be prompted to register.
Users must set a 4-digit PIN code that gets hashed with SHA-256 calculator.
Users can set a preferred name if desired.

Future plans include better player detection, account management screen (can be found as showAccountManagement() function in kiosk.lua), network implementation, and more.

