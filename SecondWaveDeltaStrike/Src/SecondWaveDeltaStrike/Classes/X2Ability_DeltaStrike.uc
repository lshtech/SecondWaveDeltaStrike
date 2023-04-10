class X2Ability_DeltaStrike extends X2Ability_SharedStrike config(SecondWaveDeltaStrike);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local int	i;

	for(i = 0; i < class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses.Length; i++)
	{
		if (class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses[i].CreateAbility)
		{
			if (class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.LOG)
				`Log("SWDS: Creating ability " $ class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses[i].AbilityName);
			Templates.AddItem(CreateArmorStats(class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses[i].AbilityName, 
				class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses[i].Shield, 
				class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses[i].Armor, 
				class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses[i].Dodge, 
				class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.default.ArmorBonuses[i].Mobility));
		}	
	}
	
	//ENEMY
	Templates.AddItem(SWDS_ReactiveArmor());
	Templates.AddItem(SWDS_ForceField());	
	Templates.AddItem(SWDS_HyperRegen());	
	Templates.AddItem(SWDS_AdrenalineRush());	
	Templates.AddItem(SWDS_ChosenActionPoints());

	return Templates;
}


/////////////////////////////////////////////////////////////////////////
//					ENEMY DURABILITY ABILITIES
/////////////////////////////////////////////////////////////////////////


static function X2AbilityTemplate SWDS_ReactiveArmor()
{
	local X2AbilityTemplate						Template;
	local X2Effect_SWDS_ReactiveArmor			SWDS_ReactiveArmor;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SWDS_ReactiveArmor');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_absorption_fields";
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	SWDS_ReactiveArmor = new class'X2Effect_SWDS_ReactiveArmor';
	SWDS_ReactiveArmor.BuildPersistentEffect(1, true, false, false);
	SWDS_ReactiveArmor.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(SWDS_ReactiveArmor);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate SWDS_AdrenalineRush()
{
	local X2AbilityTemplate						Template;
	local X2Effect_SWDS_AdrenalineRush			SWDS_AdrenalineRush;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SWDS_AdrenalineRush');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adrenaline";
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	SWDS_AdrenalineRush = new class'X2Effect_SWDS_AdrenalineRush';
	SWDS_AdrenalineRush.BuildPersistentEffect(1, true, false, false);
	SWDS_AdrenalineRush.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(SWDS_AdrenalineRush);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate SWDS_ForceField()
{
	local X2AbilityTemplate						Template;
	local X2Effect_SWDS_ForceField				SWDS_ForceField;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SWDS_ForceField');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aethershift";
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	SWDS_ForceField = new class'X2Effect_SWDS_ForceField';
	SWDS_ForceField.BuildPersistentEffect(1, true, false, false);
	SWDS_ForceField.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(SWDS_ForceField);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate SWDS_HyperRegen()
{
	local X2AbilityTemplate						Template;
	local X2Effect_SWDS_HyperRegen				SWDS_HyperRegen;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SWDS_HyperRegen');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bioelectricskin";
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	SWDS_HyperRegen = new class'X2Effect_SWDS_HyperRegen';
	SWDS_HyperRegen.BuildPersistentEffect(1, true, false, false);
	SWDS_HyperRegen.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(SWDS_HyperRegen);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate SWDS_ChosenActionPoints() {
	local X2AbilityTemplate						Template;
	local X2Effect_SWDS_ChosenActionPoints				SWDS_ChosenActionPoints;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SWDS_ChosenActionPoints');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bioelectricskin";
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	SWDS_ChosenActionPoints = new class'X2Effect_SWDS_ChosenActionPoints';
	SWDS_ChosenActionPoints.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(SWDS_ChosenActionPoints);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}
