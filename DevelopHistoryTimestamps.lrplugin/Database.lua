--[[----------------------------------------------------------------------------

Database Querying

Copyright 2022, Andrei I. Gere - www.27shutterclicks.com

Created: 09/2022
------------------------------------------------------------------------------]]

local LrTasks = import 'LrTasks'
local dialog = import 'LrDialogs'
local plugin = _PLUGIN --LrPlugin class
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local catalog = import "LrApplication".activeCatalog()
local LrFunctionContext = import 'LrFunctionContext'
local LrProgressScope = import 'LrProgressScope'

-- Main function for executing sql queries on the Ligthroom catalog
-- Accepts a prepared SQL query as first parameter and optional progress messages parameters
-- Reads contents of temp output file created by shell command, if any
-- Returns output as string on successful read, or nil and message otherwise

function getFromDB(sql, progressScopeMsg, progressDialogTitle, progressDialogMsg)
    
    -- set parameter defaults
    progressScopeMsg = progressScopeMsg ~= nil and progressScopeMsg or "Retrieving data from catalog database" 
    progressDialogTitle = progressDialogTitle ~= nil and progressDialogTitle or "Retrieving data" 
    progressDialogMsg = progressDialogMsg ~= nil and progressDialogMsg or "Retrieving data from catalog database..." 
    
    -- initialize command variables
    local cmd = ""
    local cmdStart = "" -- to hold beginning of shell command which may differ on win/mac
    local cmdEnd = "" -- to hold end of shell command which may differ on win/mac
    
    -- platform-dependent variables and command structure
    if WIN_ENV then
        sqlite = LrPathUtils.child( _PLUGIN.path, 'sqlite3.exe' )
        cmdStart = 'cmd /c ""' .. sqlite .. '" '
        cmdEnd = '"'
    else -- then Mac
        -- macOS ships with sqlite built-in
        sqlite = 'sqlite3 '
        cmdStart = sqlite .. " "
    end
    
    -- initialize db output flag
    _G.dbOutput = nil
    
    -- build the temp output file name and path
    local outputFilePath = LrPathUtils.getStandardFilePath( 'temp' )
    --    local outputFile = "c:\\temp" -- NOTE: Used for simpler dev testing
    local outputFile = LrPathUtils.child( outputFilePath, "lr_getfromdb_output.txt" )
    outputFile = LrFileUtils.chooseUniqueFileName( outputFile )

        -- sample working command in Windows 10
    -- .\sqlite3.exe "E:\Pictures\Lightroom Catalog\My Catalog.lrcat" "SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image = '45099944';" > sql.txt
    
    -- assemble shell command (see example above)
    cmd = cmdStart .. '"' .. catalog:getPath() .. '" "' .. sql .. '"'
    cmd = cmd .. " > " .. outputFile .. cmdEnd
    
    -- begin AsyncTask
    LrTasks.startAsyncTask( function()
                       
            -- call with context required for progress dialog
            LrFunctionContext.callWithContext('function', function(context)

                        -- ref: https://community.adobe.com/t5/lightroom-classic-discussions/lrdialogs-showmodalprogressdialog-does-not-hide-on-completion/td-p/1444404
                    
                    -- show progress bar in Lightroom's progress area at the top-left of the catalog window
                    local progressTask = LrProgressScope({
                            title = progressScopeMsg,
                            caption = "Please wait...",
                            functionContext = context
                                }
                            )
                    
                    -- configure progress bar
                    local progressScope = dialog.showModalProgressDialog({
                              title = progressDialogTitle,
                              caption = progressDialogMsg,
                              cannotCancel = true,
                              functionContext = context,
                                }
                            )
                    
                    -- animate progress bar    
                    progressScope:setPortionComplete(0.2, 1)
                    progressScope:setPortionComplete(0.5, 1)
                    progressScope:setPortionComplete(0.8, 1)

                    -- execute the sql query
                    LrTasks.execute(cmd)

                    -- increase progress
                    progressScope:setPortionComplete(0.9, 1)

                    -- mark progress complete
                    progressScope:done()

                    end -- function context
            ) -- callwithcontext

            -- set output flag for watiglobal function
            _G.dbOutput = true

            end -- startAsyncTask function()
    ) -- startAsyncTask

    local timeout = 15; --it's rare that the query would need more time to complete

    -- wait for sql query complete output flag before continuing
    local timeWaited = waitForGlobal('dbOutput', timeout);

    -- check if timeout reached and return message if so
    if timeWaited == nil then
       return nil, "The SQL timeout limit of " .. timeout .. " seconds has been reached. Querying the catalog took too long." 
    end
    
    -- reset output flag so that waitForGlobal works on next call
    _G.dbOutput = nil 
    
    -- read sql temp output file
    local outputExists, outputContents = pcall( LrFileUtils.readFile, outputFile )

    -- check if sql output file exists
    if outputExists then
        -- remove strange characters from output file
        outputContents = outputContents:gsub( "[%z\255\254]", "" )
    else 
        return nil, "The SQL query produced no output file or the output file is empty.", outputFile
    end
    
    -- delete temp output file
    LrFileUtils.delete(outputFile)

    return outputContents, "Success", outputFile
    
end --getFromDB
