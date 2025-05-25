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
    HookEvent("round_start", HookOnPlayerSpawn_Post);
    PrintToServer("\x04[\x03DB\x04] - \x01Drop bind plugin is running");
}

public void HookOnPlayerSpawn_Post(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(5.0, Timer_ShowMessage);
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

stock Action Timer_ShowMessage(Handle timer)
{
    PrintToChatAll("\x04[\x03DB\x04] - \x03You can drop your current equiped item when you press the \x04[WALK] \x03and \x04[RELOAD] \x03buttons");
    return Plugin_Stop;
}