({
    doInit : function(component, event, helper) {
        helper.getTemplateDetails(component, event, helper);
        helper.getEmailNotes(component, event, helper);
        helper.getStatusValues(component, event, helper);
        var today = new Date();
        component.set('v.minDate', today.toISOString().split('T')[0]);
    },
    
    handleSuccess : function(component, event, helper) {
        component.set('v.currentTab', 'All');
        helper.getEmailNotes(component, event, helper);
        component.set('v.dueDate', null);
        component.set('v.priority', null);
        component.set('v.note', null);
    },
    
    handleSubmit : function(component, event, helper) {
        var hasError = false;
        var note = component.get('v.note');
        var dueDate = component.get('v.dueDate');
        var priority = component.get('v.priority');
        
        var noteField = component.find('noteField');
        var dueDateField = component.find('dueDateField');
        var priorityField = component.find('priorityField');
        component.set('v.dateValidationErrorMsg', '');
        noteField.set('v.valid', true);
        component.set('v.dateValidationError', false);
        dueDateField.setCustomValidity('');
        priorityField.setCustomValidity('');
        
        if(note == undefined || note == null || note == ''){
            noteField.set('v.valid', false);
            hasError = true
        }
        if(!dueDateField.checkValidity()){
            hasError = true;
        }
        else if(dueDate == undefined || dueDate == null || dueDate == ''){
            dueDateField.setCustomValidity('Enter a date');
            hasError = true
        }
        if(priority == undefined || priority == null || priority == ''){
            priorityField.setCustomValidity('Select a value');            
            hasError = true
        }
        dueDateField.reportValidity();
        priorityField.reportValidity();
        if(hasError == true){
            event.preventDefault();
        }
        
    },
    
    closePopup : function(component, event, helper){
        component.find("overlayLib").notifyClose();
    }
})