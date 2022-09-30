return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 2.0,
	LrToolkitIdentifier = 'com.27shutterclicks.lr.develophistorytimestamps',

	LrPluginName = "Develop History Timestamps",
	LrPluginInfoUrl = "https://www.27shutterclicks.com",
    
    LrInitPlugin = 'PluginInit.lua',
	
	LrLibraryMenuItems = {
        {
            title = 'View Develop &History Timestamps',
            file = 'Develop History Timestamps.lua',
            enabledWhen = 'photosSelected',
        },
        {
            title = 'View Last &Develop Time',
            file = 'View Last Develop Time.lua',
            enabledWhen = 'photosSelected',
        },
        {
            title = '&View Edit Time',
            file = 'View Edit Time.lua',
            enabledWhen = 'photosSelected',
        },
	},
    
    LrExportMenuItems = {
        {
            title = 'View Develop &History Timestamps',
            file = 'Develop History Timestamps.lua',
            enabledWhen = 'photosSelected',
        },
        {
            title = 'View Last &Develop Time',
            file = 'View Last Develop Time.lua',
            enabledWhen = 'photosSelected',
        },
        {
            title = '&View Edit Time',
            file = 'View Edit Time.lua',
            enabledWhen = 'photosSelected',
        },
    },
	
	-- Add the entry for the Plug-in Manager Dialog
	LrPluginInfoProvider = 'PluginInfoProvider.lua',
    
    LrEnablePlugin = 'PluginEnable.lua',
	
	VERSION = { major=0, minor=9, revision=5, },

}
