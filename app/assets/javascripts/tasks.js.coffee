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
	  
	$('.taskCheckbox').change(taskCheckboxOnChange)