local dialog = import 'LrDialogs'
local LrHttp = import "LrHttp"
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'
local paths = import 'LrPathUtils'
local fileUtils = import 'LrFileUtils'
local LrView = import 'LrView'
local LrBinding = import "LrBinding"
--local LrFunctionContext = import 'LrFunctionContext'

local inspect = require 'inspect'

local json = require 'JSON'
local info = require 'Info'

require "Utility"

PluginManager = {}

local logger = LrLogger('com.27shutterclicks.lr.develophistorytimestamps')
logger:enable( "print" ) -- Pass either a string or a table of actions.

local function log( message, desc )
	if desc ~= nil then
        logger:info(desc)
    end
    logger:info( message )
end

function PluginManager.sectionsForTopOfDialog( viewFactory , propertyTable )
    
--    local updateAvailable = PluginManager.checkUpdateAvailable()
    
    -- create shortcut for LrView
    local bind = LrView.bind

    -- set initial plugin update text
    propertyTable.updateAvailableText = "Checking for plugin updates..."
    propertyTable.updateButtonText = "Check Update"
    
    -- begin AsyncTask
    LrTasks.startAsyncTask( function()
            
--            _G.updateAvailable = nil
            
            PluginManager.checkUpdateAvailable()
            
            local timeWaited = waitForGlobal('updateCheck')
            
            propertyTable.updateAvailableText = _G.updateAvailableText
             
            if _G.updateAvailable then
                propertyTable.updateButtonText = "View  Update"
            end
            
        end
    )

    -- return table to Lightroom Plugin Manager for sections for top of dialog
    return {
            -- Section for the top of the dialog.
            {
                title = "Plugin Info",
                viewFactory:row {
                    spacing = viewFactory:control_spacing(),
                    viewFactory:static_text {
                        title = "Click the button to learn more about this plugin and its features on GitHub  >>",
                        fill_horizontal = 1,
                    }, -- text

                    viewFactory:push_button {
                        width = 150,
                        title = "Plugin Info",
                        enabled = true,
                        action = function()
                            LrHttp.openUrlInBrowser(_G.pluginURL)
                        end,
                    }, -- button
                }, -- row
                viewFactory:row {
                    spacing = viewFactory:control_spacing(),

                    viewFactory:static_text {
                        title = "If you come across any errors, please report an issue on GitHub  >>",
                        fill_horizontal = 1,
                    }, -- text

                    viewFactory:push_button {
                        width = 150,
                        title = "Report Issue",
                        enabled = true,
                        action = function()
                            LrHttp.openUrlInBrowser(_G.pluginIssuesURL)
                        end,
                    }, -- button
                }, -- row
            }, -- section
			{
				title = "Plugin Help",
                viewFactory:row {
                        spacing = viewFactory:control_spacing(),
                        bind_to_object = propertyTable,
                        viewFactory:static_text {
                            title = bind 'updateAvailableText',
                            fill_horizontal = 1,
                        }, -- text

                        viewFactory:push_button {
                            width = 150,
                            title = bind 'updateButtonText',
                            enabled = true,
                            action = function()
                                PluginManager.checkUpdate()
                            end
                        }, -- button
                }, -- row  
                viewFactory:row {
                        spacing = viewFactory:control_spacing(),

                        viewFactory:static_text {
                            title = "Dev Assist",
                            fill_horizontal = 1,
                        }, -- text

                        viewFactory:push_button {
                            width = 150,
                            title = "Dev Button",
                            enabled = true,
                            action = function()
                                showDevDialog(_PLUGIN.path,2)
                            end
                        }, -- button
                }, -- row
                viewFactory:row {
                        spacing = viewFactory:control_spacing(),

                        viewFactory:static_text {
                            title = "Copy plugin from dev to temp folder",
                            fill_horizontal = 1,
                        }, -- text

                        viewFactory:push_button {
                            width = 150,
                            title = "Update Dev Plugin",
                            enabled = true,
                            action = function()
                                        
                                local devPluginPath = "E:\\Pictures\\Lightroom Catalog\\Lightroom Plugins\\Develop History Timestamps\\DevelopHistoryTimestamps.lrplugin"
                        
                                local tempPluginPath = "C:\\temp\\DevelopHistoryTimestamps.lrplugin"
                                
                                -- delete temp plugin
                                local deleteTempPlugin = fileUtils.delete(tempPluginPath)
                        
                                if deleteTempPlugin then
                                    dialog.showBezel("Temp plugin deleted")
                                else 
                                    dialog.showBezel("Temp plugin deletion failed")
                                end
                        
                                -- copy dev plugin
                                local copyDevPlugin = fileUtils.copy(devPluginPath, tempPluginPath)
                        
                                if copyDevPlugin then
                                    dialog.showBezel("Dev plugin copied to temp plugin folder",2)
                                else 
                                    dialog.showError("Dev plugin copy operation failed")
                                end
                        
                            end
                        }, -- button
                }, -- row
				viewFactory:row {
					spacing = viewFactory:control_spacing(),

					viewFactory:static_text {
						title = "Reset dialogs with 'Do not show' option",
						fill_horizontal = 1,
					}, -- text

					viewFactory:push_button {
						width = 150,
						title = "Reset Do Not Show Dialogs",
						enabled = true,
						action = function()
							dialog.resetDoNotShowFlag()
                            dialog.message('The "Do not show" dialogs have been reset')
						end,
					}, -- button
				}, -- row
            } -- section
        
        } --return
end

function PluginManager.checkUpdateAvailable()
    
    log("in check update...")
    local checkURL = _G.pluginUpdateReleaseURL
    local headers = {
            { field = 'Accept',  value = "application/json" }
        }
    
    _G.updateAvailable = nil
    _G.updateCheck = nil
    
     -- begin AsyncTask
    LrTasks.startAsyncTask( function()

            local response, data = LrHttp.get( checkURL, headers, 10 )

            local updateCheckTime = os.date("%B %d, %Y %I\:%M\:%S %p")
            response = json:decode(response)

            local pluginUpdateVersion = response.tag_name
            
            -- remove "v" from tag name (first character of string)
            pluginUpdateVersion = pluginUpdateVersion:sub(2)

--            local pluginVersion = info.VERSION.major .. '.' .. info.VERSION.minor .. '.' .. info.VERSION.revision
            local pluginVersion = _G.pluginVersion
            
            log("plugin version is:" .. pluginVersion)
--            local pluginVersion= "0.9.5"

            -- compare local version number with update version number
            if pluginUpdateVersion > pluginVersion then
                _G.updateAvailable = true
                _G.updateVersion = response.tag_name
                _G.updateDate = os.date("%B %d, %Y",fromISODate(response.published_at))
                _G.updateAvailableText = "Update available: " .. updateVersion .. "  Released: " .. updateDate
                _G.updateDetails = response
            else 
                _G.updateAvailableText = "Plugin is up to date. Last checked: " .. updateCheckTime
                _G.updateAvailable = false
            end
            
            -- signal completion of check
            _G.updateCheck = true
        end
    )
        
end -- checkUpdateAvailable()

function PluginManager.checkUpdate ()

    local checkURL = _G.pluginUpdateReleaseURL
    local headers = {
            { field = 'Accept',  value = "application/json" }
        }

    -- save the name of the plugin folder to a variable
    local pluginFolderName = paths.leafName(_PLUGIN.path)
    
     -- begin AsyncTask
    LrTasks.startAsyncTask( function()

            PluginManager.checkUpdateAvailable()
        
            local updateTimeWaited = waitForGlobal('updateCheck')
            
            dialog.showBezel("Checking for update...")

            LrTasks.sleep(2)
            
            -- if no update, display message
            if not _G.updateAvailable then
                return nil, dialog.message("You are using the latest version of the plugin", "Keep on inspecting timestamps!")
            end
            
            local response = _G.updateDetails
                        
            local pluginVersion = _G.pluginVersion
            local currentVersion = "v" .. pluginVersion
            
            local releaseNotes = "(Currently installed version is " .. currentVersion .. ')\n\n' .. response.body

            -- check if tar supported

            local checkTar = LrTasks.execute('cmd /c "WHERE tar"')
--            local checkTar = 1
            local buttonText = ""

            if checkTar ~= 0 then
                -- tar not supported, plugin may need to be updated manually
                buttonText = "Open update folder"
                releaseNotes = releaseNotes .. "\n\nNote: The plugin is unable to install the update automatically. It will need to be installed manually."
            else
                buttonText = "Update Now"
            end

            local confirmUpdate = dialog.confirm("Version " .. response.tag_name .. " is available." ,releaseNotes, buttonText)

            -- CHECK IF UPDATE SHOULD BE INSTALLED AUTOMATICALLY
            if (confirmUpdate == "ok" and checkTar == 0) then -- install update
                
                -- download the update file and get the filename
                local downloadFile = PluginManager.downloadUpdate(response.zipball_url)
                local downloadFileFolder = paths.parent(downloadFile)
                
                dialog.showBezel("Downloading Update...")

                -- COMMAND EXAMPLE:
--                 tar --strip-components=1 -xf 27shutterclicks-lrdevhisttimestamps-v0.9.5-0-g82626d4.zip
                
                -- build the command for extraction
                local extractCommand = "tar --strip-components=1 -xf " .. downloadFile .. " --directory \"" .. downloadFileFolder .. '"'

                if WIN_ENV then
                    extractCommand = 'cmd /c "' .. extractCommand .. '"'
                end

                log("extract command is: " .. extractCommand)
                local pluginBackupFolder = paths.child(paths.parent(_PLUGIN.path), pluginFolderName .. "-" .. currentVersion .. "-backup")
                
                log("plugin backup folder is: " .. pluginBackupFolder)
                -- rename the current version plugin folder
                local move, message = fileUtils.move(_PLUGIN.path,pluginBackupFolder)

                --[[local pluginsFolder = paths.parent(_PLUGIN.path)
                    
                -- move the extracted update folder to the plugins folder
                local moveUpdateFolder = fileUtils.move()
                
                if moveUpdateFolder then
                    dialog.showBezel("Update extracted")
                else 
                    return nil, dialog.showError("There was an error installing the plugin update.")
                end]]
                
                -- extract download archive
                local extractStatus = LrTasks.execute(extractCommand)
                dialog.showBezel("Extracting update...")

                if extractStatus == 0 then
                    dialog.showBezel("Update extracted")
                else 
                    log("extractStatus is: " .. extractStatus)
                    return nil, dialog.showError("There was an error extracting the plugin update.")
                end
                    
                -- CONFIRM DELETE OR BACKUP
                local confirmBackup = dialog.confirm("Plugin updated!", "\nWould you like to delete the old plugin version or keep a backup?\n","Delete old version", "Keep a backup")

                if confirmBackup == "ok" then -- delete old version
                    
                    log("plugin backup folder in delete is: " .. pluginBackupFolder)

                    local deleteFolder, message = fileUtils.delete(pluginBackupFolder)
                    
                    if deleteFolder then
                        dialog.showBezel("Old plugin version deleted")
                    else 
                        return nil, dialog.showError("Unable to delete old version folder", message)
                    end
                else -- keep a backup
                    dialog.showBezel("Plugin backed up in Plugins folder")
                end
                
                -- delete downloaded file
                local deleteDownload, message = fileUtils.delete(downloadFile)
                
                if not deleteDownload then
                    dialog.showError("The update archive could not be deleted")
                end
                    
                dialog.message("Plugin updated", 'Please click the "Reload Plug-in" button in the Plugin Manager window to start using the new version.')

            elseif  (confirmUpdate == "ok" and checkTar ~= 0) then -- no tar support

                local downloadFile = PluginManager.downloadUpdate(response.zipball_url)
                dialog.showBezel("Downloading update...")
                
                LrTasks.sleep(2)

                -- setup OS-specific variables and commands
                local windowName = ""
                local windowCommand = ""

                if WIN_ENV then
                    windowName = "Windows Explorer"
                    windowCommand = 'cmd /c "explorer.exe /select, "' .. downloadFile .. '""'
                else
                    windowName = "Finder"
                    windowCommand = 'open -R "' .. downloadFile .. '"'
                end -- if WIN_ENV
                
                -- reveal downloaded update file in a window
                local revealDownload = LrTasks.execute(windowCommand)

                dialog.showBezel("Plugin update archive opened in ".. windowName .. " window", 5)

            else -- user clicked cancel on confirmUpdate
                dialog.showBezel("Plugin update cancelled")
            end -- if confirmUpdate
            
    end --startAsyncTask function
    ) -- startAsyncTask

end -- checkUpdate()

function PluginManager.downloadUpdate ( url )

--        local downloadPath = paths.getStandardFilePath("temp")
    
        -- download update to plugin parent folder
        local downloadPath = paths.parent(_PLUGIN.path)

        -- also possible url: https://github.com/27shutterclicks/lrdevhisttimestamps/archive/v0.9.5/lrdevhisttimestamps-v0.9.5

        -- get the zipball
        local download, code = LrHttp.get(url, headers)

        local status = code["status"] --returned by get request
        code.status = nil

        local filename = ""
        local folderName = ""

        for key,value in pairs(code) do
            if value.field == 'content-disposition' then

                filename = split(value.value,"=")[2]
                folderName = filename:match("(.+)%..+$")
                log("filename equals: ".. filename)
                log("folder is: ".. folderName)
            end -- if
        end -- for

        local saveFileName = paths.child(downloadPath,filename)
        local saveFile = assert(io.open(saveFileName, 'wb'))
        saveFile:write(download)
        saveFile:close()

        return saveFileName
end
