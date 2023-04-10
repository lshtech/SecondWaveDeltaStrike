//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2Effect_SWDS_AdrenalineRush extends X2Effect_Persistent config(GameData_SoldierSkills);

var config int BONUS_DODGE;
var config float HP_TRIGGER;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo AccInfo;

	// DISABLE IF NO DELTA STRIKE
	if(!`SecondWaveEnabled('DeltaStrike'))
		return;

	// CANCELED BY POISON
	if (Target.IsPoisoned())
		return;

	// only give a bonus if low health
	if(Target.GetCurrentStat(eStat_HP) > (Target.GetBaseStat(eStat_HP) * default.HP_TRIGGER))
		return;

	if (class'X2DownloadableContentInfo_SecondWave'.default.LOG)
		`LOG("SWDS: Adrenaline Rush: dodge bonus: " $ Target.GetCurrentStat(eStat_Dodge) + default.BONUS_DODGE);

	// Cuts accuracy chance while low health
	AccInfo.ModType = eHit_Graze;
	AccInfo.Value = Target.GetCurrentStat(eStat_Dodge) + default.BONUS_DODGE;
	AccInfo.Reason = FriendlyName;
	ShotModifiers.AddItem(AccInfo);
}

defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
