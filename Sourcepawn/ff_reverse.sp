#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

ConVar g_FFReversalMultiplier = null;
bool   g_Invulnerable[MAXPLAYERS];

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
    HookEvent("round_start", HookOnPlayerSpawn_Post);

    HookEvent("tongue_release", HookOnReviveOrRelease_Pre, EventHookMode_Pre);
    HookEvent("charger_pummel_end", HookOnReviveOrRelease_Pre, EventHookMode_Pre);
    HookEvent("jockey_ride_end", HookOnReviveOrRelease_Pre, EventHookMode_Pre);
    HookEvent("pounce_stopped", HookOnReviveOrRelease_Pre, EventHookMode_Pre);
    HookEvent("revive_success", HookOnReviveOrRelease_Pre, EventHookMode_Pre);

    HookEvent("tongue_grab", HookOnGrab_Post, EventHookMode_Post);
    HookEvent("charger_pummel_start", HookOnGrab_Post, EventHookMode_Post);
    HookEvent("jockey_ride", HookOnGrab_Post, EventHookMode_Post);
    HookEvent("lunge_pounce", HookOnGrab_Post, EventHookMode_Post);

    PrintToServer("\x04[\x03FF\x04] - \x01Friendly fire reversal plugin is running");
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, HookOnTakeDamage_Pre);
}

public void HookOnPlayerSpawn_Post(Event event, const char[] name, bool dontBroadcast)
{
    CreateTimer(5.0, Timer_ShowMessage);
}

public void HookOnDamageMultiplierChanged_Post(ConVar convar, const char[] oldValue, const char[] newValue)
{
    PrintToServer("\x04[\x03FF\x04] - \x04g_FFReversalMultiplier \x03reversal multiplier changed from \x04%s \x03to \x04%s", oldValue, newValue);
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

    PrintToChatAll("\x04[\x03FF\x04] - \x04%N \x03damaged \x04%N \x03for \x04%d", attacker, victim, rDamage);

    SDKHooks_TakeDamage(attacker, inflictor, attacker, damage * g_FFReversalMultiplier.FloatValue, damagetype);
    return Plugin_Handled;
}

public void HookOnReviveOrRelease_Pre(Event event, const char[] name, bool dontBroadcast)
{
    int  client;
    bool wasRes = false;

    if (StrEqual(name, "revive_success"))
    {
        client = GetClientOfUserId(event.GetInt("subject"));
        wasRes = true;
    }
    else {
        client = GetClientOfUserId(event.GetInt("victim"));
    }

    if (!IsValidClient(client))
    {
        return;
    }

    if (wasRes)
    {
        g_Invulnerable[client] = true;
    }

    CreateTimer(2.0, Timer_Callback, client);
}

public void HookOnGrab_Post(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("victim"));

    if (!IsValidClient(client))
    {
        return;
    }

    g_Invulnerable[client] = true;
}

stock Action Timer_Callback(Handle timer, int client)
{
    g_Invulnerable[client] = false;
    return Plugin_Stop;
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

    if (IsIncaped(victim) || g_Invulnerable[victim])
    {
        // If the victim is incapacitated or invulnerable
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
    return (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0);    // Downed
}

stock Action Timer_ShowMessage(Handle timer)
{
    PrintToChatAll("\x04[\x03FF\x04] - \x03Friendly fire reversal plugin is running. The current reversal multiplier is \x04%.2f", g_FFReversalMultiplier.FloatValue);
    return Plugin_Stop;
}