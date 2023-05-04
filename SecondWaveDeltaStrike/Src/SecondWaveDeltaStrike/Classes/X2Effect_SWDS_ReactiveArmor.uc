//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2Effect_SWDS_ReactiveArmor extends X2Effect_Persistent config(GameData_SoldierSkills);

var config float DAMAGE_CUT;
var config int CRIT_CUT;
var config int CRIT_BONUS;

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, 
										const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local XComGameState_Unit Defender;
	
	// DISABLE IF NO DELTA STRIKE
	if(!`SecondWaveEnabled('DeltaStrike'))
		return 0;

	Defender = XComGameState_Unit(TargetDamageable);

	// while armor exists, cut damage
	if(Defender.GetCurrentStat(eStat_ArmorMitigation) > 0){
		if (class'X2DownloadableContentInfo_SecondWave'.default.LOG)
			`LOG("SWDS: Reactive Armor - damage cut!");
		return -(default.DAMAGE_CUT * CurrentDamage);
	}

}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo CritInfo;

	// DISABLE IF NO DELTA STRIKE
	if(!`SecondWaveEnabled('DeltaStrike'))
		return;

	// only give a bonus if armor isn't shredded
	if(Target.GetCurrentStat(eStat_ArmorMitigation) <= 0)
	{
		// incraeses crit chance while armor is gone
		CritInfo.ModType = eHit_Crit;
		CritInfo.Value = default.CRIT_CUT;
		CritInfo.Reason = FriendlyName;
	}
	else	
	{
		// Cuts crit chance while armor exists
		CritInfo.ModType = eHit_Crit;
		CritInfo.Value = - default.CRIT_CUT;
		CritInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(CritInfo);
	}
	
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, FriendlyName, '', eColor_Bad);
}

defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
