#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

int g_LastClientButtons[MAXPLAYERS];

public Plugin myinfo =
{
    name        = "Drop item with [WALK] + [RELOAD]",
    author      = "Sch",
    description = "This plugin drops your current equiped item when you press the [WALK] + [RELOAD] buttons",
    version     = "0.0.1",
    url         = "n/a"
};

public void OnPluginStart()
{
    HookEvent("player_spawn", HookOnPlayerSpawn_Post);
    PrintToServer("\x04Caught item drop plugin is running");
}

public void HookOnPlayerSpawn_Post(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    PrintToChat(client, "\x04You can drop your current equiped item when you press the \x03[WALK] \x04and \x03[RELOAD] \x04buttons");
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
    if (buttons == (IN_SPEED | IN_RELOAD))
    {
        if (!IsValidClient(client))
        {
            return Plugin_Continue;
        }

        if (IsFakeClient(client))
        {
            return Plugin_Continue;
        }

        if ((g_LastClientButtons[client] & IN_RELOAD))
        {
            return Plugin_Continue;
        }

        int weaponEnt = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

        if (weaponEnt != -1)
        {
            SDKHooks_DropWeapon(client, weaponEnt);
        }
    }

    g_LastClientButtons[client] = buttons;
    return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}
