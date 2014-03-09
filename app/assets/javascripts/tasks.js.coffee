# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	taskCheckboxOnChange = (event) ->
		taskID = $(event.target).data('id')
		if event.target.checked
			$('#title_'+taskID).addClass('taskCompleted')
			$('#category_'+taskID).addClass('taskCompleted')
			$('#priority_'+taskID).addClass('taskCompleted')
		else
			$('#title_'+taskID).removeClass('taskCompleted')
			$('#category_'+taskID).removeClass('taskCompleted')
			$('#priority_'+taskID).removeClass('taskCompleted')

	taskDeleteOnAJAXComplete = (event) ->
		taskID = $(event.target).data('id')
		$('#listItem_'+taskID).remove()
		
	listTitleHeaderTextOnClick = (event) ->
		$('#listTitleHeader').hide()
		$('#list_title').show()
		$('#list_title').focus()
		
	listTitleInputOnFocusLost = (event) ->
		$('#listTitleHeader').text($('#list_title').val())
		$('#listTitle form').submit()
		
		$('#list_title').hide()
		$('#listTitleHeader').show()
		
	listTitleInputOnKeypress = (event) ->
		if event.which == 13 # Enter key.
			listTitleInputOnFocusLost(event)

	$('.taskCheckbox').change(taskCheckboxOnChange)
	$('.taskDelete[data-remote]').on('ajax:complete', taskDeleteOnAJAXComplete)
	$('#listTitleHeader').click(listTitleHeaderTextOnClick)
	$('#list_title').focusout(listTitleInputOnFocusLost)
	$('#list_title').keypress(listTitleInputOnKeypress)