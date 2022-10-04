-- this file is loaded and executed when the plug-in is loaded or reloaded in the Plugin Manager

local info = require 'Info'

_G.pluginURL = "https://github.com/27shutterclicks/lrdevhisttimestamps/"
_G.pluginIssuesURL = "https://github.com/27shutterclicks/lrdevhisttimestamps/issues"
_G.pluginUpdateReleaseURL = "https://api.github.com/repos/27shutterclicks/lrdevhisttimestamps/releases/latest"
_G.pluginVersion = info.VERSION.major .. '.' .. info.VERSION.minor .. '.' .. info.VERSION.revision
-- check for update on plugin load

--PluginManager.checkUpdateAvailable()
