local dialog = import 'LrDialogs'
local LrHttp = import "LrHttp"

PluginManager = {}

function PluginManager.sectionsForTopOfDialog( viewFactory , _ )
	return {
            -- Section for the top of the dialog.
            {
                title = "Plugin Info",
                viewFactory:row {
                    spacing = viewFactory:control_spacing(),

                    viewFactory:static_text {
                        title = "Click the button to learn more about this plugin on GitHuib",
                        fill_horizontal = 1,
                    }, -- text

                    viewFactory:push_button {
                        width = 150,
                        title = "Visit GitHub",
                        enabled = true,
                        action = function()
                            LrHttp.openUrlInBrowser(_G.pluginURL)
                        end,
                    }, -- button
                }, -- row
            }, -- section
			{
				title = "Reset Dialogs",
				viewFactory:row {
					spacing = viewFactory:control_spacing(),

					viewFactory:static_text {
						title = "Reset dialogs with 'Do not show' option",
						fill_horizontal = 1,
					}, -- text

					viewFactory:push_button {
						width = 150,
						title = "Reset Do Not Show Dialogs",
						enabled = true,
						action = function()
							dialog.resetDoNotShowFlag()
                            dialog.message('The "Do not show" dialogs have been reset')
						end,
					}, -- button
				}, -- row
            } -- section
        } --return
end