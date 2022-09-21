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

LrTasks.startAsyncTask( function()
        
    local filename = photo:getFormattedMetadata ("fileName")

    

    local sql = 'SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE \'%' .. photoID .. '%\' ORDER BY dateCreated DESC LIMIT 1;'

    
    local outputContents = getFromDB(sql, "Retrieving last edited time", "Last Edited Time", "Retrieving last edited for the selected photo...")

    -- initialize variables
    local splitStep = {}
    
    splitStep = split(outputContents,"|")
    lastEdited = splitStep[2]
    lastEdited = tonumber(lastEdited) + 978307200

    lastEdited = os.date("%A, %B %d, %Y %X",lastEdited)
    
    dialog.message( lastEdited, "Last edit time for: " .. filename)
	
end -- function()
) --startAsyncTask

-- .\sqlite3.exe "E:\Pictures\Lightroom Catalog\AIG Photography 2021.lrcat" "SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE'%45099944%';" > sql.txt
