#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
    name        = "Caught item drop",
    author      = "Sch",
    description = "This plugin drops your primary weapon when pounced or grabbed",
    version     = "0.0.1",
    url         = "n/a"
};

public void OnPluginStart()
{
    PrintToServer("\x04Caught item drop plugin is running");
    HookEvent("choke_start", HookOnPlayerGrab_Post);
    HookEvent("lunge_pounce", HookOnPlayerGrab_Post);
    HookEvent("charger_pummel_start", HookOnPlayerGrab_Post);
    HookEvent("jockey_ride", HookOnPlayerGrab_Post);
    HookEvent("player_spawn", HookOnPlayerSpawn_Post);
}

public void HookOnPlayerGrab_Post(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("victim"));

    if (!IsValidClient(client))
    {
        return;
    }

    int weapon = GetPlayerWeaponSlot(client, 0);

    if (weapon != -1)
    {
        SDKHooks_DropWeapon(client, weapon);
        PrintToChatAll("\x03%N \x04dropped his main weapon", client);
    }
}

public void HookOnPlayerSpawn_Post(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    PrintToChat(client, "\x04You will drop your primary weapon when pounced or grabbed");
}

stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}
