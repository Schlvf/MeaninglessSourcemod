# L4D2 Plugins

This is a small collection of plugins that were updated/refactored so they can run over the Sourcepawn/Sourcemod version `1.12`

## Disclaimer

The plugins listed below were originally created by various authors from the **AlliedModders** community. I do not claim ownership of the original implementations. My contribution was limited to updating/refactoring the code to ensure compatibility with the latest version of SourcePawn and making functional adjustments based on personal preference. All credit for the original concepts and development goes to the respective creators.

|PLUGIN|SM VERSION|ORIGINAL|AUTHORS|
|-|-|-|-|
|Friendly-Fire Reversal|1.12|[Friendly-Fire Protection Tool](https://forums.alliedmods.net/showthread.php?t=137558)|Skyy|
|Drop bind|1.12|[Item Drop](https://forums.alliedmods.net/showthread.php?t=158962)|panxiaohai / Frustian|
|Caught item drop|1.12|[Item Drop](https://forums.alliedmods.net/showthread.php?t=158962)|panxiaohai / kwski43|

## Plugins

### Friendly-Fire Reversal

This plugin will redirect the survivor friendly **`bullet damage`** back to the attacker and prevent the target from receiving the damage at all\
*Please note that it **won't** work with bots or if the target is incapacitated*

### Drop bind

This plugin will drop your current equiped item when you press the `[WALK]` + `[RELOAD]` buttons

### Caught item drop

This plugin will drop a survivor's primary weapon when they get `pounced` or `grabbed` by an infected\
*Please note that it **will** work with bots and incapacitated targets*

## How-to

### Installation

To install the `Sourcemod` engine please follow their [official documentation](https://wiki.alliedmods.net/Installing_SourceMod)

Once `Sourcemod` has been installed, simply download the files in the `SMX` folder and put then in your plugins folder\
Example: `~\Steam\steamapps\common\Left 4 Dead 2\left4dead2\addons\sourcemod\plugins`

### Compiling your own plugins

If you have any issues with the `.smx` files you can edit the `.sp` source file inside the `Sourcepawn` folder and compile it on your own. Learn more about it in the [official documentation](https://wiki.alliedmods.net/Compiling_SourceMod_Plugins)
