return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 2.0,
	LrToolkitIdentifier = 'com.lightroom.sdk.history.develophistorytimestamps',

	LrPluginName = LOC "$$$/DevelopHistory/PluginName=Develop History Timestamps",
	LrPluginInfoUrl = "http://www.27shutterclicks.com",
	
	LrLibraryMenuItems = {
		title = 'Develop History Timestamps',
		file = 'Develop History Timestamps.lua',
		enabledWhen = 'photosAvailable',
	},
    
    LrExportMenuItems = {
        {
            title = 'Develop &History Timestamps',
            file = 'Develop History Timestamps.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'Develop &Last Edited Time',
            file = 'Develop Last Edited.lua',
            enabledWhen = 'photosAvailable',
        },
    },
	
	-- Add the entry for the Plug-in Manager Dialog
--	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	
	VERSION = { major=0, minor=5, revision=0, },

}
