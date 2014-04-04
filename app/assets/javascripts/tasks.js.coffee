# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	taskCheckboxOnChange = (event) ->
		taskID = $(event.target).data('id')
		if event.target.checked
			$('#listItem_'+taskID).addClass('listItemTaskCompleted')
			$('#title_'+taskID).addClass('taskCompleted')
			$('#category_'+taskID).addClass('taskCompleted')
			$('#priority_'+taskID).addClass('taskCompleted')
			$('#datecreated_'+taskID).addClass('taskCompleted')
		else
			$('#listItem_'+taskID).removeClass('listItemTaskCompleted')
			$('#title_'+taskID).removeClass('taskCompleted')
			$('#category_'+taskID).removeClass('taskCompleted')
			$('#priority_'+taskID).removeClass('taskCompleted')
			$('#datecreated_'+taskID).removeClass('taskCompleted')

	taskDeleteOnAJAXComplete = (event) ->
		taskID = $(event.target).data('id')
		$('#listItem_'+taskID).remove()
		removeEmptyListSections()
		
	listTitleHeaderTextOnClick = (event) ->
		$('#listTitleHeader').hide()
		$('#list_title').show()
		$('#list_title').focus()
		
	listSectionHeaderTextOnClick = (event) ->
		priority = $(event.target).data('priority')
		category_id = $(event.target).data('category_id')

		if priority != undefined && category_id == undefined
			$('.listSectionItems[data-priority='+priority+']:not([data-category_id])').slideToggle()

		if priority != undefined && category_id != undefined
			$('.listSectionItems[data-priority='+priority+'][data-category_id='+category_id+']').slideToggle()

	listTitleInputOnFocusLost = (event) ->
		newTitle = $('#list_title').val()
		$('#listTitleHeader').text(newTitle)
		document.title = newTitle
		
		$('#listTitle form').submit()
		
		$('#list_title').hide()
		$('#listTitleHeader').show()
		
	listTitleInputOnKeypress = (event) ->
		if event.which == 13 # Enter key.
			listTitleInputOnFocusLost(event)

	formClearCompletedOnSubmit = (event) ->
		$('.listItemTaskCompleted').remove()
		removeEmptyListSections()

	$('.taskCheckbox').change(taskCheckboxOnChange)
	$('.taskDelete[data-remote]').on('ajax:complete', taskDeleteOnAJAXComplete)
	$('#listTitleHeader').click(listTitleHeaderTextOnClick)
	$('.listSectionHeader').click(listSectionHeaderTextOnClick)
	$('#list_title').focusout(listTitleInputOnFocusLost)
	$('#list_title').keypress(listTitleInputOnKeypress)
	$('#task_due_tmp').datepicker({altField: '#task_due', altFormat: 'yy-mm-dd'}) # Use altField because Rails expects a certain format when creating the new task.
	$('#formClearCompleted').submit(formClearCompletedOnSubmit)

	removeEmptyListSections = ->
		$('.listSectionItems:not(:has(*))').parent().remove() # Remove sections that have no children.
		$('.listSectionItems:not(:has(*))').parent().remove() # Repeat in case a higher-level section just had all its children removed and now needs to be removed itself.
