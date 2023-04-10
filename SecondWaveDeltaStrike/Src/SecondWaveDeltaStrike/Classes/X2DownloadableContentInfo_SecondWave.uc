class X2DownloadableContentInfo_SecondWave extends X2DownloadableContentInfo config(SecondWaveDeltaStrike);

struct Requirement
{
	var name 					UnitName;
	var name					GroupName;
	var name					AbilityName;	
};

struct UnitStatBonus
{
	var ECharStatType	        Stat;
	var float			        Bonus;
	var int				        Minimum;
};

struct UnitStatBonuses
{
	var name 					UnitName;
	var name					GroupName;
	var array<UnitStatBonus>	Bonuses;
	var array<name>				Abilities;
	var bool					ArmorlessDodge;
	var array<Requirement>		Exemptions;
};

struct ArmorBonus
{
	var Name					ArmorName;
	var Name					AbilityName;
	var array<Name>				AbilitiesToRemove;
	var int						Armor;
	var int 					Shield;
	var int 					Mobility;
	var int 					Dodge;
	var bool					CreateAbility;
	var int						ArmorOverhaulShield;	
};

var localized string 			mstrShieldLabel;
var localized string			strThetaStrike_Description;
var localized string			strThetaStrike_Tooltip;
var localized string			strDeltaStrike_Description;
var localized string			strDeltaStrike_Tooltip;

var config bool                 LOG;
var config bool                 OverridesArmorOverhaul;
var config string				ArmorMode;
var config bool					LightResistanceKevlar;

static event OnPostTemplatesCreated()
{
	local array<Object>			UIShellDifficultyArray;
	local Object				ArrayObject;
	local UIShellDifficulty		UIShellDifficulty;
    local SecondWaveOption		DeltaStrike, ThetaStrike;

	if (default.LOG)
		`Log("SWDTS: Adding Second Wave options");
	
	DeltaStrike.ID = 'DeltaStrike';
	DeltaStrike.DifficultyValue = 0;

	ThetaStrike.ID = 'ThetaStrike';
	ThetaStrike.DifficultyValue = 0;

	UIShellDifficultyArray = class'XComEngine'.static.GetClassDefaultObjects(class'UIShellDifficulty');
	foreach UIShellDifficultyArray(ArrayObject)
	{
		UIShellDifficulty = UIShellDifficulty(ArrayObject);
		
		UIShellDifficulty.SecondWaveOptions.AddItem(ThetaStrike);
		UIShellDifficulty.SecondWaveDescriptions.AddItem(default.strThetaStrike_Description);
		UIShellDifficulty.SecondWaveToolTips.AddItem(default.strThetaStrike_Tooltip);

		UIShellDifficulty.SecondWaveOptions.AddItem(DeltaStrike);
		UIShellDifficulty.SecondWaveDescriptions.AddItem(default.strDeltaStrike_Description);
		UIShellDifficulty.SecondWaveToolTips.AddItem(default.strDeltaStrike_Tooltip);

	}

	UpdateCharacterTemplates();
	if (default.LOG)
		`Log("SWDTS: Armor Mode " $ default.ArmorMode);

	if (default.ArmorMode == "Delta" || default.ArmorMode == "delta")
		class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.static.UpdateArmorTemplates();
	else if (default.ArmorMode == "Theta" || default.ArmorMode == "theta")
		class'X2DownloadableContentInfo_SecondWaveThetaStrike'.static.UpdateArmorTemplates();
}

static function bool HasIridarArmorOverhaul()
{
    local XComOnlineEventMgr			EventManager;
	local int							Index;

    EventManager = `ONLINEEVENTMGR;
	for(Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--)
	{
		if(EventManager.GetDLCNames(Index)=='WOTCDefensiveItemOverhaul2')
		{
			return true;
		}
	}

    return false;
}

static function UpdateCharacterTemplates()
{
	local X2CharacterTemplateManager	CharacterTemplateManager;
    local X2CharacterTemplate			CharTemplate;
    local array<X2DataTemplate>			DataTemplates;
    local X2DataTemplate				Template, DiffTemplate;

	CharacterTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

    foreach CharacterTemplateManager.IterateTemplates(Template, None)
    {
        CharacterTemplateManager.FindDataTemplateAllDifficulties(Template.DataName, DataTemplates);
        foreach DataTemplates(DiffTemplate)
        {
            CharTemplate = X2CharacterTemplate(DiffTemplate);

            if (CharTemplate.bIsSoldier || CharTemplate.CharacterGroupName == 'TheLost')
            {
				continue;
			}
		
			class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.static.DeltaStrikeAssignUnitAbilities(CharTemplate);

			CharTemplate.OnStatAssignmentCompleteFn = AssignUnitStats;			
		}	
	}	
}

static function AssignUnitStats(XComGameState_unit Unit)
{
	if (`SecondWaveEnabled('DeltaStrike'))
	{
		if (default.LOG)
			`Log("SWDS: Delta Strike is enabled.");
		class'X2DownloadableContentInfo_SecondWaveDeltaStrike'.static.DeltaStrikeAssignUnitStats(Unit);
	}
	else if (`SecondWaveEnabled('ThetaStrike'))
	{
		if (default.LOG)
			`Log("SWTS: Theta Strike is enabled.");
		class'X2DownloadableContentInfo_SecondWaveThetaStrike'.static.ThetaStrikeAssignUnitStats(Unit);
	}
}

static function AssignUnitStatsFromConfig(XComGameState_unit Unit, UnitStatBonuses Bonuses)
{
	local float 					BetaStrikeMod;
	local float 					BetaStrikeBonus;
	local UnitStatBonus 			Bonus;
	local bool						UnitHasArmor;
	local name						Ability, abilityName;
	local X2CharacterTemplate		CharacterTemplate;
	local int						BonusValue;
	local bool						HasAbility;
	local Requirement				Exemption;

	BetaStrikeMod =	class'X2StrategyGameRulesetDataStructures'.default.SecondWaveBetaStrikeHealthMod;
	BetaStrikeBonus = Unit.GetBaseStat(eStat_HP) * (BetaStrikeMod / 2);
	UnitHasArmor = HasArmor(Unit);

	if (default.LOG)	
		`Log("SWDTS: Beginning modification of " $ Unit.GetMyTemplateName());

	foreach Bonuses.Exemptions(Exemption)
	{
		if (Exemption.UnitName != '' && Unit.GetMyTemplateName() == Exemption.UnitName)
			return;
		if (Exemption.GroupName != '' && Unit.GetMyTemplateGroupName() == Exemption.GroupName)
			return;
		if (Exemption.AbilityName != '' && Unit.HasAbilityFromAnySource(Exemption.AbilityName))
			return;
	}

	foreach Bonuses.Bonuses(Bonus)
	{
		if (Bonuses.ArmorlessDodge && Bonus.Stat == eStat_ArmorMitigation)
		{
			if (UnitHasArmor)
			{
				BonusValue = int(BetaStrikeBonus * Bonus.Bonus);
				`Log("SWDTS: " $ Bonus.Stat $ " | " $ BonusValue $ " | " $ BetaStrikeBonus);
				if(BonusValue < Bonus.Minimum)
					BonusValue = Bonus.Minimum;
				Unit.SetBaseMaxStat(Bonus.Stat, Unit.GetBaseStat(Bonus.Stat) + BonusValue);
			}
		}
		else if (Bonuses.ArmorlessDodge && Bonus.Stat == eStat_Dodge)
		{
			if (!UnitHasArmor)
				Unit.SetBaseMaxStat(eStat_Dodge, Unit.GetBaseStat(Bonus.Stat) + int(Bonus.Bonus));
		}
		else
		{
			BonusValue = int(BetaStrikeBonus * Bonus.Bonus);
			`Log("SWDTS: " $ Bonus.Stat $ " | " $ BonusValue $ " | " $ BetaStrikeBonus);
			if(BonusValue < Bonus.Minimum)
				BonusValue = Bonus.Minimum;
			Unit.SetBaseMaxStat(Bonus.Stat, Unit.GetBaseStat(Bonus.Stat) + BonusValue);
		}
		if (default.LOG)
			`Log("SWDTS: Increasing " $ Bonus.Stat $ " for " $ Unit.GetMyTemplateName() $ " to " $ Unit.GetBaseStat(Bonus.Stat));
	}

	Unit.bGotFreeFireAction = true;
}

static function bool HasArmor(XComGameState_Unit Unit){

	if (Unit.GetBaseStat(eStat_ArmorMitigation) > 0)
		return true;
	else 
		return false;
}

static function string GetUILabel(ECharStatType StatType)
{
	switch (StatType)
	{
		case eStat_HP:
			return class'XLocalizedData'.default.HealthLabel;
		case eStat_ShieldHP:
			return default.mstrShieldLabel;
		case eStat_ArmorMitigation:
			return class'XLocalizedData'.default.ArmorLabel;
		case eStat_Dodge:
			return class'XLocalizedData'.default.MobilityLabel;
		case eStat_Mobility:
			return class'XLocalizedData'.default.DodgeLabel;
		default:
			return "";
	}
}

static function int GetStatValue(ECharStatType StatType, ArmorBonus Bonus)
{
	switch (StatType)
	{
		case eStat_ShieldHP:
			return Bonus.Shield;
		case eStat_ArmorMitigation:
			return Bonus.Armor;
		case eStat_Dodge:
			return Bonus.Dodge;
		case eStat_Mobility:
			return Bonus.Mobility;
		default:
			return 0;
	}
}

static function PatchStat(X2ArmorTemplate Template, Name AbilityName, ECharStatType StatType, int value, string label)
{
	local X2AbilityTemplateManager		AbilityTemplateManager;
	local X2AbilityTemplate				AbilityTemplate;
    local array<X2DataTemplate>			DifficultyVariants;
    local X2DataTemplate				DifficultyVariant;
	local X2Effect						Effect;
	local X2Effect_PersistentStatChange	StatEffect;
	local int 							i, i2;
	local StatChange					Change;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplateManager.FindDataTemplateAllDifficulties(AbilityName, DifficultyVariants);
	
	foreach DifficultyVariants(DifficultyVariant)
	{
		AbilityTemplate = X2AbilityTemplate(DifficultyVariant);
		if (AbilityTemplate != none)
		{	
			foreach AbilityTemplate.AbilityTargetEffects(Effect)
			{
				StatEffect = X2Effect_PersistentStatChange(Effect);
				if (StatEffect != none)
				{
					i = StatEffect.m_aStatChanges.Find('StatType', StatType);

					if (i == INDEX_NONE)
					{
						if (value > 0)
						{						
							Change.StatType = StatType;
							Change.StatAmount = value;
							StatEffect.m_aStatChanges.AddItem(Change);
							
							for (i2 = 0; i2  < Template.UIStatMarkups.Length; i2++)
							{
								if (Template.UIStatMarkups[I2].StatType == StatType && Template.UIStatMarkups[I2].ShouldStatDisplayFn == none)
								{
									Template.UIStatMarkups[i2].StatLabel = label;
									Template.UIStatMarkups[i2].StatModifier = value;
									return;
								}
							}

							if (StatType == eStat_ShieldHP)
							{
								for (i2 = 0; i2  < Template.UIStatMarkups.Length; i2++)
								{
									if (Template.UIStatMarkups[I2].StatType == eStat_HP)
									{
										Template.UIStatMarkups[I2].StatType = eStat_ShieldHP;
										Template.UIStatMarkups[i2].StatLabel = label;
										Template.UIStatMarkups[i2].StatModifier = value;
										return;
									}
								}
							}
							
							Template.SetUIStatMarkup(label, StatType, value);			
						}
						else
						{
							while (Template.UIStatMarkups.Find('StatType', StatType) != INDEX_NONE)
							{
								i2 = Template.UIStatMarkups.Find('StatType', StatType);
								if (i2 != INDEX_NONE)
							 		Template.UIStatMarkups.Remove(i2, 1);
							}
						}
					}
					else
					{
						if (value > 0)
						{
							StatEffect.m_aStatChanges[i].StatAmount = value;

							for (i2 = 0; i2  < Template.UIStatMarkups.Length; i2++)
							{
								if (Template.UIStatMarkups[I2].StatType == StatType && Template.UIStatMarkups[I2].ShouldStatDisplayFn == none)
								{
									Template.UIStatMarkups[i2].StatLabel = label;
									Template.UIStatMarkups[i2].StatModifier = value;
									return;
								}
							}

							if (StatType == eStat_ShieldHP)
							{
								for (i2 = 0; i2  < Template.UIStatMarkups.Length; i2++)
								{
									if (Template.UIStatMarkups[I2].StatType == eStat_HP)
									{
										Template.UIStatMarkups[I2].StatType = eStat_ShieldHP;
										Template.UIStatMarkups[i2].StatLabel = label;
										Template.UIStatMarkups[i2].StatModifier = value;
										return;
									}
								}
							}

							Template.SetUIStatMarkup(label, StatType, value);
						}
						else
						{
							StatEffect.m_aStatChanges.Remove(i, 1);
						
							while (Template.UIStatMarkups.Find('StatType', StatType) != INDEX_NONE)
							{
							i2 = Template.UIStatMarkups.Find('StatType', StatType);
							if (i2 != INDEX_NONE)
								//Template.UIStatMarkups[i2].StatModifier = value;
								Template.UIStatMarkups.Remove(i2, 1);
							}
						}
					}
				}
			}
		}
	}
}