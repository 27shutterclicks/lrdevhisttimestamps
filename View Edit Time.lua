local LrTasks = import 'LrTasks'
local catalog = import "LrApplication".activeCatalog()
local ProgressScope = import 'LrProgressScope'
local dialog = import 'LrDialogs'
local LrView = import 'LrView'
local plugin = _PLUGIN --LrPlugin class
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrStringUtils = import 'LrStringUtils'
local LrDate = import 'LrDate'

require "db"
require "func"

local photo = catalog:getTargetPhoto() -- retrieve the active photo // returns nil if no photo selected

--check if a photo was selected
if not photo then
    return nil, dialog.message("Please select a photo", "No photo seems to be selected. Please select a photo and try again")
end

local photoID = photo.localIdentifier

dialog.messageWithDoNotShow({
        message = "The View Edit Time option  retrieves the date and time of Lightroom's regular Edit Time timestamp, which accounts for any changes to an image in regards to flagging, star rating, color labeling, keywording and maybe other metadata.",
        info = "Use View Last Develop Time option of the plugin to get the latest Develop History Step timestamp.",
        actionPrefKey = "plgDevelopHistoryTimestampsLastChangeMsg"
    })

LrTasks.startAsyncTask( function()
        
    local filename = photo:getFormattedMetadata ("fileName")

    local sql = 'SELECT changedAtTime,localTimeOffsetSecs FROM main.AgLibraryImageChangeCounter WHERE image LIKE \'%' .. photoID .. '%\';'
    
    local outputContents = getFromDB(sql, "Retrieving Image Edit Time", "Latest Edit Time", "Retrieving last edited time for the selected photo...")
        
    outputContents = split(outputContents,"|")
    
    local changedTime = outputContents[1]
    local timeOffset = tonumber(outputContents[2]) --returned in seconds from db

    changedTime = fromISODate(changedTime)-timeOffset
    
    dialog.message( os.date("%A, %B %d, %Y %I\:%M\:%S %p",changedTime), "Last edit time for: " .. filename)
	
end -- function()
) --startAsyncTask

