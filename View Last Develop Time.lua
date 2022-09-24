--[[----------------------------------------------------------------------------

Develop History Timestamps - View Last Develop Time

Copyright 2022, Andrei I. Gere - www.27shutterclicks.com

Created: 09/2022
------------------------------------------------------------------------------]]

local LrTasks = import 'LrTasks'
local catalog = import "LrApplication".activeCatalog()
local ProgressScope = import 'LrProgressScope'
local dialog = import 'LrDialogs'
local LrView = import 'LrView'
local plugin = _PLUGIN --LrPlugin class
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrStringUtils = import 'LrStringUtils'

require "Database"
require "Utility"

-- retrieve the active photo // returns nil if no photo selected
local photo = catalog:getTargetPhoto() 

--check if a photo was selected
if not photo then
    return nil, dialog.message("Please select a photo", "No photo seems to be selected. Please select a photo and try again")
end

-- get photo id used in catalog
local photoID = photo.localIdentifier

-- show initial message
dialog.messageWithDoNotShow({
        message = "View Last Develop Time retrieves the date and time of the last Develop History step of an image.\n\nNote that this is different from Lightroom's regular Edit Time timestamp, which also accounts for any changes to an image in regards to flagging, star rating, color labeling, keywording and maybe other metadata.",
        info = "Use View Edit Time option of the plugin to get the regular Edit Time timestamp.",
        actionPrefKey = "plgDevelopHistoryTimestampsLastEditMsg"
    })

-- begin task
LrTasks.startAsyncTask( function()

        -- get the photo filename to show in dialog box
        local filename = photo:getFormattedMetadata ("fileName")
        
        -- prepare the SQL statement
        local sql = 'SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE \'%' .. photoID .. '%\' ORDER BY dateCreated DESC LIMIT 1;'

        -- call function to query the catalog/database
        local outputContents = getFromDB(sql, "Retrieving latest develop time", "Latest Develop Time", "Retrieving latest develop time for the selected photo...")
        
        --check if output received, if not show error
        if outputContents == nil then
            dialog.message("There was an error", msg, "critical")
            return nil
        end
        
        -- initialize variables
        local splitStep = {}
        
        -- split/explode the db output by divider
        splitStep = split(outputContents,"|")
        
        -- set output values to variables
        local lastEdited = splitStep[2]

        -- format timestamp to string
        lastEdited = timeStampToDate(lastEdited,"%A, %B %d, %Y %I\:%M\:%S %p")

        -- show output
        dialog.message( lastEdited, "Latest develop time for: " .. filename)

    end -- function()
) --startAsyncTask