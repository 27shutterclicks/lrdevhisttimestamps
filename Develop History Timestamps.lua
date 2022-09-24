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

-- include files
require "Database"
require "Utility"

-- retrieve the active photo // returns nil if no photo selected
local photo = catalog:getTargetPhoto() 

--check if a photo was selected
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
        local sql = 'SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE \'%' .. photoID .. '%\' ORDER BY dateCreated DESC;'

        -- call function to query the catalog/database
        local outputContents, msg = getFromDB(sql)

        --check if output received, if not show error
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

        -- build history steps output
        historySteps = historySteps .. "-----------------------\n"
        historySteps = historySteps .. "Image last edited: " .. timeStampToDate(lastEditStep[2]) .. "\n"
        historySteps = historySteps .. "Image first imported: " .. timeStampToDate(firstEditStep[2]) .. "\n"
        historySteps = historySteps .. "-----------------------\n"

        -- save number of history steps to variable
        local stepNo = #stepDates

        -- loop through history steps and build output
        for key,value in ipairs(stepDates) do

            -- split step by separator (e.g.: Update Radial Gradient 1|685337266.640549 )
            splitStep[key] = split(value,"|")
            
            -- add the step number before the step name
            stepName = "Step " .. stepNo .. ": " .. splitStep[key][1]

            -- check if step may already include a date, usually included in paranthesis after the step name
            local dateExists = string.find(stepName,"%(") --returns nil if not found
            
            -- save the step timestamp to variable
            stepDate = timeStampToDate(splitStep[key][2])

            -- build output with or without including the timestamp
            if not dateExists then
                historySteps = historySteps .. stepName .. " (" .. stepDate .. ")\n"
            else
                historySteps = historySteps .. stepName .. "\n" --omit the date if name includes it 
            end

            -- decrease step number variable
            stepNo = stepNo - 1
        end

        -- build the dialog box view
        local view = LrView.osFactory()
        local contents = 
            view:row{
                bind_to_object = props,	-- not currently in use
                view:column { 				
                        view:edit_field { 
                            value = historySteps, 
                            width_in_chars = 50,
                            height_in_lines = #stepDates < 50 and #stepDates+5 or 50
                        }, -- edit_field
                }, -- column
            } -- row

        --show floating dialog
        local dialog = dialog.presentFloatingDialog(_PLUGIN,
            {
                title = "Develop History Steps for: " .. filename ,
                contents = contents,
                -- save_frame = "plgDevelopHistoryStepTimestamps",
                onShow = function(t)
                    _G.floatingDialog = t
                end
            }
        )
  end -- startasynctask function
) -- startasynctask