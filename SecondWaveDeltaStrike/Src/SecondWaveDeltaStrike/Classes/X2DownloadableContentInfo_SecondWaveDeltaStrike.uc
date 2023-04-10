class X2DownloadableContentInfo_SecondWaveDeltaStrike extends X2DownloadableContentInfo_SecondWave config(SecondWaveDeltaStrike);

	var config array<UnitStatBonuses> 	DeltaStrikeBonuses;
	var config UnitStatBonuses			DeltaStrikeRobotic;
	var config UnitStatBonuses			DeltaStrikePsionic;
	var config UnitStatBonuses			DeltaStrikeAdvent;
	var config UnitStatBonuses			DeltaStrikeAlien;
	var config UnitStatBonuses			DeltaStrikeAlienMelee;
	var config UnitStatBonuses			DeltaStrikeRuler;
	var config UnitStatBonuses			DeltaStrikeChosen;

	var config array<ArmorBonus> ArmorBonuses;

static event OnPostTemplatesCreated()
{}

static function DeltaStrikeAssignUnitAbilities(X2CharacterTemplate CharacterTemplate)
{
	local UnitStatBonuses	UnitBonus;

	// Check by Template Name
	foreach default.DeltaStrikeBonuses(UnitBonus)
	{
		if (CharacterTemplate.Name == UnitBonus.UnitName)
		{
			AssignUnitAbility(CharacterTemplate, UnitBonus);
			return;
		}
	}

	// Check by group name
	foreach default.DeltaStrikeBonuses(UnitBonus)
	{
		if (CharacterTemplate.CharacterGroupName == UnitBonus.GroupName)
		{
			AssignUnitAbility(CharacterTemplate, UnitBonus);
			return;
		}
	}

	// Alien Ruler
	if(CharacterTemplate.Name == 'ViperKing' || CharacterTemplate.Name == 'BerserkerQueen' || CharacterTemplate.Name == 'ArchonKing'){
		AssignUnitAbility(CharacterTemplate, default.DeltaStrikeRuler);
		return;
	}

	// Chosen
	if(CharacterTemplate.bIsChosen){
		AssignUnitAbility(CharacterTemplate, default.DeltaStrikeChosen);		
		return;
	}

	// Robotic
	if(CharacterTemplate.bIsRobotic)
	{
		AssignUnitAbility(CharacterTemplate, default.DeltaStrikeRobotic);
		return;
	}

	// Psionic
	if(CharacterTemplate.bIsPsionic)
	{
		AssignUnitAbility(CharacterTemplate, default.DeltaStrikePsionic);
	}

	// Advent
	if(CharacterTemplate.bIsAdvent)
	{	
		AssignUnitAbility(CharacterTemplate, default.DeltaStrikeAdvent);
	}

	// Aliens
	if(CharacterTemplate.bIsAlien)
	{
		//BERSERKERS/FACELESS
		if(CharacterTemplate.bIsMeleeOnly)
		{
			AssignUnitAbility(CharacterTemplate, default.DeltaStrikeAlienMelee);
			return;
		}

		AssignUnitAbility(CharacterTemplate, default.DeltaStrikeAlien);
	}
}

static function AssignUnitAbility(X2CharacterTemplate CharacterTemplate, UnitStatBonuses Bonuses)
{
	local name	Ability;
	local int	i;

	foreach Bonuses.Abilities(Ability)
	{
		i = CharacterTemplate.Abilities.Find(Ability);
		if (i != INDEX_NONE)
			continue;

		CharacterTemplate.Abilities.AddItem(Ability);

		if (default.LOG)
			`Log("SWDS: Adding ability " $ Ability $ " to " $ CharacterTemplate.Name);
	}
}


static function DeltaStrikeAssignUnitStats(XComGameState_unit Unit)
{
	local UnitStatBonuses	UnitBonus;

	// Taken from shiremct 'Point-Based NCE'
	// Exit if the function is being called a second time from ApplyFirstTimeStatModifiers()
	// HACK to detect this hijacking the bGotFreeFireAction variable
	if (Unit.bGotFreeFireAction)
	{
		Unit.bGotFreeFireAction = false;
		return;
	}

	// Check by Template Name
	foreach default.DeltaStrikeBonuses(UnitBonus)
	{
		if (Unit.GetMyTemplateName() == UnitBonus.UnitName)
		{
			AssignUnitStatsFromConfig(Unit, UnitBonus);
			return;
		}
	}

	// Check by group name
	foreach default.DeltaStrikeBonuses(UnitBonus)
	{
		if (Unit.GetMyTemplateGroupName() == UnitBonus.GroupName)
		{
			AssignUnitStatsFromConfig(Unit, UnitBonus);
			return;
		}
	}

	// Alien Ruler
	if(Unit.GetMyTemplateName() == 'ViperKing' || Unit.GetMyTemplateName() == 'BerserkerQueen' || Unit.GetMyTemplateName() == 'ArchonKing'){
		AssignUnitStatsFromConfig(Unit, default.DeltaStrikeRuler);
		return;
	}

	// Chosen
	if(Unit.IsChosen()){
		AssignUnitStatsFromConfig(Unit, default.DeltaStrikeChosen);		
		return;
	}

	// Robotic
	if(Unit.IsRobotic())
	{
		AssignUnitStatsFromConfig(Unit, default.DeltaStrikeRobotic);
		return;
	}

	// Psionic
	if(Unit.IsPsionic())
	{
		AssignUnitStatsFromConfig(Unit, default.DeltaStrikePsionic);
	}

	// Advent
	if(Unit.IsADVENT())
	{	
		AssignUnitStatsFromConfig(Unit, default.DeltaStrikeAdvent);
	}

	// Aliens
	if(Unit.IsAlien())
	{
		//BERSERKERS/FACELESS
		if(Unit.IsMeleeOnly())
		{
			AssignUnitStatsFromConfig(Unit, default.DeltaStrikeAlienMelee);
			return;
		}

		AssignUnitStatsFromConfig(Unit, default.DeltaStrikeAlien);
	}
}

static function UpdateArmorTemplates()
{
	local X2ItemTemplateManager			ArmorTemplateManager;
    local X2ArmorTemplate				Template;
    local array<X2DataTemplate>			DataTemplates;
    local X2DataTemplate				DataTemplate, DiffTemplate;

	if (default.LOG)
		`Log("SWDS: Starting Delta Strike armor changes");

    ArmorTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    foreach ArmorTemplateManager.IterateTemplates(DataTemplate, None)
    {
        ArmorTemplateManager.FindDataTemplateAllDifficulties(DataTemplate.DataName, DataTemplates);

        foreach DataTemplates(DiffTemplate)
        {
            if(X2ItemTemplate(DiffTemplate).ItemCat != 'armor')
				continue;
			
			Template = X2ArmorTemplate(DiffTemplate);			
			DeltaStrikeAssignArmorStats(Template);				
		}	
	}	
}

static function DeltaStrikeAssignArmorStats(X2ArmorTemplate Template)
{
	local int						Index;
	local name						Ability;
	local X2AbilityTemplate			AbilityTemplate;
	local X2AbilityTemplateManager	AbilityTemplateManager;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	if (Template.Name == '')
		return;

	if (default.log)
		`Log("SWDS: Starting " $ Template.Name);

	if (Template.Name == 'KevlarArmor' || Template.Name == 'KevlarArmor_Diff_0' || Template.Name == 'KevlarArmor_Diff_1' || Template.Name == 'KevlarArmor_Diff_2' || Template.Name == 'KevlarArmor_Diff_3' || Template.Name == 'KevlarArmor_Diff_4' || 
		Template.Name == 'ReaperArmor' || Template.Name == 'ReaperArmor_Diff_0' || Template.Name == 'ReaperArmor_Diff_1' || Template.Name == 'ReaperArmor_Diff_2' || Template.Name == 'ReaperArmor_Diff_3' || Template.Name == 'ReaperArmor_Diff_4' || 
		Template.Name == 'SkirmisherArmor' || Template.Name == 'SkirmisherArmor_Diff_1' || Template.Name == 'SkirmisherArmor_Diff_2' || Template.Name == 'SkirmisherArmor_Diff_3' || Template.Name == 'SkirmisherArmor_Diff_4' || 
		Template.Name == 'TemplarArmor' || Template.Name == 'TemplarArmor_Diff_0' || Template.Name == 'TemplarArmor_Diff_1' || Template.Name == 'TemplarArmor_Diff_2' || Template.Name == 'TemplarArmor_Diff_3' || Template.Name == 'TemplarArmor_Diff_4')
	{	
		Index = Template.Abilities.Find('MediumKevlarArmorStats');
		if (Index == INDEX_NONE)
		{
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('MediumKevlarArmorStats');
			if (AbilityTemplate == none)
				Template.Abilities.AddItem('SWDS_MediumKevlarStatsBonus');
			else
				Template.Abilities.AddItem('MediumKevlarArmorStats');
		}
	}

	if (Template.Name == 'KevlarArmor_DLC_Day0')
	{
		if (default.LightResistanceKevlar)
		{
			Index = Template.Abilities.Find('LightKevlarArmorStats');
			if (Index == INDEX_NONE)
			{
				Template.ArmorClass = 'light';
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('LightKevlarArmorStats');
				if (AbilityTemplate == none)
					Template.Abilities.AddItem('SWDS_LightKevlarStatsBonus');
				else
					Template.Abilities.AddItem('LightKevlarArmorStats');
			}

			Template.Abilities.RemoveItem('MediumKevlarArmorStats');
		}
		else
		{
			Index = Template.Abilities.Find('MediumKevlarArmorStats');
			if (Index == INDEX_NONE)
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('MediumKevlarArmorStats');
				if (AbilityTemplate == none)
					Template.Abilities.AddItem('SWDS_MediumKevlarStatsBonus');
				else
					Template.Abilities.AddItem('MediumKevlarArmorStats');
			}
		}		
	}

	if (Template.Name == 'SparkArmor' || Template.Name == 'SparkArmor_Diff_0' || Template.Name == 'SparkArmor_Diff_1' || Template.Name == 'SparkArmor_Diff_2' || Template.Name == 'SparkArmor_Diff_3' || Template.Name == 'SparkArmor_Diff_4')
	{	
		Index = Template.Abilities.Find('SPARKArmorStats');
		if (Index == INDEX_NONE)
		{
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('SPARKArmorStats');
			if (AbilityTemplate == none)
				Template.Abilities.AddItem('SWDS_SPARKArmorStatsBonus');
			else
				Template.Abilities.AddItem('SPARKArmorStats');
		}
	}

	Index = default.ArmorBonuses.Find('ArmorName', Template.Name);
	if (Index != INDEX_NONE)
	{
		foreach default.ArmorBonuses[Index].AbilitiesToRemove(Ability)
		{
			if (default.log)
				`Log("SWDS: Removing ability " $ Template.Name $ " | " $ Ability);
			Template.Abilities.RemoveItem(Ability);
		}

		if (default.log)
			`Log("SWDS: Adding ability " $ Template.Name $ " | " $ default.ArmorBonuses[Index].AbilityName);
		Template.Abilities.AddItem(default.ArmorBonuses[Index].AbilityName);
	}

	foreach Template.Abilities(Ability)
	{			
		if (Ability == '')
			continue;

		Index = default.ArmorBonuses.Find('AbilityName', Ability);
		if (Index != INDEX_NONE)
		{	
			if (default.log)
			{
				`Log("SWDS: Setting ability for " $ Template.Name $ " | " $ Ability);
				`Log("SWDS: eStat_ShieldHP | " $ default.ArmorBonuses[Index].Shield);
				`Log("SWDS: eStat_ArmorMitigation | " $ default.ArmorBonuses[Index].Armor);
				`Log("SWDS: eStat_Mobility | " $ default.ArmorBonuses[Index].Mobility);
				`Log("SWDS: eStat_Dodge | " $ default.ArmorBonuses[Index].Dodge);
			}
			PatchStat(Template, Ability, eStat_HP, 0, GetUILabel(eStat_HP));
			if (!HasIridarArmorOverhaul() || default.OverridesArmorOverhaul)
				PatchStat(Template, Ability, eStat_ShieldHP, default.ArmorBonuses[Index].Shield, GetUILabel(eStat_ShieldHP));
			else
			{
				if (default.ArmorBonuses[Index].CreateAbility)
				{
					PatchStat(Template, Ability, eStat_ShieldHP, default.ArmorBonuses[Index].ArmorOverhaulShield, GetUILabel(eStat_ShieldHP));
				}
			}
			PatchStat(Template, Ability, eStat_ArmorMitigation, default.ArmorBonuses[Index].Armor, GetUILabel(eStat_ArmorMitigation));
			PatchStat(Template, Ability, eStat_Mobility, default.ArmorBonuses[Index].Mobility, GetUILabel(eStat_Mobility));
			PatchStat(Template, Ability, eStat_Dodge, default.ArmorBonuses[Index].Dodge, GetUILabel(eStat_Dodge));
		}
	}
}
