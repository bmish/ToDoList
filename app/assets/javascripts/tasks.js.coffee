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
			$('#datestart_'+taskID).addClass('taskCompleted')
			$('#datedue_'+taskID).addClass('taskCompleted')
			$('#blocked_'+taskID).addClass('taskCompleted')
			$('#location_'+taskID).addClass('taskCompleted')
			$('#frequency_'+taskID).addClass('taskCompleted')
			$('#dependee_'+taskID).addClass('taskCompleted')
		else
			$('#listItem_'+taskID).removeClass('listItemTaskCompleted')
			$('#title_'+taskID).removeClass('taskCompleted')
			$('#category_'+taskID).removeClass('taskCompleted')
			$('#priority_'+taskID).removeClass('taskCompleted')
			$('#datecreated_'+taskID).removeClass('taskCompleted')
			$('#datestart_'+taskID).removeClass('taskCompleted')
			$('#datedue_'+taskID).removeClass('taskCompleted')
			$('#blocked_'+taskID).removeClass('taskCompleted')
			$('#location_'+taskID).removeClass('taskCompleted')
			$('#frequency_'+taskID).removeClass('taskCompleted')
			$('#dependee_'+taskID).removeClass('taskCompleted')

	taskDeleteOnAJAXComplete = (event) ->
		taskID = $(event.target).data('id')
		$('#listItem_'+taskID).remove()
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

	$('.taskCheckbox').change(taskCheckboxOnChange)
	$('.taskDelete[data-remote]').on('ajax:complete', taskDeleteOnAJAXComplete)
	$('#listTitleHeaderNewLink[data-remote]').on('ajax:complete', listTitleHeaderNewLinkOnAJAXComplete)
	$('.listSectionHeader').click(listSectionHeaderTextOnClick)
	$('#formClearCompleted').submit(formClearCompletedOnSubmit)

	# Use altField because Rails expects a certain format when creating the new task.
	$('#task_start_tmp').datepicker({altField: '#task_start', altFormat: 'yy-mm-dd'})
	$('#task_due_tmp').datepicker({altField: '#task_due', altFormat: 'yy-mm-dd'})

	removeEmptyListSections = ->
		$('.listSectionItems:not(:has(*))').parent().remove() # Remove sections that have no children.
		$('.listSectionItems:not(:has(*))').parent().remove() # Repeat in case a higher-level section just had all its children removed and now needs to be removed itself.
