// Friendly Fire Protection
// And Eventual Removal Tool

/****************************************
This Plugin is an highly customizable
Friendly-Fire Protection Tool.
Permanent Ban or Time Ban, Kicking, How
Many Kicks before ban is allowed,
Slaying, Enable and Disable Reversed
Effect, etc.
****************************************/

/*
*
*
*	1.7 (by raziEiL [disawar1])
*	Fixed incorrect ban time
*
*	1.6			r2
*	Several bugs have been corrected
*	Code has been reorganized
*	New features are on the way in 1.6 r3
*
*
*/

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "1.7"
#define SURVIVORTEAM 2

ConVar FFProtection_Enable;
ConVar FFProtection_Punish;
ConVar FFProtection_Limit;
ConVar FFProtection_Kick;
ConVar FFProtection_Ban;
ConVar FFProtection_Warning;
ConVar FFProtection_WarningType;
ConVar FFProtection_WarnDisplay;
ConVar FFProtection_WarnDisplayType;
ConVar FFProtection_AttackerDisplay;
ConVar FFProtection_AttackerDType;
ConVar FFProtection_ShowVictim;
ConVar FFProtection_ShowDetail;
ConVar FFProtection_Slay;
ConVar FFProtection_Fire;
ConVar FFProtection_Incap;
ConVar FFProtection_TimeBan;
ConVar FFProtection_KickMax;
ConVar FFProtection_SlayAllowed;
ConVar FFProtection_Redirect;
ConVar FFProtection_Heal;
ConVar FFProtection_pAmount;
ConVar FFProtection_pRound;
ConVar FFProtection_pCampaign;

int totalDamage[MAXPLAYERS + 1];
int kickMax[MAXPLAYERS + 1];
int wasSlayed[MAXPLAYERS + 1];
int firstRound;

public Plugin myinfo =
{
	name = "Friendly Fire Protection Removal Tool",
	author = "Sky",
	description = "High-Customization Friendly-Fire Plugin",
	version = PLUGIN_VERSION,
	url = "http://sky-gaming.org"
};

public void OnPluginStart()
{
	CreateConVar("sky_ffpt_ver", PLUGIN_VERSION, "Sky_ffpt_Ver", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	HookEvent("player_hurt", PlayerHurt_Action);
	PrintToChatAll("\x03Sky's \x04Friendly-Fire Protection Tool \x03Loaded.");
}



public Action PlayerHurt_Action(Event event, const char[] name, bool dontBroadcast)
{
	int victimUserId = event.GetInt("userid");
	int attackerUserId = even.GetInt("attacker");
	bool headshot = event.GetBool("headshot");

	int healthRemaining = GetInt("health")
	int dealtHealthDmg = GetInt("dmg_health");
	int dealtArmorDmg = GetInt("dmg_armor");

	int damageType = GetInt("type")

	String weaponId = GetString("weapon")

	
	//PrintToChatAll("\x03 %N \x04damaged \x03 %N \x04for \x03 %d ", attackerUserId, victimUserId, dealtHealthDmg);
	PrintToChatAll("Attacker: %N \nVictim: %N \nHealthAmount: %d \nArmorAmount: %d \nWeapong: %N \nHealthRemaining: %d", attackerUserId, victimUserId, dealtHealthDmg, dealtArmorDmg, weaponId, healthRemaining);
	/*
	GetEventString(event, "weapon", WeaponCallBack, 32);

	if ((!IsValidEntity(victimUserId)) || (!IsValidEntity(attackerUserId)))
	{
		return Plugin_Continue;
	}
	
	if ((strlen(WeaponCallBack) <= 0) || (attackerUserId == victimUserId) || (GetClientTeam(victimUserId) != GetClientTeam(attackerUserId)) || GetClientTeam(attackerUserId) != 2 || IsIncaped(victimUserId))
	{
		return Plugin_Continue;
	}
	if(IsFakeClient(victimUserId))
	{
		PrintToChatAll("\x03 %N \x04damaged \x03 %N \x04for \x03 %d", attackerUserId, victimUserId, victimHurt);
		return Plugin_Continue;
	}
	if (StrEqual(WeaponCallBack, "inferno", false) || StrEqual(WeaponCallBack, "pipe_bomb", false) || StrEqual(WeaponCallBack, "fire_cracker_blast", false))
	{	
		return Plugin_Continue;

	}
	if (IsPlayerAlive(victimUserId) && IsClientInGame(victimUserId))
	{
		int victimHealth = GetClientHealth(victimUserId);
		if (GetConVarInt(FFProtection_Heal) == 1)
		{
			SetEntityHealth(victimUserId, (victimHealth+victimHurt));
		}
	}
	if (GetConVarInt(FFProtection_Punish) == 1)
	{
		
		if (IsPlayerAlive(attackerUserId) && IsClientInGame(victimUserId))
		{
			//int tellClient = GetClientOfUserId(GetEventInt(event, "attacker"));
			PrintToChatAll("\x03 %N \x04damaged \x03 %N \x04for \x03 %d", attackerUserId, victimUserId, victimHurt);
			if (GetConVarInt(FFProtection_Redirect) == 1) 
			{
				attackerHealth = (GetClientHealth(attackerUserId)-(victimHurt));
			}
			if (attackerHealth < 1)
			{
				if(GetEntProp(attackerUserId, Prop_Send, "m_currentReviveCount") >= GetConVarInt(FindConVar("survivor_max_incapacitated_count")))
				{
					ForcePlayerSuicide(attackerUserId);
				}
				else 
				{
					SetEntityHealth(attackerUserId, 1);
					SetIncapState(attackerUserId, 1);
					SetEntityHealth(attackerUserId, 299);
				}
			}
			else if (attackerHealth >= 1)
			{
				SetEntityHealth(attackerUserId, attackerHealth);
			}
		}
	}
	*/
	return Plugin_Continue;
}
/*
public Action damageAmount(int client, int args)
{
	ShowDamageAmount(client);
	return Plugin_Handled;
}

public Action ShowDamageAmount(int client)
{
	PrintToChat(client, "\x04Friendly-Fire This Round: \x03 %d",totalDamage[client]);
	return Plugin_Handled;
}


public Action forgiveAll(int client, int args)
{
	for (int index; index < MaxClients; index++)
	{
		totalDamage[index] = 0;
	}
	PrintToChatAll("\x04Friendly-Fire Calculations Reset \x03for all clients.");
}

public Action forgiveMe(int client, int args)
{
	totalDamage[client] = 0;
	PrintToChat(client, "\x04Friendly-Fire Calculations Reset \x03for %d");
}
*/
stock void SetIncapState(int client, int isIncapacitated)
{
	SetEntProp(client, Prop_Send, "m_isIncapacitated", isIncapacitated);
}

stock bool IsIncaped(int client)
{
	if(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)){
		return true;
	}
	return false;
}