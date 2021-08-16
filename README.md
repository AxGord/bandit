Bandit and Dungeon
==================

Simple platform game example
-----------------

Haxe + Heaps + Pony

Play: <https://axgord.github.io/bandit/>

MacOS and Windows build: <https://github.com/AxGord/bandit/releases/>

Dungeon assets: <https://bakudas.itch.io/generic-dungeon-pack>

Bandit assets: <https://sventhole.itch.io/bandits>

Build
-----------------

1. Install lts Node.JS <https://nodejs.org/>
2. Install latest Haxe <https://haxe.org/>
3. Install TexturePacker <https://www.codeandweb.com/texturepacker>
4. Install Pony (`haxelib install pony && haxelib run pony`) <https://github.com/AxGord/Pony>
5. `cd PROJECT_DIR && pony prepare && pony build all` or open in VSCode (enable all recommended extensions and allow automatic tasks) <https://code.visualstudio.com>

Build and pack commands
-----------------

All targets: `pony zip all`

HTML version: `pony zip js`

MacOS build: `pony zip mac`

Windows build: `pony zip win`