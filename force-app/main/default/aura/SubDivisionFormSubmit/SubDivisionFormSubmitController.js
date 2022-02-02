({
    doInit : function(component, event, helper) {
        helper.stateListHelper(component, event, helper);
        helper.initWrapper(component, event, helper);
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("Id");
        component.set("v.subscriptionId", subId);
        
        helper.getSubscriptionInfo(component);
    },
    validateField : function(component, event, helper){
        helper.validate(component, event, helper);
        
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            var fileInput = component.find("fuploader").get("v.files");
            var file = fileInput[0];
            if(file.size > 4194304) { //4 * 1024 * 1024
                alert("File size must be less than 4 MB");
            }
            else {
                let files = component.get('v.files');
                var fileInput = component.find("fuploader").get("v.files");
                var file = fileInput[0];
                if(file){
                    files.push(file);
                }
                component.set('v.files', files);
                component.find('fuploader').setCustomValidity('');
                component.find('fuploader').reportValidity();
            }
            component.find("fuploader").set("v.files", null);
        }
    },
    validateFile: function(component, event, helper){
        console.log('validateFile');
        component.find('fuploader').setCustomValidity('');
        component.find('fuploader').reportValidity();
    },
    rerenderForm: function(component, event, helper) {
        setTimeout(function() {
            helper.removeValidateMsgs(component, event, helper); 
            helper.handleCheckReadyForSubmit(component, event, helper);
        }, 10);
    },
    saveForm: function(component, event, helper) {   
        component.set('v.showspinner', true);
        var selectedvalue = component.get("v.selected");
        var allValid = helper.validateForm(component, event, true);
        if(allValid){
            console.log('saveform');
            
            if(selectedvalue){
                component.set("v.showSuccess", true);
            }
            console.log('selectedvalue'+selectedvalue);
            console.log('thank');
            helper.saveForm(component, event, helper); 
            
        }else{
            console.log('saveelseform');
            component.set('v.showspinner', false);
        } 
    },
    returnBackPage: function(component, event, helper) { 
        var subId = component.get("v.subscriptionId");   
        window.open("/customers/apex/SubdivisionBuildingForm?id="+subId,'_self');
    },
    checkReadyForSubmit: function(component, event, helper) { 
        helper.handleCheckReadyForSubmit(component, event, helper);
    },
    
})