return {

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 2.0,
	LrToolkitIdentifier = 'com.27shutterclicks.develophistorytimestamps',

	LrPluginName = "Develop History Timestamps",
	LrPluginInfoUrl = "http://www.27shutterclicks.com",
	
	LrLibraryMenuItems = {
        {
            title = 'View Develop &History Timestamps',
            file = 'Develop History Timestamps.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'View Last &Develop Time',
            file = 'View Last Develop Time.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = '&View Edit Time',
            file = 'View Edit Time.lua',
            enabledWhen = 'photosAvailable',
        },
	},
    
    LrExportMenuItems = {
        {
            title = 'View Develop &History Timestamps',
            file = 'Develop History Timestamps.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = 'View Last &Develop Time',
            file = 'View Last Develop Time.lua',
            enabledWhen = 'photosAvailable',
        },
        {
            title = '&View Edit Time',
            file = 'View Edit Time.lua',
            enabledWhen = 'photosAvailable',
        },
    },
	
	-- Add the entry for the Plug-in Manager Dialog
	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	
	VERSION = { major=0, minor=8, revision=0, },

}
