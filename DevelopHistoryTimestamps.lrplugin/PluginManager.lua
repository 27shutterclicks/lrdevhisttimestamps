local dialog = import 'LrDialogs'
local LrHttp = import "LrHttp"
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'
local paths = import 'LrPathUtils'
local fileUtils = import 'LrFileUtils'

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

function PluginManager.sectionsForTopOfDialog( viewFactory , _ )
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
				title = "Reset Dialogs",
                viewFactory:row {
                        spacing = viewFactory:control_spacing(),

                        viewFactory:static_text {
                            title = "Check for plugin updates",
                            fill_horizontal = 1,
                        }, -- text

                        viewFactory:push_button {
                            width = 150,
                            title = "Check Update",
                            enabled = true,
                            action = function()
                                PluginManager.checkUpdate()
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


function PluginManager.checkUpdate()

    local checkURL = "https://api.github.com/repos/27shutterclicks/lrdevhisttimestamps/releases/latest"
    local headers = {
            { field = 'Accept',  value = "application/json" }
        }

     -- begin AsyncTask
    LrTasks.startAsyncTask( function()

            local response,data = LrHttp.get( checkURL, headers, 10 )

    --        log(inspect(response))

            response = json:decode(response)


            dialog.showBezel("Checking for update...")

            LrTasks.sleep(2)

            local currentVersion = "v".. info.VERSION.major .. '.' .. info.VERSION.minor .. '.' .. info.VERSION.revision

            local releaseNotes = "(Currently installed version is " .. currentVersion .. ')\n\n' .. response.body

            -- check if tar supported

--            local checkTar = LrTasks.execute('cmd /c "WHERE tar"')
            local checkTar = 1
            local buttonText = ""

            if checkTar ~= 0 then
                -- tar not supported, plugin may need to be updated manually
                buttonText = "Open update folder"
                releaseNotes = releaseNotes .. "\n\nNote: The plugin is unable to install the update automatically. It will need to be installed manually."
            else
                buttonText = "Update Now"
            end

            local confirmUpdate = dialog.confirm("Version " .. response.tag_name .. " is available." ,releaseNotes, buttonText)

            if (confirmUpdate == "ok" and checkTar == 0) then

                local downloadFile = PluginManager.downloadFile(response.zipball_url)

                dialog.showBezel("Downloading Update...")
    --            log("filename: " .. saveFileName)

    --            log("code is: " .. code["content-disposition"])

                dialog.showBezel("Extracting update...")
                local unzip = paths.child( _PLUGIN.path, 'unzip.exe' )
                local tempPath = paths.child("c:\\temp\\", "unzipoutput.txt")
                local zipcmd ='cmd /c ""' .. unzip ..  '" "' .. saveFileName .. '" -d ' .. '"' .. 'c:\\temp' .. '""'

                -- tar --strip-components=1 -xvf 27shutterclicks-lrdevhisttimestamps-v0.9.5-0-g82626d4.zip
--                local zipcmd ='cmd /c ""' .. unzip ..  '" "' .. saveFileName .. '" -d ' .. '"' .. _PLUGIN.path .. '""'

                local tempname = paths.child("c:\\temp",folderName)
--                    local pluginUpdateFolder = paths.child(tempname,"DevelopHistoryTimestamps.lrplugin")
                local pluginOldFolder = paths.child("c:\\temp","DevelopHistoryTimestamps.lrplugin")

                local pluginNewFolder = paths.child("c:\\temp","DevelopHistoryTimestamps.lrplugin-" .. currentVersion .. "-backup")

                log("plugin path is: " .. _PLUGIN.path)

                log("old folder path is: " .. pluginOldFolder)
                log("new folder path is: " .. pluginNewFolder)
--                local move, reason = fileUtils.move(pluginOldFolder,pluginNewFolder)

                log("move result is: " .. inspect(move))
                log("reason is: " .. inspect(reason))

                log("zipcmd is: " .. zipcmd)
--                local status = LrTasks.execute(zipcmd)
                log("execute status : " ..status)

                --check for exit status 0 to make sure operation succeeded
                if status ~= 0 then
                    dialog.showError("There was an error extracting the plugin update.")
                end


                local confirmBackup = dialog.confirm("Plugin updated!", "\nWould you like to delete the old plugin version or keep a backup?\n","Delete old version", "Keep a backup")

            else if  (confirmUpdate == "ok" and checkTar ~= 0) then -- no tar support

                    -- setup OS-specific variables and commands
                    local windowName = ""
                    local windowCommand = ""

                    if WIN_ENV then
                        windowName = "Windows Explorer"
                        windowCommand = 'cmd /c "explorer.exe /select, "' .. saveFileName .. '""'
                    else
                        windowName = "Finder"
                        windowCommand = 'open -R "' .. saveFileName .. '"'
                    end -- if WIN_ENV
                log("confirm updates is: "..confirmUpdate)
                    -- take user to plugin download folder

                local moveFile = fileUtils.move(saveFileName, paths.parent(_PLUGIN.path))
                --maybe move update archive to plugin parent folder
                -- reveal downloaded update file in a window
                LrTasks.execute(windowCommand)

                dialog.showBezel("Plugin update archive opened in ".. windowName .. " window", 5)

            else -- user clicked cancel on confirmUpdate

                    --

            end -- if confirmUpdate
    end --startAsyncTask function
    ) -- startAsyncTask


end

function PluginManager.downloadUpdate( url )

--        local downloadPath = paths.getStandardFilePath("temp")
        local downloadPath = _PLUGIN.path

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
                log("filename is: ".. filename)
                log("folder is: ".. folderName)
            end -- if
        end -- for

        saveFileName =paths.child(downloadPath,filename)
        local saveFile = assert(io.open(saveFileName, 'wb'))
        saveFile:write(download)
        saveFile:close()

        return saveFileName
end
