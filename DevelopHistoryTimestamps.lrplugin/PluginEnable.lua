local dialog = import 'LrDialogs'

-- show message when plugin enabled (also shown when plugin first added in Plugin Manager)

local enableMessage = "The plugin adds three new options:\n\n"

enableMessage = enableMessage .. "- View Develop History Timestamps\n- View Last Develop Time\n- View Edit Time"

enableMessage = enableMessage .. "\n\nTo use, select a photo and then choose one of options above from:\n\n"

enableMessage = enableMessage .. "File > Plug-in Extras menu, while in Library module\n"
enableMessage = enableMessage .. "Library > Plug-in Extras menu, while in Develop module\n\n"

enableMessage = enableMessage .. "To learn more about each feature click the Plugin Info button in the Plugin Manager.\n\n"

dialog.messageWithDoNotShow({
        message = "Develop History Timestamps plugin enabled.",
        info = enableMessage,
        actionPrefKey = "plgDevelopHistoryTimestampsEnableMsg"
    })