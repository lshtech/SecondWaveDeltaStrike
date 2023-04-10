class X2Effect_SWDS_HyperRegen extends X2Effect_Regeneration config(GameData_SoldierSkills);

var config float HYPER_REGEN_AMOUNT;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	if(!`SecondWaveEnabled('DeltaStrike'))
		return;

	RegenerationTicked(self, ApplyEffectParameters, NewEffectState, NewGameState, true);
}

function bool RegenerationTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit OldTargetState, NewTargetState;
	local int AmountToHeal;

	if(!`SecondWaveEnabled('DeltaStrike'))
		return false;

	if (class'X2DownloadableContentInfo_SecondWave'.default.LOG)
		 `LOG("SWDS: Hyper Regeneration triggering.");
	OldTargetState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (OldTargetState.IsBurning())
		return false;

	// If no value tracking for health regenerated is set, heal for the default amount
	AmountToHeal = OldTargetState.GetBaseStat(eStat_HP) * default.HYPER_REGEN_AMOUNT;
			
	// Perform the heal
	NewTargetState = XComGameState_Unit(NewGameState.ModifyStateObject(OldTargetState.Class, OldTargetState.ObjectID));
		
	//Don't overheal
	if(OldTargetState.GetCurrentStat(eStat_HP) + AmountToHeal > OldTargetState.GetBaseStat(eStat_HP))
		NewTargetState.ModifyCurrentStat(eStat_HP, OldTargetState.GetBaseStat(eStat_HP) - OldTargetState.GetCurrentStat(eStat_HP));
	else
		NewTargetState.ModifyCurrentStat(eStat_HP, AmountToHeal);

	if (EventToTriggerOnHeal != '')
		`XEVENTMGR.TriggerEvent(EventToTriggerOnHeal, NewTargetState, NewTargetState, NewGameState);
		
	return false;
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
	local XComGameState_Unit OldUnit, NewUnit;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local int Healed;
	local string Msg;
	local string Vis;

	OldUnit = XComGameState_Unit(ActionMetadata.StateObject_OldState);
	NewUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	Healed = NewUnit.GetCurrentStat(eStat_HP) - OldUnit.GetCurrentStat(eStat_HP);
	
	if( Healed > 0 )
	{
		Vis = "Restorative Smoke: </Heal>";
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		Msg = Repl(Vis, "<Heal/>", Healed);
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Msg, '', eColor_Good);
	}
}

defaultproperties
{
	EffectName="SWDS_HyperRegen"
}