-- this file is loaded and executed when the plug-in is loaded or reloaded in the Plugin Manager

local info = require 'Info'

local prefs = import 'LrPrefs'.prefsForPlugin() 

local dialog = import 'LrDialogs'
local inspect = require 'Inspect'

_G.pluginURL = "https://github.com/27shutterclicks/lrdevhisttimestamps/"
_G.pluginBuyPrintsURL = "https://shop.27shutterclicks.com"
_G.pluginIssuesURL = "https://github.com/27shutterclicks/lrdevhisttimestamps/issues"
_G.pluginUpdateReleaseURL = "https://api.github.com/repos/27shutterclicks/lrdevhisttimestamps/releases/latest"
_G.pluginVersion = info.VERSION.major .. '.' .. info.VERSION.minor .. '.' .. info.VERSION.revision
_G.pluginTwitterURL = "https://www.twitter.com/27shutterclicks"
_G.updateCheckText = "Check for plugin update"


-- set default values for plugin options
_G.prefKeys = {
    
    showTimestamps = true,
    showDualTimestamps = false,
    showTimestampsLeft = false,
    showStepNumbers = true,
    showStepNumbersRight = false,
    showPhotoID = false,
    checkForUpdate = true,
    updateLastCheck = "Never",
    updateAvailable = false,
}

-- initialize plugin options with default values
for prefKey,value in pairs(prefKeys) do
    if prefs[prefKey] == nil then
        prefs[prefKey] = value
    end
end