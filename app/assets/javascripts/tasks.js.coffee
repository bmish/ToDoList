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
		list_id = $(event.target).data('list_id')

		$('.listTitleHeaderText[data-list_id='+list_id+']').hide()
		$('.listTitleHeaderTextField[data-list_id='+list_id+']').show()
		$('.listTitleHeaderTextField[data-list_id='+list_id+']').focus()
		
	listSectionHeaderTextOnClick = (event) ->
		priority = $(event.target).data('priority')
		category_id = $(event.target).data('category_id')

		if priority != undefined && category_id == undefined
			$('.listSectionItems[data-priority='+priority+']:not([data-category_id])').slideToggle()

		if priority != undefined && category_id != undefined
			$('.listSectionItems[data-priority='+priority+'][data-category_id='+category_id+']').slideToggle()

	listTitleHeaderTextFieldOnFocusLost = (event) ->
		list_id = $(event.target).data('list_id')

		oldTitle = $('.listTitleHeaderText[data-list_id='+list_id+']').text()
		newTitle = $('.listTitleHeaderTextField[data-list_id='+list_id+']').val()
		
		if oldTitle != newTitle
			$('.listTitleHeaderText[data-list_id='+list_id+']').text(newTitle)
			document.title = newTitle
			$('#edit_list_'+list_id).submit()
		
		$('.listTitleHeaderTextField[data-list_id='+list_id+']').hide()
		$('.listTitleHeaderText[data-list_id='+list_id+']').show()
		
	listTitleHeaderTextFieldOnKeypress = (event) ->
		if event.which == 13 # Enter key.
			listTitleHeaderTextFieldOnFocusLost(event)

	formClearCompletedOnSubmit = (event) ->
		$('.listItemTaskCompleted').remove()
		removeEmptyListSections()

	$('.taskCheckbox').change(taskCheckboxOnChange)
	$('.taskDelete[data-remote]').on('ajax:complete', taskDeleteOnAJAXComplete)
	$('.listTitleHeaderText').click(listTitleHeaderTextOnClick)
	$('.listSectionHeader').click(listSectionHeaderTextOnClick)
	$('.listTitleHeaderTextField').focusout(listTitleHeaderTextFieldOnFocusLost)
	$('.listTitleHeaderTextField').keypress(listTitleHeaderTextFieldOnKeypress)
	$('#task_due_tmp').datepicker({altField: '#task_due', altFormat: 'yy-mm-dd'}) # Use altField because Rails expects a certain format when creating the new task.
	$('#formClearCompleted').submit(formClearCompletedOnSubmit)

	removeEmptyListSections = ->
		$('.listSectionItems:not(:has(*))').parent().remove() # Remove sections that have no children.
		$('.listSectionItems:not(:has(*))').parent().remove() # Repeat in case a higher-level section just had all its children removed and now needs to be removed itself.
