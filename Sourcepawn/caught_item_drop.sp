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
    HookEvent("choke_start", HookOnPlayerGrab_Post);
    HookEvent("lunge_pounce", HookOnPlayerGrab_Post);
    HookEvent("charger_pummel_start", HookOnPlayerGrab_Post);
    HookEvent("jockey_ride", HookOnPlayerGrab_Post);
    HookEvent("round_start", HookOnPlayerSpawn_Post);
    PrintToServer("\x04[\x03CID\x04] - \x01Caught item drop plugin is running");
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
        PrintToChatAll("\x04[\x03CID\x04] - \x04%N \x03dropped his main weapon", client);
    }
}

public void HookOnPlayerSpawn_Post(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(5.0, Timer_ShowMessage);
}

stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

stock Action Timer_ShowMessage(Handle timer)
{
    PrintToChatAll("\x04[\x03CID\x04] - \x03You will drop your primary weapon when \x04pounced \x03or \x04grabbed");
    return Plugin_Stop;
}
