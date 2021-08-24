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

#include <sdkhooks>

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
float g_fDmgFrc[3] = {0.0, 0.0, 0.0};
float g_fDmgPos[3] = {0.0, 0.0, 0.0};

public Plugin myinfo =
{
	name = "Friendly Fire Protection Removal Tool",
	author = "Sky",
	description = "High-Customization Friendly-Fire Plugin",
	version = PLUGIN_VERSION,
	url = "http://sky-gaming.org"
};

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnPluginStart()
{
	CreateConVar("sky_ffpt_ver", PLUGIN_VERSION, "Sky_ffpt_Ver", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	FFProtection_Enable = CreateConVar("l4d2_ffprotection_enable","1","Enable or Disable the plugin.");
	FFProtection_Punish = CreateConVar("l4d2_ffprotection_punish","1","Punish the Attacking Teammate?");
	FFProtection_Limit = CreateConVar("l4d2_ffprotection_fflimit","1","FF Damage Limit Enabled or Disabled. (Must be ON for Kick/Ban/Slay");
	FFProtection_Kick = CreateConVar("l4d2_ffprotection_kick","0","Friendly-Fire Limit at which to Kick Offender. 0 Disables.");
	FFProtection_Ban = CreateConVar("l4d2_ffprotection_ban","0","Friendly-Fire Limit at which to Ban Offender. 0 Disables. (Overrides Kick.)");
	FFProtection_Warning = CreateConVar("l4d2_ffprotection_warn","1","Enable or Disable Warning Attacker.");
	FFProtection_WarningType = CreateConVar("l4d2_ffprotection_warn_type","1","1 - Center Text (that small stuff) 2 - Hint Text 3 - Chat Text. (Defaults to 1 if invalid selection. Should not be same as display type due to conflict)");
	FFProtection_WarnDisplay = CreateConVar("l4d2_ffprotection_warn_display","0","Enables or Disables showing player damage amount caused by their friendly-fire.");
	FFProtection_WarnDisplayType = CreateConVar("l4d2_ffprotection_warn_display_type","1","1 - Center Text 2 - Hint Text 3 - Chat Text. (Defaults to 1 if invalid selection. Should not be same as warn type due to conflict)");
	FFProtection_AttackerDisplay = CreateConVar("l4d2_ffprotection_attacker_display","0","Enables Display of person who is attacking teammates.");
	FFProtection_AttackerDType = CreateConVar("l4d2_ffprotection_attacker_display_type","0","Attacker Display must be enabled. 1 (Center) 2 (Hint) 3 (Chat). If war, warn display, and attacker display enabled, encourage all 3 different values.)");
	FFProtection_ShowVictim = CreateConVar("l4d2_ffprotection_show_victim","0","If Attacker Display Enabled, Enables or Disables showing the victim.");
	FFProtection_ShowDetail = CreateConVar("l4d2_ffprotection_show_detail","0","If Enabled, shows full detail. Show victim, and attacker display must be enabled for this to work.");
	FFProtection_Slay = CreateConVar("l4d2_ffprotection_slay","0","When set above 0, will kill attacker when they pass the Friendly-Fire Limit set here.");
	FFProtection_Fire = CreateConVar("l4d2_ffprotection_fire","0","Enable or Disable Friendly-Fire through Molotov usage.");
	FFProtection_Incap = CreateConVar("l4d2_ffprotection_slay","1","Allow Friendly-Fire to Incapacitate the attacker?");
	FFProtection_TimeBan = CreateConVar("l4d2_ffprotection_timeban","15","If ban is enabled, the amount of time in minutes to ban the offender.");
	FFProtection_KickMax = CreateConVar("l4d2_ffprotection_kickmax","1","If at least 1, will kick offender this many times prior to ban. If 0, will never kick.");
	FFProtection_SlayAllowed = CreateConVar("l4d2_ffprotection_slay_enabled","1","Enable or Disable the plugin from slaying offenders.");
	FFProtection_Redirect = CreateConVar("l4d2_ffprotection_attacker_redirect","1","Enable or Disable the redirection of Friendly Fire upon the attacker.");
	FFProtection_Heal = CreateConVar("l4d2_ffprotection_victim_heal","1","Enable or Disable healing victim of damage received from Friendly-Fire.");
	FFProtection_pAmount = CreateConVar("l4d2_ffprotection_punish_amount","1","Amount of damage offender receives. If 0, received is same as dealt.");
	FFProtection_pRound = CreateConVar("l4d2_ffprotection_reset_round","1","Reset Friendly-Fire At the end of the round? (Overrides campaign reset)");
	FFProtection_pCampaign = CreateConVar("l4d2_ffprotection_reset_finale","0","Reset Friendly-Fire At the end of the campaign?");

	AutoExecConfig(true, "sky_ffpt_16r2");

	//HookEvent("player_hurt", PlayerHurt_Action);
	//HookEvent("round_end", RoundEnd);

	//HookEvent("round_start", RoundStart);

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
	//debug plugin enabled flag
	//PrintToServer("g_bCvarAllow: %b", g_bCvarAllow);
	//debug damage
	//PrintToServer("Vic: %i, Atk: %i, Inf: %i, Dam: %f, DamTyp: %i, Wpn: %i", victim, attacker, inflictor, damage, damagetype, weapon);
	PrintToChatAll("\x03 %N \x04damaged \x03 %N \x04for \x03 %f", attacker, victim, damage);
	//attacker and victim survivor checks
	if (IsValidClientAndInGameAndSurvivor(attacker) && IsValidClientAndInGameAndSurvivor(victim) && victim != attacker)
	{
		if (IsFakeClient(attacker) || IsFakeClient(victim) || IsIncaped(victim))
		{
			//treat friendly-fire from bot attacker normally, which is 0 damage anyway
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
		//debug weapon
		//PrintToServer("GL: %b, MG: %b, InfCls: %s, weapon: %i", bWeaponGL, bWeaponMG, sInflictorClass, weapon);
		//if weapon caused damage

		//apply reverseff_dmgmodifer damage modifier
		//damage = 1.0;
		
		//pan0s | 20-Apr-2021 | Fixed: Server crashes if reversing chainsaw damage makes the attacker incapacitated or dead.
		//pan0s | start chainsaw fix part 1
		/*if (bWeaponChainsaw)
		{
			//Create a DataPack to pass to ChainsawTakeDamageTimer.
			Handle dataPack = CreateDataPack();
			WritePackCell(dataPack, attacker);
			WritePackCell(dataPack, inflictor);
			WritePackCell(dataPack, victim);
			WritePackFloat(dataPack, damage);
			WritePackCell(dataPack, damagetype);
			WritePackCell(dataPack, weapon);
			for (int i=0; i<3; i++)
			{
				WritePackFloat(dataPack, damageForce[i]);
				WritePackFloat(dataPack, damagePosition[i]);
			}
			//adding a timer fixes the bug, reason unknown
			CreateTimer(0.01, ChainsawTakeDamageTimer, dataPack);
		}
		//pan0s | end chainsaw fix part 1
		*/
		else
		{
			if(GetClientHealth(victim) == 1)
			{
				SetIncapState(victim, 0);
				SetEntityHealth(victim, 1);
			}
			else
			{
				SetEntityHealth(victim, GetClientHealth(victim) + 1);
				SDKHooks_TakeDamage(victim, inflictor, attacker, 1.0, 0, weapon, g_fDmgFrc, g_fDmgPos);
			}			
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

int GetPlayerTempHealth(int client)
{
	Handle painPillsDecayCvar = INVALID_HANDLE;

	if (painPillsDecayCvar == INVALID_HANDLE)
	{
		painPillsDecayCvar = FindConVar("pain_pills_decay_rate");

		if (painPillsDecayCvar == INVALID_HANDLE)
			SetFailState("pain_pills_decay_rate not found.");
	}

	int tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * GetConVarFloat(painPillsDecayCvar))) - 1;
	PrintToChat(client, "TEMP HEALTH %d", tempHealth);
	return tempHealth < 0 ? 0 : tempHealth;
}

stock int GetTotalHealth(int client)
{
	int iHealth = GetEntProp(client, Prop_Send, "m_iHealth") + GetPlayerTempHealth(client);
	PrintToChat(client, "TOTAL HEALTH %d", iHealth);
	return iHealth;
}