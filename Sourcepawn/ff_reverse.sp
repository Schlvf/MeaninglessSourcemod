#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

ConVar g_FFReversalMultiplier = null;

public Plugin myinfo =
{
    name        = "FF reversal",
    author      = "Sch",
    description = "This plugin redirects friendly fire back to the attacker and heals the target",
    version     = "0.0.1",
    url         = "n/a"
};

public void OnPluginStart()
{
    g_FFReversalMultiplier = CreateConVar("g_FFReversalMultiplier", "0.8", "Default FF reversal damage", FCVAR_NOTIFY);
    HookConVarChange(g_FFReversalMultiplier, HookOnDamageMultiplierChanged_Post);
    HookEvent("player_spawn", HookOnPlayerSpawn_Post);

    PrintToServer("\x04Friendly fire reversal plugin is running");
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, HookOnTakeDamage_Pre);
}

public void HookOnPlayerSpawn_Post(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    PrintToChat(client, "\x04Friendly fire reversal plugin is running");
    PrintToChat(client, "\x04The current reversal multiplier is \x03%.2f", g_FFReversalMultiplier.FloatValue);
}

public void HookOnDamageMultiplierChanged_Post(ConVar convar, const char[] oldValue, const char[] newValue)
{
    PrintToServer("\x04g_FFReversalMultiplier reversal multiplier changed from \x03%s \x04to \x03%s", oldValue, newValue);
}

public Action HookOnTakeDamage_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!(damagetype & DMG_BULLET))
    {
        // If the damage was not dealt with bullets
        return Plugin_Continue;
    }

    if (!WasValidFriendlyFireActors(victim, attacker))
    {
        // If the actors involved are not valid
        return Plugin_Continue;
    }

    int rDamage;
    rDamage = RoundToCeil(damage);

    PrintToChatAll("\x03%N \x04damaged \x03%N \x04for \x03%d", attacker, victim, rDamage);

    SDKHooks_TakeDamage(attacker, inflictor, attacker, damage * g_FFReversalMultiplier.FloatValue, damagetype);
    return Plugin_Handled;
}

stock bool WasValidFriendlyFireActors(int victim, int attacker)
{
    if (victim == attacker)
    {
        // If the victim and attacker are the same
        return false;
    }

    if (!IsValidClient(victim) || !IsValidClient(attacker))
    {
        // If the victim or attacker are not valid clients
        return false;
    }

    if (!IsPlayerAndSurvivor(victim) || !IsPlayerAndSurvivor(attacker))
    {
        // If the victim is not a human player or in the survivor team
        return false;
    }

    if (IsIncaped(victim))
    {
        // If the victim is incapacitated
        return false;
    }
    return true;
}

stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

stock bool IsPlayerAndSurvivor(int client)
{
    return (!IsFakeClient(client) && GetClientTeam(client) == 2);
}

stock bool IsIncaped(int client)
{
    return (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) > 0);
}
