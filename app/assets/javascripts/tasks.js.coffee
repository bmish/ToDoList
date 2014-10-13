# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	taskCheckboxOnChange = (event) ->
		taskID = $(event.target).data('id')
		if event.target.checked
			$('.listItem[data-task_id='+taskID+']').addClass('listItemTaskCompleted')
			$('.listItemColumn[data-task_id='+taskID+']').addClass('taskCompleted')
		else
			$('.listItem[data-task_id='+taskID+']').removeClass('listItemTaskCompleted')
			$('.listItemColumn[data-task_id='+taskID+']').removeClass('taskCompleted')

	taskDeleteOnAJAXComplete = (event) ->
		taskID = $(event.target).data('id')
		$('.listItem[data-task_id='+taskID+']').remove()
		removeEmptyListSections()

	listTitleHeaderNewLinkOnAJAXComplete = (e, data, status) ->
		json = JSON.parse(data.responseText)
		if json
			$('#listTitleHeaders').append('<div class="listTitleHeader"><a class="listTitleHeaderText" href="/lists/'+json.list.id+'">'+json.list.title+'</a></div>'); # TODO: Avoid hard-coding list path?

	listSectionHeaderTextOnClick = (event) ->
		priority = $(event.target).data('priority')
		category_id = $(event.target).data('category_id')

		if priority != undefined && category_id == undefined
			$('.listSectionItems[data-priority='+priority+']:not([data-category_id])').slideToggle()

		if priority != undefined && category_id != undefined
			$('.listSectionItems[data-priority='+priority+'][data-category_id='+category_id+']').slideToggle()

	formClearCompletedOnSubmit = (event) ->
		$('.listItemTaskCompleted').remove()
		removeEmptyListSections()

	newTaskButtonOnClick = (event) ->
		$('#newTaskDialog').dialog('open')

	newTaskDialogOnSave = (event) ->
		$('#listNewFormSubmit').click()

	formNewTaskOnSubmit = (event) ->
		$('#newTaskDialog').dialog('close')

	$('.taskCheckbox').change(taskCheckboxOnChange)
	$('.taskDelete[data-remote]').on('ajax:complete', taskDeleteOnAJAXComplete)
	$('#listTitleHeaderNewLink[data-remote]').on('ajax:complete', listTitleHeaderNewLinkOnAJAXComplete)
	$('.listSectionHeader').click(listSectionHeaderTextOnClick)
	$('#formClearCompleted').submit(formClearCompletedOnSubmit)
	$('#newTaskButton').click(newTaskButtonOnClick)
	$('#newTaskDialog').dialog({ autoOpen: false, buttons: [{text: 'Save', click: newTaskDialogOnSave}] })
	$('#formNewTask').submit(formNewTaskOnSubmit)

	# Use altField because Rails expects a certain format when creating the new task.
	$('#task_start_tmp').datepicker({altField: '#task_start', altFormat: 'yy-mm-dd'})
	$('#task_due_tmp').datepicker({altField: '#task_due', altFormat: 'yy-mm-dd'})

	removeEmptyListSections = ->
		$('.listSectionItems:not(:has(*))').parent().remove() # Remove sections that have no children.
		$('.listSectionItems:not(:has(*))').parent().remove() # Repeat in case a higher-level section just had all its children removed and now needs to be removed itself.
