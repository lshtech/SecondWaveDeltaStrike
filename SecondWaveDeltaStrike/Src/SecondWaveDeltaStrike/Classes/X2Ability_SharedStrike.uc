class X2Ability_SharedStrike extends X2Ability;

static function X2AbilityTemplate CreateArmorStats(Name TemplateName, int Shield, int Armor, int Dodge, int Mobility)
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	if (Armor > 0)
		PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, Armor);	
	if (Shield > 0)
		PersistentStatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, Shield);
	if (Mobility != 0)
		PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, Mobility);
	if (Dodge > 0)
		PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, Dodge);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}