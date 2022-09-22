local dialog = import 'LrDialogs'

local function sectionsForTopOfDialog( viewFactory , _ )
	return {
            -- Section for the top of the dialog.
			{
				title = "Reset Dialogs",
				viewFactory:row {
					spacing = viewFactory:control_spacing(),

					viewFactory:static_text {
						title = "Reset dialogs with 'Do not show' option",
						fill_horizontal = 1,
					},

					viewFactory:push_button {
						width = 150,
						title = "Reset Do Not Show Dialogs",
						enabled = true,
						action = function()
							dialog.resetDoNotShowFlag()
                            dialog.message('The "Do not show" dialogs have been reset')
						end,
					},
				},
            }
        }
end

return {

	sectionsForTopOfDialog = sectionsForTopOfDialog,

}