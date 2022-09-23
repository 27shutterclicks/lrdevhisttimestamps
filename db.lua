--module(..., package.seeall)

local LrTasks = import 'LrTasks'
local dialog = import 'LrDialogs'
local plugin = _PLUGIN --LrPlugin class
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local catalog = import "LrApplication".activeCatalog()
local LrFunctionContext = import 'LrFunctionContext'
local LrProgressScope = import 'LrProgressScope'

-- TODO: maybe move this inside func.lua for less file clutter
function getFromDB(sql, progressScopeMsg, progressDialogTitle, progressDialogMsg)
    
    progressScopeMsg = progressScopeMsg ~= nil and progressScopeMsg or "Retrieving data from catalog database" 
    progressDialogTitle = progressDialogTitle ~= nil and progressDialogTitle or "Retrieving data" 
    progressDialogMsg = progressDialogMsg ~= nil and progressDialogMsg or "Retrieving data from catalog database..." 
    
    local cmd = ""
    local cmdStart = "" -- to hold beginning of shell command which may differ on win/mac
    local cmdEnd = "" -- to hold end of shell command which may differ on win/mac
    
    if WIN_ENV then
        sqlite = LrPathUtils.child( _PLUGIN.path, 'sqlite3.exe' )
        cmdStart = 'cmd /c ""' .. sqlite .. '" '
        cmdEnd = '"'
    else
--        sqlite = LrPathUtils.child( _PLUGIN.path, 'sqlite3' )
        sqlite = 'sqlite3 '
        cmdStart = sqlite .. " "
    end
    
    local dbOutput = false
--    _G.dbOutput = nil
    
    local outputFile = LrPathUtils.getStandardFilePath( 'temp' )
    --    local outputFile = "c:\\temp" -- NOTE: Used for simpler testing
    outputFile = LrPathUtils.child( outputFile, "lr_getfromdb_output.txt" )
    outputFile = LrFileUtils.chooseUniqueFileName( outputFile )

    -- .\sqlite3.exe "E:\Pictures\Lightroom Catalog\AIG Photography 2021.lrcat" "SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE'%45099944%';" > sql.txt
    
    cmd = cmdStart .. '"' .. catalog:getPath() .. '" "' .. sql .. '"'
    cmd = cmd .. " > " .. outputFile .. cmdEnd
    
    LrTasks.startAsyncTask( function()

        LrFunctionContext.callWithContext('function', function(context)


            -- https://community.adobe.com/t5/lightroom-classic-discussions/lrdialogs-showmodalprogressdialog-does-not-hide-on-completion/td-p/1444404
                    
            local progressTask = LrProgressScope({
                    title = progressScopeMsg,
                    caption = "Please wait...",
                    functionContext = context
                        }
                    )
                    
            local progressScope = dialog.showModalProgressDialog({
                      title = progressDialogTitle,
                      caption = progressDialogMsg,
                      cannotCancel = true,
                      functionContext = context,
                        }
                    )

            progressScope:setPortionComplete(0.2, 1)
            progressScope:setPortionComplete(0.5, 1)
            progressScope:setPortionComplete(0.8, 1)
                    
            -- execute the sql
            LrTasks.execute(cmd)
                    
            progressScope:setPortionComplete(0.9, 1)

            progressScope:done()

            end -- function context
        ) -- callwithcontext
            
        _G.dbOutput = true

        end -- function()
    ) -- startAsyncTask

    local timeout = 10;

    local timeWaited = waitForGlobal('dbOutput', timeout);

--    dialog.message("time waited: " .. timeWaited)
    -- check if sql output file exists
    local outputExists, outputContents = pcall( LrFileUtils.readFile, outputFile )


    if outputExists then
            outputContents = outputContents:gsub( "[%z\255\254]", "" )
    end

    if outputContents == "" then
            return nil, dialog.message("Hmm...", "Output file looks empty... : " .. outputFile, "critical")
    end


    -- delete temp file
    LrFileUtils.delete(outputFile)

--    dbOutput = outputContents 
--    dialog.message("outside lrtask:  " .. outputContents)

    _G.dbOutput = nil -- reset output flag so that waitForGlobal works on next call

    return outputContents
end --getFromDB
