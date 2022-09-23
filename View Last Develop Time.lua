local LrTasks = import 'LrTasks'
local catalog = import "LrApplication".activeCatalog()
local ProgressScope = import 'LrProgressScope'
local dialog = import 'LrDialogs'
local LrView = import 'LrView'
local plugin = _PLUGIN --LrPlugin class
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrStringUtils = import 'LrStringUtils'

require "db"
require "func"

local photo = catalog:getTargetPhoto() -- retrieve the active photo // returns nil if no photo selected

--check if a photo was selected
if not photo then
    return nil, dialog.message("Please select a photo", "No photo seems to be selected. Please select a photo and try again")
end

local photoID = photo.localIdentifier

dialog.messageWithDoNotShow({
        message = "View Last Develop Time retrieves the date and time of the last Develop History step of an image.\n\nNote that this is different from Lightroom's regular Edit Time timestamp, which also accounts for any changes to an image in regards to flagging, star rating, color labeling, keywording and maybe other metadata.",
        info = "Use View Edit Time option of the plugin to get the regular Edit Time timestamp.",
        actionPrefKey = "plgDevelopHistoryTimestampsLastEditMsg"
    })

LrTasks.startAsyncTask( function()
        
    local filename = photo:getFormattedMetadata ("fileName")

    local sql = 'SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE \'%' .. photoID .. '%\' ORDER BY dateCreated DESC LIMIT 1;'

    
    local outputContents = getFromDB(sql, "Retrieving latest develop time", "Latest Develop Time", "Retrieving latest develop time for the selected photo...")

    -- initialize variables
    local splitStep = {}
    
    splitStep = split(outputContents,"|")
    lastEdited = splitStep[2]
--    lastEdited = tonumber(lastEdited) + 978307200

--    lastEdited = os.date("%A, %B %d, %Y %X",lastEdited)
    lastEdited = timeStampToDate(lastEdited,"%A, %B %d, %Y %I\:%M\:%S %p")
    
    dialog.message( lastEdited, "Latest develop time for: " .. filename)
	
end -- function()
) --startAsyncTask