--[[----------------------------------------------------------------------------

Develop History Timestamps

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
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'

local prefs = import 'LrPrefs'.prefsForPlugin() 

-- include files
require "Database"
require "Utility"
local inspect = require 'Inspect'

-- retrieve the active photo // returns nil if no photo selected
local photo = catalog:getTargetPhoto() 

-- check if a photo was selected
if not photo then
    return nil, dialog.message("Please select a photo", "No photo seems to be selected. Please select a photo and try again.")
end

-- get photo id used in catalog
local photoID = photo.localIdentifier

-- show initial message
dialog.messageWithDoNotShow({
        message = "View Develop History Timestamps retrieves the date and time of all Develop History steps of an image in a floating window.\n\nYou may open multiple Develop History Steps windows by leaving the window open and getting the timestamps for other images.",
        info = "Tip: Click inside the window and drag down to see all entries or use Ctrl/Cmd + A to select all for copying and pasting elsewhere.",
        actionPrefKey = "plgDevelopHistoryTimestampsMsg"
    })

-- initialize global variable for floating dialog toFront() function
_G["floatingDialog"] = {}

-- begin task
LrTasks.startAsyncTask( function()

        -- get the photo filename to show in dialog box
        local filename = photo:getFormattedMetadata ("fileName")

        -- prepare the SQL statement
        local sql = 'SELECT name,dateCreated,image FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image = \'' .. photoID .. '\' ORDER BY dateCreated DESC;'

        -- call function to query the catalog/database
        local outputContents, msg = getFromDB(sql,"Retrieving history steps from catalog database")

        -- check if output received, if not show error
        if outputContents == nil then
            dialog.message("There was an error", msg, "critical")
            return nil
        end
        
        -- initialize variables
        local splitStep = {}
        local historySteps = ""

        -- split (explode to array) the db output string by line break
        stepDates = split(outputContents,"\n")

        local showingText = #stepDates < 50 and "Showing all" or "Showing last 50, click and drag down for all"

        historySteps = #stepDates .. " develop history steps found (" .. showingText .. ")\n"

        -- save most recent history step (last develop step) to variable
        local lastEditStep = split(stepDates[1],"|")
        
        -- save oldest history step (first import/copy creation) to variable
        local firstEditStep = split(stepDates[#stepDates],"|")
        
        -- initialize variable that will hold the length of the longest step (for dialog box width size)
        local stepStringLength = 0

        -- build history steps output
        historySteps = historySteps .. "-----------------------\n"
        historySteps = historySteps .. "Image last edited: " .. timeStampToDate(lastEditStep[2]) .. "\n"
        historySteps = historySteps .. "Image first imported: " .. timeStampToDate(firstEditStep[2]) .. "\n"
        historySteps = historySteps .. "-----------------------\n"

        -- save number of history steps to variable
        local stepNumber = #stepDates
        
        -- get plugin options
        local showTimestamps = prefs.showTimestamps
        local showDualTimestamps = prefs.showDualTimestamps
        local showTimestampsLeft = prefs.showTimestampsLeft
        local showStepNumbers = prefs.showStepNumbers
        local showStepNumbersRight = prefs.showStepNumbersRight
        
        local stepNumbersTextLeft, stepNumbersTextRight = ""
        local stepDateBaked = ""
        
        -- loop through history steps and build output
        for key,value in ipairs(stepDates) do

            -- split step by separator (e.g.: Update Radial Gradient 1|685337266.640549 )
            splitStep[key] = split(value,"|")
            
            local stepName = splitStep[key][1]
            
            -- check if step may already include a date, usually included in paranthesis after the step name
            local dateExists = string.find(stepName,"%(") --returns nil if not found
            
            -- save the step timestamp to variable
            stepDate = timeStampToDate(splitStep[key][2])
            
            if dateExists then
                -- extract baked-in timestamp
                stepDateBaked = string.sub(stepName, dateExists, #stepName)
                
                -- extract the step name
                stepName = string.sub(stepName, 1, dateExists-2)
            end

            --build date based on plugin options
            if dateExists and not prefs.showDualTimestamps then
                stepDate = " " .. stepDateBaked -- timestamp is the baked-in one
            elseif dateExists and prefs.showDualTimestamps then
                stepDate = " (" .. stepDate .. ") " .. stepDateBaked .. " "
            else 
                stepDate = " (" .. stepDate .. ") "
            end
            
            local stepNumberLeft = "Step " .. stepNumber .. ": "
            local stepNumberRight = " - Step " .. stepNumber
            
            -- get format for current step
            local currentStep = getHistoryStepFormat(stepName, stepDate, stepNumberLeft, stepNumberRight)

            -- check if show photo ID is enabled
            if prefs.showPhotoID then
                currentStep = "ID: " .. photoID .. " - " .. currentStep 
            end
            
            -- add current step to the other steps
            historySteps = historySteps .. "\n" .. currentStep
            
            -- decrease step number variable
            stepNumber = stepNumber - 1
            
            -- check string length of step
            if stepStringLength < #currentStep then
                stepStringLength = #currentStep
            end
        end

        -- build the dialog box view
        local view = LrView.osFactory()
        local dialogContents = 
                view:column { 	
                        view:edit_field { 
                            value = historySteps, 
                            width_in_chars = stepStringLength/1.7,
                            height_in_lines = #stepDates < 50 and #stepDates+6 or 50
                        }, -- edit_field
                }, -- column
            
        -- display bezel message
        dialog.showBezel("Displaying History Timestamps")
        
        --show floating dialog
        local dialog = dialog.presentFloatingDialog(_PLUGIN,
            {
                title = "Develop History Steps for: " .. filename ,
                contents = dialogContents,
                -- save_frame = "plgDevelopHistoryStepTimestamps",
                onShow = function(t)
                    _G.floatingDialog = t
                end
            }
        )
  end -- startasynctask function
) -- startasynctask

function getHistoryStepFormat(stepName, stepDate, stepNumberLeft, stepNumberRight)
    
    -- step builder examples
    local histNoStepNumberNoTimestamp = stepName
    local histStepNumberNoTimestamp = stepNumberLeft .. stepName
    local histStepNumberRightNoTimestamp = stepName .. stepNumberRight
    local histDefault = stepNumberLeft .. stepName .. stepDate
    local histDefaultNoStepNumber = stepName .. stepDate
    local histDefaultStepNumberRight = stepName .. stepDate .. stepNumberRight

    local histTimestampLeftStepNumberRight = stepDate .. stepName .. stepNumberRight
    local histTimestampLeftNoStepNumber = stepDate .. stepName 
    local histTimestampLeft = stepDate .. stepNumberLeft .. stepName

    local histDualTimestamps = stepNumberLeft .. stepName .. stepDate
    local histDualTimestampsStepNumberRight = stepName .. stepDate .. stepNumberRight
    local histDualTimestampsLeft = stepDate .. stepNumberLeft .. stepName
    local histDualTimestampsLeftStepNumberRight = stepDate .. stepName .. stepNumberRight
    local histDualTimestampsLeftNoStepNumber = stepDate .. stepName
    local histDualTimestampsRightNoStepNumber = stepName .. stepDate

--    dialog.message("prefs " .. inspect(prefs))
    if not prefs.showTimestamps then
        if prefs.showStepNumbers then
            if prefs.showStepNumbersRight then
                return histStepNumberRightNoTimestamp
            else 
                return histStepNumberNoTimestamp
            end
        else
            return histNoStepNumberNoTimestamp
        end
    else --if showing timestamps
        if prefs.showDualTimestamps then
            if prefs.showTimestampsLeft then
                if prefs.showStepNumbers then
                    if prefs.showStepNumbersRight then
                        return histDualTimestampsLeftStepNumberRight
                    else -- step numbers left
                        return histDualTimestampsLeft
                    end
                else --no step numbers 
                    return histDualTimestampsLeftNoStepNumber
                end
            else -- show timestamps right
                if prefs.showStepNumbers then
                    if prefs.showStepNumbersRight then
                        return histDualTimestampsStepNumberRight
                    else -- step numbers left
                        return histDualTimestamps
                    end
                else --no step numbers 
                    return histDualTimestampsRightNoStepNumber
                end
            end -- if timestamps left
        else -- not dual
            if prefs.showStepNumbers then
                if prefs.showStepNumbersRight then
                    if prefs.showTimestampsLeft then
                        return histTimestampLeftStepNumberRight
                    else
                        return histDefaultStepNumberRight
                    end
                else -- step numbers left
                    if prefs.showTimestampsLeft then
                        return histTimestampLeft
                    else
                        return histDefault
                    end
                end
            else --no step numbers 
                if prefs.showTimestampsLeft then
                    return histTimestampLeftNoStepNumber
                else
                    return histDefaultNoStepNumber
                end
            end -- if step numbers
        end -- if dual timestamps
    end -- 


end -- getHistoryStepFormat()