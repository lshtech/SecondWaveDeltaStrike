class X2Ability_ThetaStrike extends X2Ability_SharedStrike config(SecondWaveThetaStrike);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local int	i;

	for(i = 0; i < class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses.Length; i++)
	{
		if (class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses[i].CreateAbility)
		{
			if (class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.LOG)
				`Log("SWTS: Creating ability " $ class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses[i].AbilityName);
			Templates.AddItem(CreateArmorStats(class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses[i].AbilityName, 
				class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses[i].Shield, 
				class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses[i].Armor, 
				class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses[i].Dodge, 
				class'X2DownloadableContentInfo_SecondWaveThetaStrike'.default.ArmorBonuses[i].Mobility));
		}	
	}
	
	return Templates;
}
