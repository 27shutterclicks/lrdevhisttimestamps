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

require "func"
require "db"
    
--LrFunctionContext.callWithContext("floatingDialog", function( context )
        
        --[[local view = LrView.osFactory()
        local props = LrBinding.makePropertyTable(context)
        props = {
            steps = "Retrieving data from catalog... please wait",
            messageVisible = true,
            stepsVisible = false,
            stepsHeight = 3
        }
--        props.stepsHeight = 1
        
        local contents = 
            view:row{
                bind_to_object = props,	
                view:column { 				
                     view:view {
--                          visible = LrView.bind("messageVisible"),
                            visible = LrBinding.keyIsNotNil("messageVisible"),
                            view:edit_field {
                                value = LrView.bind("steps"),
                                width_in_chars = 40,
                                height_in_lines = 1,
                            }
                        },   
                    view:view { 
                        visible = LrBinding.keyIsNotNil("stepsVisible"),
                        view:edit_field {
                            value = LrView.bind("steps"),
                            width_in_chars = 40,
                            height_in_lines = LrView.bind("stepsHeight"),
                        },
                    }
                }
        --				f:edit_field { value = catalog:getPath(), width_in_chars = 80, height_in_lines = 1 },
        --				f:edit_field { value = cmd, width_in_chars = 80, height_in_lines = 1 },
        --				f:edit_field { value = sqlite, width_in_chars = 80, height_in_lines = 1 },
                
            }]]

        local photo = catalog:getTargetPhoto() -- retrieve the active photo // returns nil if no photo selected

        --check if a photo was selected
        if not photo then
            return nil, dialog.message("Please select a photo", "No photo seems to be selected. Please select a photo and try again")
        end

        local photoID = photo.localIdentifier

        _G["floatingDialog"] = {}
        _G.waitReturn = false


        LrTasks.startAsyncTask( function()

                local filename = photo:getFormattedMetadata ("fileName")

        --[[local dialog = dialog.presentFloatingDialog(_PLUGIN,
            {
                title = "Develop History Steps for: " .. filename ,
                contents = contents,
--                save_frame = "plgDevelopHistoryTimestamps",
                onShow = function(t)
                    _G.floatingDialog = t
                end
            }
        )]]


                local sql = 'SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE \'%' .. photoID .. '%\' ORDER BY dateCreated DESC;'


                local outputContents = getFromDB(sql)
                _G.dbOutput = nil

        --        local waited = waitForGlobal("waitReturn")

                -- initialize variables
                local splitStep = {}
                local historySteps = ""

                stepDates = split(outputContents,"\n")

                historySteps = #stepDates .. " develop history steps found\n"
                for key,value in ipairs(stepDates) do

                    splitStep[key] = split(value,"|")
                    stepName = splitStep[key][1]
                    dateCreated = tonumber(splitStep[key][2]) + 978307200

                    dateCreated = os.date("%x %X",dateCreated)

                    -- check if step may already include a date, usually included in paranthesis after the step name
                    local dateExists = string.find(stepName,"%(") --returns nil if not found

                    if not dateExists then
                        historySteps = historySteps .. stepName .. " (" .. dateCreated .. ")\n"
                    else
                        historySteps = historySteps .. stepName .. "\n" --omit the date if name includes it 
                    end
                end

                if outputContents == "" then
                    return nil, dialog.message("Hmm...", "Output file looks empty. ", "critical")
                end
                
                
                local view = LrView.osFactory()
--                local props = 
                local contents = 
                    view:row{
                        bind_to_object = props,	
                        view:column { 				
                                view:edit_field { value = historySteps, width_in_chars = 40, height_in_lines = #stepDates },
                --				view:edit_field { value = catalog:getPath(), width_in_chars = 80, height_in_lines = 1 },
                --				view:edit_field { value = cmd, width_in_chars = 80, height_in_lines = 1 },
                --				view:edit_field { value = sqlite, width_in_chars = 80, height_in_lines = 1 },
                        },
                    }

                local dialog = dialog.presentFloatingDialog(_PLUGIN,
                    {
                        title = "Develop History Steps for: " .. filename ,
                        contents = contents,
        --                save_frame = "plgDevelopHistoryTimestamps",
                        onShow = function(t)
                            _G.floatingDialog = t
                        end
                    }
                )

          end
        )

--[[end
)]]

-- .\sqlite3.exe "E:\Pictures\Lightroom Catalog\AIG Photography 2021.lrcat" "SELECT name,dateCreated FROM main.Adobe_libraryImageDevelopHistoryStep WHERE image LIKE'%45099944%';" > sql.txt


--    dialog.message("Hello World", "Please select a photo")

-- SUPPORTING FUNCTIONS


