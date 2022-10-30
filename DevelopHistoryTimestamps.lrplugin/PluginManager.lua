local dialog = import 'LrDialogs'
local LrHttp = import "LrHttp"
local LrTasks = import 'LrTasks'
local paths = import 'LrPathUtils'
local fileUtils = import 'LrFileUtils'
local LrView = import 'LrView'
local LrBinding = import "LrBinding"
local LrColor = import 'LrColor'

local prefs = import 'LrPrefs'.prefsForPlugin() 

--local LrFunctionContext = import 'LrFunctionContext'

local inspect = require 'Inspect'

local json = require 'JSON'
local info = require 'Info'

require "Utility"

PluginManager = {}

function PluginManager.sectionsForTopOfDialog( viewFactory , propertyTable )
    
--    local updateAvailable = PluginManager.checkUpdateAvailable()
    
    -- create shortcut for LrView
    local bind = LrView.bind


    -- set initial plugin update text
    propertyTable.updateLabelText = _G.updateCheckText .. prefs.updateLastCheck
    propertyTable.updateButtonText = "Check for update"
    propertyTable.updateButtonEnabled = true
--    propertyTable.checkForUpdate = prefs.checkForUpdate
    
    -- step builder examples
    local histNoStepNumberNoTimestamp = "Exposure"
    local histStepNumberNoTimestamp = "Step 5: Exposure"
    local histStepNumberRightNoTimestamp = "Exposure - Step 5"
    local histDefault = "Step 5: Exposure (10/12/22 10:45:01 AM)"
    local histDefaultNoStepNumber = "Exposure (10/12/22 10:45:01 AM)"
    local histDefaultStepNumberRight = "Exposure (10/12/22 10:45:01 AM) - Step 5"

    local histTimestampLeftStepNumberRight = "(10/12/22 10:45:01 AM) Exposure - Step 5"
    local histTimestampLeftNoStepNumber = "(10/12/22 10:45:01 AM) Exposure"
    local histTimestampLeft = "(10/12/22 10:45:01 AM) Step 5: Exposure "

    local histDualTimestamps = "Step 1: Import (10/12/22 4:45:01 AM) (10/12/22 10:45:01 AM)"
    local histDualTimestampsStepNumberRight = "Import (10/12/22 4:45:01 AM) (10/12/22 10:45:01 AM) - Step 1"
    local histDualTimestampsLeft = "(10/12/22 10:45:01 AM) (10/12/22 4:45:01 AM) Step 1: Import "
    local histDualTimestampsLeftStepNumberRight = "(10/12/22 10:45:01 AM) (10/12/22 4:45:01 AM) Import  - Step 1"
    local histDualTimestampsLeftNoStepNumber = "(10/12/22 10:45:01 AM) (10/12/22 4:45:01 AM) Import "
    local histDualTimestampsRightNoStepNumber = "Import (10/12/22 4:45:01 AM) (10/12/22 10:45:01 AM)"
         
    --[[if prefs.checkForUpdate then
        -- begin AsyncTask for update check and wait
        LrTasks.startAsyncTask( function()

                _G.updateAvailable = nil

                PluginManager.checkUpdateAvailable()

                propertyTable.updateCheckInProgress = true

                local timeWaited = waitForGlobal('updateCheckComplete')


                propertyTable.updateCheckInProgress = _G.updateCheckInProgress
                propertyTable.updateLabelText = _G.updateAvailableText

                if _G.updateAvailable then
                    propertyTable.updateButtonText = "View  Update"
                    propertyTable.synopsisText = "Update Available"
                end

            end
        )
    end -- if check for update enabled]]

    -- return table to Lightroom Plugin Manager for sections for top of dialog
    return {
            
            { -- Section for PLUGIN ABOUT ======================================================
            
                title = "About Develop History Timestamps",
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
                            title = "Like this plugin? Support its development by buying a fine art print  >>",
                            fill_horizontal = 1,
                        }, -- text

                        viewFactory:push_button {
                            width = 150,
                            title = "Buy a print",
                            enabled = true,
                            action = function()
                                LrHttp.openUrlInBrowser(_G.pluginBuyPrintsURL)
                            end,
                        }, -- button
                }, -- row
                viewFactory:row {
                        spacing = viewFactory:control_spacing(),
                        viewFactory:static_text {
                            title = "Author: Andrei I. Gere    Website: www.27shutterclicks.com",
                            text_color = LrColor(.1, .2, .5),
                            tooltip = "Click to visit website",
                            mouse_down = function()
                                LrHttp.openUrlInBrowser(info.LrPluginInfoUrl)
                            end,
                            fill_horizontal = 1,
                        }, -- text
                        viewFactory:push_button {
                            width = 150,
                            title = "Follow on Twitter",
                            enabled = true,
                            action = function()
                                LrHttp.openUrlInBrowser(_G.pluginTwitterURL)
                            end,
                        }, -- button
                }, -- row
            }, -- section
            
            { -- Section for PLUGIN OPTIONS ================================================
            
                title = "Plug-in Options",
                bind_to_object = prefs, --bind to user plugin preferences
                viewFactory:row {
                        viewFactory:static_text {
                            title = "Step Preview:",
                            width = 85,
                            font = "<system/small/bold>"
                        }, -- text
                        viewFactory:static_text {
--                            bind_to_object = propertyTable,
                            fill_horizontal = 0.7,
                            alignment = "center",
                            title = LrView.bind {
                                keys = { 'showStepNumbers', 'showTimestamps', 'showTimestampsLeft', 'showStepNumbersRight', 'showDualTimestamps' }, -- bind to both keys
                                bind_to_object = prefs,
                                operation = function( binder, options, fromTable )
                                    if not options.showTimestamps then
                                        if options.showStepNumbers then
                                            if options.showStepNumbersRight then
                                                return histStepNumberRightNoTimestamp
                                            else 
                                                return histStepNumberNoTimestamp
                                            end
                                        else
                                            return histNoStepNumberNoTimestamp
                                        end
                                    else --if showing timestamps
                                        if options.showDualTimestamps then
                                            if options.showTimestampsLeft then
                                                if options.showStepNumbers then
                                                    if options.showStepNumbersRight then
                                                        return histDualTimestampsLeftStepNumberRight
                                                    else -- step numbers left
                                                        return histDualTimestampsLeft
                                                    end
                                                else --no step numbers 
                                                    return histDualTimestampsLeftNoStepNumber
                                                end
                                            else -- show timestamps right
                                                if options.showStepNumbers then
                                                    if options.showStepNumbersRight then
                                                        return histDualTimestampsStepNumberRight
                                                    else -- step numbers left
                                                        return histDualTimestamps
                                                    end
                                                else --no step numbers 
                                                    return histDualTimestampsRightNoStepNumber
                                                end
                                            end -- if timestamps left
                                        else -- not dual
                                            if options.showStepNumbers then
                                                if options.showStepNumbersRight then
                                                    if options.showTimestampsLeft then
                                                        return histTimestampLeftStepNumberRight
                                                    else
                                                        return histDefaultStepNumberRight
                                                    end
                                                else -- step numbers left
                                                    if options.showTimestampsLeft then
                                                        return histTimestampLeft
                                                    else
                                                        return histDefault
                                                    end
                                                end
                                            else --no step numbers 
                                                if options.showTimestampsLeft then
                                                    return histTimestampLeftNoStepNumber
                                                else
                                                    return histDefaultNoStepNumber
                                                end
                                            end -- if step numbers
                                        end -- if dual timestamps
                                    end -- 
                                    
                                    
                                end,
                            }, -- title
                        }, -- static_text
                    }, -- row
                viewFactory:row {
                        viewFactory:checkbox {
                            title = "Show Timestamps",
                            value = bind "showTimestamps",
                            fill_horizontal = 1,
                        },
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
                viewFactory:row {
                        viewFactory:checkbox {
                            title = "Show Dual Timestamps",
                            enabled = bind "showTimestamps",
                            value = bind "showDualTimestamps",
                        },
                        viewFactory:column { 
                            fill_vertical =  1,
                            viewFactory:static_text {
                                place_vertical = 0.5,
                                title = "Learn more",
    --                            font = "<system/bold>",
                                size = "mini",
                                mouse_down = function()
                                    dialog.message("Enabling this option will show the additional timestamp for steps like Export, Import, Print and Edited in App, alongside the regular timestamp of the step.", "By default, the plugin doesn't display timestamps for the steps mentioned above, since these steps have dates baked into the step name, based on the local time of the step's occurence. Displaying the additional timestamp may reveal whether a certain step was performed in a different timezone than the one you're currently in. This can be common for those who travel often between timezones with their Lightroom catalog.")
                                        end,
                            } -- static_text learn more
                        } -- column
                }, -- row
                viewFactory:row {
                        viewFactory:checkbox {
                            title = "Show Timestamps at beginning of step name",
                            enabled = bind "showTimestamps",
                            value = bind "showTimestampsLeft"
                        },
                }, -- row
                viewFactory:row {
                        viewFactory:checkbox {
                            title = "Show step numbers",
                            value = bind "showStepNumbers",
                            fill_horizontal = 1,
                        },
                }, -- row 
                viewFactory:row {
                        spacing = viewFactory:control_spacing(),
                        viewFactory:checkbox {
                            enabled = bind "showStepNumbers",
                            title = "Show step numbers after the step name",
                            value = bind "showStepNumbersRight",
                            fill_horizontal = 1,
                        },
                        viewFactory:column { 
                            viewFactory:push_button {
                                width = 150,
                                title = "Reset Plugin Options",
                                action = function()
                                    PluginManager.resetPluginOptions()
                                end,
                            }, -- button
                        } -- column
                
                }, -- row
                viewFactory:row {
                        viewFactory:checkbox {
                            title = "Show Photo ID",
                            value = bind "showPhotoID",
                        },
                        viewFactory:column { 
                            fill_vertical =  1,
                            viewFactory:static_text {
                                place_vertical = 0.5,
                                title = "Learn more",
                                size = "mini",
                                mouse_down = function()
                                    dialog.message("Enabling this option will show the photo local identifier at the beginning of each history step.", "This can be helpful in confirming that the listed steps do indeed belong to the same photo.")
                                end,
                            }, -- static_text learn more
--                            viewFactory:spacer {
--                                height = 1,
--                            }
                        } -- column
                }, -- row 
            }, -- section plugin options
            
			{ -- section PLUGIN UPDATE ======================================================
            
			title = "Plug-in Update",
                
                bind_to_object = propertyTable,
                synopsis = bind 'synopsisText',
                viewFactory:row {
                    bind_to_object = prefs,
                    viewFactory:checkbox {
                        title = "Check for update automatically",
                        value = bind "checkForUpdate",
                        enabled = LrView.bind {
                            key = "checkForUpdate",
                            transform = function (enabled, fromTable)
                                if enabled then
                                LrTasks.startAsyncTask( function()

                                        _G.updateAvailable = nil

                                        PluginManager.checkUpdateAvailable()

                                        propertyTable.updateCheckInProgress = true

                                        local timeWaited = waitForGlobal('updateCheckComplete')


                                        propertyTable.updateCheckInProgress = _G.updateCheckInProgress
                                        propertyTable.updateLabelText = prefs.updateLastCheck

                                        if _G.updateAvailable then
                                            propertyTable.updateButtonText = "View  Update"
                                            propertyTable.synopsisText = "Update Available"
                                        end

                                    end
                                )
                                else 
                                    propertyTable.updateLabelText = prefs.updateLastCheck
                                end -- if enabled
                                return true
                            end,
                    }
                    },
                    viewFactory:column { 
                        fill_vertical =  1,
                        viewFactory:static_text {
                            place_vertical = 0.5,
                            title = "Learn more",
                            size = "mini",
                            mouse_down = function()
                                dialog.message("When enabled, the plugin will check for an update automatically whenever the plugin is selected in the Plugin Manager.", "It is recommended to leave this enabled.")
                            end,
                        }, -- static_text learn more
                        --                            viewFactory:spacer {
                        --                                height = 1,
                        --                            }
                    } -- column
                }, -- row 
                viewFactory:row {
                        spacing = viewFactory:control_spacing(),
                        viewFactory:static_text {
                            title = LrView.bind {
                                keys = { 'updateCheckInProgress', 'updateLabelText', "updateButtonEnabled"},
                                operation = function( binder, binding, fromTable )
                                    if binding.updateCheckInProgress then
                                        binding.updateButtonEnabled = false
                                        return "Checking for plugin updates..."
                                    else 
                                        binding.updateButtonEnabled = true
                                        return binding.updateLabelText
                                    end
                                end,
                            },
                            fill_horizontal = 1,
                        }, -- text

                        viewFactory:push_button {
                            width = 150,
                            title = bind 'updateButtonText',
                            enabled = bind "updateButtonEnabled",
                            action = function()
                                PluginManager.checkUpdate()
                            end
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
            
        } -- return
end

function PluginManager.checkUpdateAvailable(override)
    
    local checkURL = _G.pluginUpdateReleaseURL
    local headers = {
            { field = 'Accept',  value = "application/json" }
        }
    
    _G.updateAvailable = nil
    _G.updateCheckComplete = nil
    
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
            
--            local pluginVersion= "0.9.5"

            -- compare local version number with update version number
            if (pluginUpdateVersion > pluginVersion) or (override) then
                _G.updateAvailable = true
                _G.updateVersion = response.tag_name
                _G.updateDate = os.date("%B %d, %Y",fromISODate(response.published_at))
--                _G.updateCheckText = "Update available: " .. updateVersion .. "  Released: " .. updateDate
                prefs.updateLastCheck = "Update available: " .. updateVersion .. "  Released: " .. updateDate
                _G.updateDetails = response
            else -- no new update available
                _G.updateCheckText = "Plugin is up to date." 
                prefs.updateLastCheck = "Last check: " .. updateCheckTime
                _G.updateAvailable = false
            end
            
            -- signal completion of check
            _G.updateCheckInProgress = false
            _G.updateCheckComplete = true
        end
    )
        
end -- checkUpdateAvailable()

function PluginManager.checkUpdate (override) --override bool parameter used to force update check in devtools

    local checkURL = _G.pluginUpdateReleaseURL
    local headers = {
            { field = 'Accept',  value = "application/json" }
        }

    -- save the name of the plugin folder to a variable
    local pluginFolderName = paths.leafName(_PLUGIN.path)
    
     -- begin AsyncTask
    LrTasks.startAsyncTask( function()

            if override then
                PluginManager.checkUpdateAvailable(true)
            else
                PluginManager.checkUpdateAvailable()
            end
        
            local updateTimeWaited = waitForGlobal('updateCheckComplete')
            
            dialog.showBezel("Checking for update...")

            LrTasks.sleep(2)
            
            -- if no update, display message
            if (not _G.updateAvailable) and (not override) then
                return nil, dialog.message("You are using the latest version of the plugin", "Keep on inspecting timestamps!")
            end
            
            local response = _G.updateDetails
                        
            local pluginVersion = _G.pluginVersion
            local currentVersion = "v" .. pluginVersion
            
            local releaseNotes = "(Currently installed version is " .. currentVersion .. ')\n\n' .. response.body

            local buttonText = "Update Now"
            
            local checkTar = 0 -- initialize variable that holds tar support check flag
            
            -- check if tar supported (mostly for Windows, Mac supports by default)
            if WIN_ENV then
                
                checkTar = LrTasks.execute('cmd /c "WHERE tar"')

                if checkTar ~= 0 then
                    -- tar not supported, plugin may need to be updated manually
                    buttonText = "Open update folder"
                    releaseNotes = releaseNotes .. "\n\nNote: The plugin is unable to install the update automatically. It will need to be installed manually."
                end
            end -- if WIN_ENV

            local confirmUpdate = dialog.confirm("Version " .. response.tag_name .. " is available." ,releaseNotes, buttonText)

            -- CHECK IF UPDATE SHOULD BE INSTALLED AUTOMATICALLY
            if (confirmUpdate == "ok" and checkTar == 0) then -- install update
                
                -- download the update file and get the filename
                local downloadFile = PluginManager.downloadUpdate(response.zipball_url)
                local downloadFileFolder = paths.parent(downloadFile)
                
                dialog.showBezel("Downloading Update...")

                LrTasks.sleep(2)
                -- COMMAND EXAMPLE:
--                 tar --strip-components=1 -xf 27shutterclicks-lrdevhisttimestamps-v0.9.5-0-g82626d4.zip
                
                -- build the command for extraction
                local extractCommand = "tar --strip-components=1 -xf " .. downloadFile .. " --directory \"" .. downloadFileFolder .. '"'

                if WIN_ENV then
                    extractCommand = 'cmd /c "' .. extractCommand .. '"'
                end

                local pluginBackupFolder = paths.child(paths.parent(_PLUGIN.path), pluginFolderName .. "-" .. currentVersion .. "-backup")
                
                -- rename the current version plugin folder
                local move, message = fileUtils.move(_PLUGIN.path,pluginBackupFolder)

                -- extract download archive
                local extractStatus = LrTasks.execute(extractCommand)
                
                dialog.showBezel("Extracting update...")

                if extractStatus == 0 then
                    dialog.showBezel("Update extracted")
                else 
                    return nil, dialog.message("There was an error extracting the plugin update.")
                end
                
                LrTasks.sleep(2)
                    
                -- CONFIRM DELETE OR BACKUP
                local confirmBackup = dialog.confirm("Plugin updated!", "\nWould you like to delete the old plugin version or keep a backup?\n","Delete old version", "Keep a backup")

                if confirmBackup == "ok" then -- delete old version
                    
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
                    
                dialog.showBezel('Updated. Click "Reload Plug-in" button in Plugin Manager')
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

function PluginManager.downloadUpdate(url)

--        local downloadPath = paths.getStandardFilePath("temp")
    
        -- download update to plugin parent folder
        local downloadPath = paths.parent(_PLUGIN.path)
    
        -- also possible url: https://github.com/27shutterclicks/lrdevhisttimestamps/archive/v0.9.5/lrdevhisttimestamps-v0.9.5

        -- get the zipball
        local download, code = LrHttp.get(url)

        local status = code["status"] --returned by get request
    
        local filename = ""
        local folderName = ""

        for key,value in pairs(code) do
            if (type(value) == "table" ) and (string.lower(value.field) == 'content-disposition') then
                filename = split(value.value,"=")[2]
                folderName = filename:match("(.+)%..+$")
            end -- if
        end -- for
    
        local saveFileName = paths.child(downloadPath,filename)
        local saveFile = assert(io.open(saveFileName, 'wb'))
        saveFile:write(download)
        saveFile:close()

        return saveFileName
end

function PluginManager.resetPluginOptions() 

    -- prompt for confirmation
    local confirm = dialog.confirm("Are you sure you want to reset the plugin options to their default settings?")

    if confirm == "ok" then

        -- loop through the table containing the default values and set the plugin preferences accordingly
        for prefKey,value in pairs(_G.prefKeys) do
            prefs[prefKey] = value
        end
        
        dialog.showBezel('The plugin options have been reset.')
        
        return true
        
    else 
        return false
    end
    
end -- resetPluginOptions()
