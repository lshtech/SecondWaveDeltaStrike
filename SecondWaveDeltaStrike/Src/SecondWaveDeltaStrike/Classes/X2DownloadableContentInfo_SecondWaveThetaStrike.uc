class X2DownloadableContentInfo_SecondWaveThetaStrike extends X2DownloadableContentInfo_SecondWave config(SecondWaveThetaStrike);

	var config array<UnitStatBonuses> 	ThetaStrikeBonuses;
	var config UnitStatBonuses			ThetaStrikeRobotic;
	var config UnitStatBonuses			ThetaStrikePsionic;
	var config UnitStatBonuses			ThetaStrikeAdvent;
	var config UnitStatBonuses			ThetaStrikeAlien;
	var config UnitStatBonuses			ThetaStrikeAlienMelee;
	var config UnitStatBonuses			ThetaStrikeRuler;
	var config UnitStatBonuses			ThetaStrikeChosen;

var config array<ArmorBonus> ArmorBonuses;

static event OnPostTemplatesCreated()
{}

static function ThetaStrikeAssignUnitStats(XComGameState_unit Unit)
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
	foreach default.ThetaStrikeBonuses(UnitBonus)
	{
		if (Unit.GetMyTemplateName() == UnitBonus.UnitName)
		{
			AssignUnitStatsFromConfig(Unit, UnitBonus);
			return;
		}
	}

	// Check by group name
	foreach default.ThetaStrikeBonuses(UnitBonus)
	{
		if (Unit.GetMyTemplateGroupName() == UnitBonus.GroupName)
		{
			AssignUnitStatsFromConfig(Unit, UnitBonus);
			return;
		}
	}

	// Alien Ruler
	if(Unit.GetMyTemplateName() == 'ViperKing' || Unit.GetMyTemplateName() == 'BerserkerQueen' || Unit.GetMyTemplateName() == 'ArchonKing'){
		AssignUnitStatsFromConfig(Unit, default.ThetaStrikeRuler);
		return;
	}

	// Chosen
	if(Unit.IsChosen()){
		AssignUnitStatsFromConfig(Unit, default.ThetaStrikeChosen);		
		return;
	}

	// Robotic
	if(Unit.IsRobotic())
	{
		AssignUnitStatsFromConfig(Unit, default.ThetaStrikeRobotic);
		return;
	}

	// Psionic
	if(Unit.IsPsionic())
	{
		AssignUnitStatsFromConfig(Unit, default.ThetaStrikePsionic);
	}

	// Advent
	if(Unit.IsADVENT())
	{	
		AssignUnitStatsFromConfig(Unit, default.ThetaStrikeAdvent);
	}

	// Aliens
	if(Unit.IsAlien())
	{
		//BERSERKERS/FACELESS
		if(Unit.IsMeleeOnly())
		{
			AssignUnitStatsFromConfig(Unit, default.ThetaStrikeAlienMelee);
			return;
		}

		AssignUnitStatsFromConfig(Unit, default.ThetaStrikeAlien);
	}
}

static function UpdateArmorTemplates()
{
	local X2ItemTemplateManager			ArmorTemplateManager;
    local X2ArmorTemplate				Template;
    local array<X2DataTemplate>			DataTemplates;
    local X2DataTemplate				DataTemplate, DiffTemplate;

	if (default.LOG)
		`Log("SWDS: Starting Theta Strike armor changes");

    ArmorTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    foreach ArmorTemplateManager.IterateTemplates(DataTemplate, None)
    {
        ArmorTemplateManager.FindDataTemplateAllDifficulties(DataTemplate.DataName, DataTemplates);

        foreach DataTemplates(DiffTemplate)
        {
            if(X2ItemTemplate(DiffTemplate).ItemCat != 'armor')
				continue;
			
			Template = X2ArmorTemplate(DiffTemplate);
			ThetaStrikeAssignArmorStats(Template);
		}	
    }	
}

static function ThetaStrikeAssignArmorStats(X2ArmorTemplate Template)
{
	local int						Index;
	local name						Ability;
	local X2AbilityTemplate			AbilityTemplate;
	local X2AbilityTemplateManager	AbilityTemplateManager;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	if (Template.Name == '')
		return;

	if (default.log)
		`Log("SWTS: Starting " $ Template.Name);

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
				Template.Abilities.AddItem('SWTS_MediumKevlarStatsBonus');
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
					Template.Abilities.AddItem('SWTS_LightKevlarStatsBonus');
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
					Template.Abilities.AddItem('SWTS_MediumKevlarStatsBonus');
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
				Template.Abilities.AddItem('SWTS_SPARKArmorStatsBonus');
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
				`Log("SWTS: Removing ability " $ Template.Name $ " | " $ Ability);
			Template.Abilities.RemoveItem(Ability);
		}

		if (default.log)
			`Log("SWTS: Adding ability " $ Template.Name $ " | " $ default.ArmorBonuses[Index].AbilityName);
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
				`Log("SWTS: Setting ability for " $ Template.Name $ " | " $ Ability);
				`Log("SWTS: eStat_ShieldHP | " $ default.ArmorBonuses[Index].Shield);
				`Log("SWTS: eStat_ArmorMitigation | " $ default.ArmorBonuses[Index].Armor);
				`Log("SWTS: eStat_Mobility | " $ default.ArmorBonuses[Index].Mobility);
				`Log("SWTS: eStat_Dodge | " $ default.ArmorBonuses[Index].Dodge);
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