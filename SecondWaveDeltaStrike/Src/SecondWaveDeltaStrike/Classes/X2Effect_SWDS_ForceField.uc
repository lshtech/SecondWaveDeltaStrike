//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2Effect_SWDS_ForceField extends X2Effect_Persistent config(GameData_SoldierSkills);

var config int ACC_CUT;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo AccInfo;
	local int adjustedMalus;

	// DISABLE IF NO DELTA STRIKE
	if(!`SecondWaveEnabled('DeltaStrike'))
		return;

	// only give a bonus if shielded
	if(Target.GetCurrentStat(eStat_ShieldHP) <= 0 || bMelee)
		return;

	adjustedMalus = min(default.ACC_CUT, default.ACC_CUT * (Target.GetCurrentStat(eStat_ShieldHP) / Target.GetMaxStat(eStat_ShieldHP)));

	if (class'X2DownloadableContentInfo_SecondWave'.default.LOG)
		`LOG("SWDS: Forcefield - Accuracy cut: -" $ adjustedMalus);

	// Cuts accuracy chance while shields exists
	AccInfo.ModType = eHit_Success;
	AccInfo.Value = -adjustedMalus;
	AccInfo.Reason = FriendlyName;
	ShotModifiers.AddItem(AccInfo);
}


defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
