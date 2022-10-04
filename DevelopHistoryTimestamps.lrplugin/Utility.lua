--[[----------------------------------------------------------------------------

Utility functions

------------------------------------------------------------------------------]]

local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'

-- ref: https://stackoverflow.com/a/40180465/10792097

-- split("a,b,c", ",") => {"a", "b", "c"}

function split(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end


--Wait for a global variable that may not have been initialized yet. If it is nil, wait.

-- Times out after 'timeout' seconds (or 30s, if only one argument is passed)

-- Returns the number of seconds which were waited (for debug/monitoring purposes) or false

-- if the timeout was reached and the variable name still didn't exist.

-- ref: https://community.adobe.com/t5/lightroom-classic-discussions/many-sdk-methods-yield-preventing-robust-plugins/m-p/8432135#M164219

function waitForGlobal(globalName, timeout)

    local sleepTimer = 0;

    local LrTasks = import 'LrTasks';

    local timeout = (timeout ~= nil) and timeout or 30;

    while (_G[globalName] == nil) and (sleepTimer < timeout) do

        LrTasks.sleep(1);

        sleepTimer = sleepTimer + 1;

    end

    return _G[globalName] ~= nil and sleepTimer or false

end


--  Function to convert the dateCreated timestamp from Lr catalog DB to date

function timeStampToDate(dateCreated,dateFormat)
    
    dateCreated = tonumber(dateCreated) + 978307200
    
    return dateFormat ~= nil and os.date(dateFormat,dateCreated) or os.date("%x %I\:%M\:%S %p",dateCreated)
    
    
end

-- Function to take an ISO-8601 formatted date (e.g.: "2022-09-20T03:53:32.765Z") as parameter with an option date format string and return either a formatted date or a timestamp in seconds. 

function fromISODate(stringDate, format)  
    
    local inYear, inMonth, inDay, inHour, inMinute, inSecond, inZone = string.match(stringDate, '^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)(.-)$')

    --	local zHours, zMinutes = string.match(inZone, '^(.-):(%d%d)$')
	
    --        dialog.message("Year: " .. inYear .. " Month: " .. inMonth .. " Day: " .. inDay .. " Hour: " .. inHour .. " Min: " .. inMinute .. " Sec: " .. inSecond)

	local time = os.time({year=inYear, month=inMonth, day=inDay, hour=inHour, min=inMinute, sec=inSecond, isdst=false})
    
    return format ~= nil and os.date(format,time) or time
    
    
end

-- utility function for displaying a simple dialog with an edit field for showing longer strings
function showDevDialog( data, location )
   
    local bigFieldData, smallFieldData = ""
    
    if location ~= nil then
        if location == 1 then
            bigFieldData = data
        elseif location == 2 then
            smallFieldData = data
        end
    else
        smallFieldData = data
    end
    
    local f = LrView.osFactory()
	local c = 
		f:row{
		bind_to_object = props,	
			f:column { 				
				f:edit_field { value = bigFieldData, width_in_chars = 80, height_in_lines = 10 },
                f:edit_field { value = smallFieldData, width_in_chars = 80, height_in_lines = 1 },
			},
		} 
	LrDialogs.presentModalDialog(
		{
			title = "Dev Data" ,
			contents = c,
		}
	)
end