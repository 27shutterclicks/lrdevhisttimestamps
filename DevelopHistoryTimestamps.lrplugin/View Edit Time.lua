--[[----------------------------------------------------------------------------

Develop History Timestamps - View Edit Time

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
local LrDate = import 'LrDate'

-- include files
require "Database"
require "Utility"

-- retrieve the active photo // returns nil if no photo selected
local photo = catalog:getTargetPhoto()

-- check if a photo was selected
if not photo then
    return nil, dialog.message("Please select a photo", "No photo seems to be selected. Please select a photo and try again")
end

-- get photo id used in catalog
local photoID = photo.localIdentifier

-- show initial message
dialog.messageWithDoNotShow({
        message = "The View Edit Time option retrieves the date and time of Lightroom's regular Edit Time timestamp, which accounts for any changes to an image in regards to developing, flagging, star rating, color labeling, keywording and maybe other metadata.",
        info = "Tip: Use View Last Develop Time option of the plugin to get the latest Develop History Step timestamp.",
        actionPrefKey = "plgDevelopHistoryTimestampsLastChangeMsg"
    })

-- begin task
LrTasks.startAsyncTask( function()

        -- get the photo filename to show in dialog box
        local filename = photo:getFormattedMetadata ("fileName")

        -- prepare the SQL statement
        local sql = 'SELECT changedAtTime,localTimeOffsetSecs FROM main.AgLibraryImageChangeCounter WHERE image = ' .. photoID .. ';'

        -- call function to query the catalog/database
        local outputContents, msg, tempFile = getFromDB(sql, "Retrieving Image Edit Time", "Latest Edit Time", "Retrieving last edited time for the selected photo...")

        -- check if output received, if not show error
        if outputContents == nil then
            dialog.message("Error with database query output file." .. " (" .. tempFile .. ") " , msg, "critical")
            return nil
        end
        
        -- check if query return is empty - possible if no change counter found for photo ID
        if #outputContents == 0 then
            return nil, dialog.message('There is no "Edit Time" information available for this image in the catalog.', "Select another image and try again.")
        end
        
        -- split/explode the db output by divider
        outputContents = split(outputContents,"|")

        -- set output values to variables
        local changedTime = outputContents[1]
        local timeOffset = tonumber(outputContents[2]) --returned in seconds from db

        -- account for time offset possibly being nil (not existing in db)
        timeOffset = timeOffset ~= nil and timeOffset or 0 -- if nil set it to zero
        
        -- parse ISO timestamp to seconds and adjust timezone offset
        changedTime = fromISODate(changedTime) + timeOffset
        
        -- account for Daylight Savings Time (DST)
        local time = os.date("*t")
        local dst = time.isdst
        
        -- subtract one hour if DST is in effect
        changedTime = dst~= nil and changedTime-3600 or changedTime
        
        -- save the formatted time string to variable
        local lastEditTime = os.date("%B %d, %Y %I\:%M\:%S %p",changedTime)
        
        -- display bezel message
        dialog.showBezel("Displaying Last Edit Time")

        -- show output
        dialog.message( lastEditTime, "Last edit time for: " .. filename)

    end -- function()
) --startAsyncTask

