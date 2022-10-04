require 'PluginManager'

local devToolsFileExists = pcall(require, 'DevTools')

if not devToolsFileExists then
    return {
        sectionsForTopOfDialog = PluginManager.sectionsForTopOfDialog,
    }
else 
    require 'DevTools'
    return {
        sectionsForTopOfDialog = PluginManager.sectionsForTopOfDialog,
        sectionsForBottomOfDialog = DevTools.sectionsForBottomOfDialog,
    }
end