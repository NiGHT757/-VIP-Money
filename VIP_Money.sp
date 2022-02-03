//------------------------------------------------------------------------------
// GPL LISENCE (short)
//------------------------------------------------------------------------------
/*
 * Copyright (c) 2014 R1KO

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.

 * ChangeLog:
		1.0.0 -	Релиз
		1.0.1 -	Исправлена выдача денег выше лимита
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools_functions>
#include <vip_core>
#include <cstrike>

public Plugin myinfo =
{
	name = "[VIP] Money",
	author = "R1KO (skype: vova.andrienko1), NiGHT",
	version = "1.0.1"
};

static const char g_sFeature[] = "Money";

ConVar mp_maxmoney;

int m_iAccount;
int g_iMaxMoney;

bool g_bLateLoaded;
bool g_bEnabled = false;
bool g_bEnable[MAXPLAYERS+1] = false;

char g_sMoneyValue[MAXPLAYERS+1][8];

public void OnPluginStart()
{
	LoadTranslations("vip_modules.phrases");
	m_iAccount = FindSendPropInfo("CCSPlayer", "m_iAccount");

	if (VIP_IsVIPLoaded())
	{
		VIP_OnVIPLoaded();
	}
	mp_maxmoney = FindConVar("mp_maxmoney");

	mp_maxmoney.AddChangeHook(OnSettingsChanged);

	if(g_bLateLoaded)
	{
		for(int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if(!IsClientInGame(iClient) || IsFakeClient(iClient))
			{
				continue;
			}

			VIP_OnVIPClientLoaded(iClient);
		}
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLateLoaded = late;
	return APLRes_Success;
}

public void OnSettingsChanged(ConVar convar, const char[] oldVal, const char[] newVal)
{
	g_iMaxMoney = mp_maxmoney.IntValue;
}

public void OnConfigsExecuted()
{
	g_iMaxMoney = mp_maxmoney.IntValue;
}

public void VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(g_sFeature, STRING, _, OnToggleItem, OnItemDisplay);
}

public void OnPluginEnd()
{
	if (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
	{
		VIP_UnregisterFeature(g_sFeature);
	}
}

public void OnMapStart()
{
	g_bEnabled = true;

	char map[MAX_NAME_LENGTH];
	GetCurrentMap(map, sizeof(map));

	if(strncmp(map, "35hp_", 5) == 0 || strncmp(map, "awp_", 4) == 0 || strncmp(map, "aim_", 4) == 0 || strncmp(map, "fy_", 3) == 0) g_bEnabled = false;
}

public void VIP_OnVIPClientLoaded(int iClient)
{
	g_bEnable[iClient] = VIP_IsClientFeatureUse(iClient, g_sFeature);
	VIP_GetClientFeatureString(iClient, g_sFeature, g_sMoneyValue[iClient], sizeof(g_sMoneyValue[]));
}

public Action OnToggleItem(int iClient, const char[] sFeatureName, VIP_ToggleState OldStatus, VIP_ToggleState &NewStatus)
{
	g_bEnable[iClient] = (NewStatus == ENABLED);
	return Plugin_Continue;
}

public bool OnItemDisplay(int iClient, const char[] szFeature, char[] szDisplay, int iMaxLength)
{
	if (g_bEnable[iClient])
	{
		FormatEx(szDisplay, iMaxLength, "%T [%s]", g_sFeature, iClient, g_sMoneyValue[iClient][(g_sMoneyValue[iClient][0] == '+') ? 1:0]);
		return true;
	}
	
	return false;
}

public void OnClientDisconnect(int iClient)
{
	g_bEnable[iClient] = false;
	g_sMoneyValue[iClient][0] = '\0';
}

public void VIP_OnPlayerSpawn(int iClient, int iTeam, bool bIsVIP)
{
	if(!g_bEnabled || !g_bEnable[iClient]) return;

	int Rounds = CS_GetTeamScore(2) + CS_GetTeamScore(3);
	if(Rounds == 0 || Rounds == 15)
		return;

	int iMoney;
	if(g_sMoneyValue[iClient][0] == '+')
	{
		iMoney = StringToInt(g_sMoneyValue[iClient][1])+GetEntData(iClient, m_iAccount);

		if(iMoney > g_iMaxMoney)
		{
			iMoney = g_iMaxMoney;
		}
	}
	else
	{
		StringToIntEx(g_sMoneyValue[iClient], iMoney);
	}

	SetEntData(iClient, m_iAccount, iMoney);
}