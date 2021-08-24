#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0"

float g_fDmgFrc[3] = {0.0, 0.0, 0.0};
float g_fDmgPos[3] = {0.0, 0.0, 0.0};

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnPluginStart()
{
	PrintToChatAll("\x03Sky's \x04Friendly-Fire Protection Tool \x03Loaded.");

	for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i))
            continue;
        SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
    }
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (IsValidClientAndInGameAndSurvivor(attacker) && IsValidClientAndInGameAndSurvivor(victim) && victim != attacker)
	{
		int rDamage;
		rDamage = RoundToCeil(damage); 

		if (IsFakeClient(attacker) || IsIncaped(victim))
		{
			return Plugin_Continue;
		}
		if (IsFakeClient(victim))
		{
			PrintToChatAll("\x03 %N \x04damaged \x03 %N \x04for \x03 %d", attacker, victim, rDamage);
			return Plugin_Continue;
		}
		char sInflictorClass[32];
		if (inflictor > MaxClients)
		{
			GetEdictClassname(inflictor, sInflictorClass, sizeof(sInflictorClass));
		}
		
		//Banned damages
		if(IsWeaponGrenadeLauncher(sInflictorClass) || IsWeaponChainsaw(sInflictorClass) || IsWeaponThrowable(sInflictorClass))
		{
			return Plugin_Continue;
		}		
		else
		{
			PrintToChatAll("\x03 %N \x04damaged \x03 %N \x04for \x03 %d", attacker, victim, rDamage);
			if(GetClientHealth(victim) != 1)
			{
				//SetIncapState(victim, 0);
				//SetEntityHealth(victim, 1);
                //Victim Camera Shake
				SetEntityHealth(victim, GetClientHealth(victim) + 1);
				SDKHooks_TakeDamage(victim, inflictor, attacker, 1.0, 0, weapon, g_fDmgFrc, g_fDmgPos);
			}
            //Attacker damage
			SDKHooks_TakeDamage(attacker, inflictor, attacker, damage, damagetype, weapon, damageForce, damagePosition);
		}
		//no damage for victim
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

stock bool IsValidClientAndInGameAndSurvivor(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

stock bool IsWeaponGrenadeLauncher(char[] sInflictorClass)
{
	return (StrEqual(sInflictorClass, "grenade_launcher_projectile"));
}

stock bool IsWeaponMinigun(char[] sInflictorClass)
{
	return (StrEqual(sInflictorClass, "prop_minigun") || StrEqual(sInflictorClass, "prop_minigun_l4d1") || StrEqual(sInflictorClass, "prop_mounted_machine_gun"));
}

stock bool IsWeaponMelee(char[] sInflictorClass)
{
	return (StrEqual(sInflictorClass, "weapon_melee"));
}

stock bool IsWeaponChainsaw(char[] sInflictorClass)
{
	return (StrEqual(sInflictorClass, "weapon_chainsaw"));
}

stock bool IsWeaponThrowable(char[] sInflictorClass)
{
	return (StrEqual(sInflictorClass, "inferno") || StrEqual(sInflictorClass, "pipe_bomb") || StrEqual(sInflictorClass, "fire_cracker_blast"));
}

stock bool IsIncaped(int client)
{
	if(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)){
		return true;
	}
	return false;
}
