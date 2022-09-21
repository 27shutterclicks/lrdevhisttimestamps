--module(..., package.seeall)

local LrTasks = import 'LrTasks'
local dialog = import 'LrDialogs'
local plugin = _PLUGIN --LrPlugin class
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local catalog = import "LrApplication".activeCatalog()
local LrFunctionContext = import 'LrFunctionContext'
local LrProgressScope = import 'LrProgressScope'

function getFromDB(sql, progressScopeMsg, progressDialogTitle, progressDialogMessage)
    
    progressScopeMsg ~= nil and progressScopeMsg or "Retrieving data from catalog database" 
    progressDialogTitle ~= nil and progressDialogTitle or "Retrieving data" 
    progressDialogMessage ~= nil and progressDialogMessage or "Retrieving data from catalog database" 
    
    if WIN_ENV then
        sqlite = LrPathUtils.child( _PLUGIN.path, 'sqlite3.exe' )
    else
        sqlite = LrPathUtils.child( _PLUGIN.path, 'sqlite3' )
    end
    
    local dbOutput = false
    
    --    local outputFile = LrPathUtils.getStandardFilePath( 'temp' )
    local outputFile = "c:\\temp"
    outputFile = LrPathUtils.child( outputFile, "lr_getfromdb_output.txt" )
    outputFile = LrFileUtils.chooseUniqueFileName( outputFile )

    cmd = 'cmd /c ""' .. sqlite .. '" "'.. catalog:getPath() .. '" '
    cmd = cmd .. '"' .. sql .. '"'
    cmd = cmd .. " > " .. outputFile .. '"'

    LrTasks.startAsyncTask( function()

        LrFunctionContext.callWithContext('function', function(context)


            -- https://community.adobe.com/t5/lightroom-classic-discussions/lrdialogs-showmodalprogressdialog-does-not-hide-on-completion/td-p/1444404
                    
            local progressScope = LrProgressScope({
                        title = "Retrieving develop history steps timestamps",
                        caption = "Please wait...",
                        functionContext = context
                        })
            local progressDialog = dialog.showModalProgressDialog({

              title = 'Develop History Steps',

              caption = 'Retrieving data from the catalog... please wait',

              cannotCancel = true,

              functionContext = context,

            })

            progressScope:setPortionComplete(0.0, 1.0)
                    
            LrTasks.execute(cmd)

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

--    _G.waitReturn = true
    
    return outputContents
end --getFromDB

--return DB