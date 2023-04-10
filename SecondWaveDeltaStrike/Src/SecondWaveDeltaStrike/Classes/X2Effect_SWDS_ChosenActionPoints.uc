class X2Effect_SWDS_ChosenActionPoints extends X2Effect_Persistent config(GameData_SoldierSkills);

var config int NumActionPoints;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState) {
	local int idx;
	
	if(!`SecondWaveEnabled('DeltaStrike'))
		return;

	if ( UnitState.GetCurrentStat(eStat_HP) < UnitState.GetMaxStat(eStat_HP) ) {
		for (idx = 0; idx < NumActionPoints; ++idx) {
			ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.RunAndGunActionPoint);
		}
	}
}

function EffectAddedCallback(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState) {
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState != none) {
		ModifyTurnStartActionPoints(UnitState, UnitState.ActionPoints, none);
	}
}

DefaultProperties
{
	EffectAddedFn=EffectAddedCallback
}