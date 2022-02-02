({
    doInit : function(component, event, helper) {
        helper.stateListHelper(component, event, helper);
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
                alert("File size must be less than 2 MB");
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
        // helper.validate(component, event, helper);
    },
    validateFile: function(component, event, helper){
        console.log('validateFile');
        component.find('fuploader').setCustomValidity('');
        component.find('fuploader').reportValidity();
    },
    rerenderForm: function(component, event, helper) { 
        var inputId = event.getSource().get("v.name")+"Input";
        var allInputs = component.find("subDivisionForm");
        allInputs.forEach(function(eachInput){
            console.log('name---'+eachInput.get("v.name"));
            console.log('inputId---'+inputId);
            if(eachInput.get("v.name") == inputId){
                eachInput.reportValidity();
            }
        }); 
    },
    saveForm: function(component, event, helper) {   
        component.set('v.showspinner', true);
        var allValid = helper.validateForm(component, event, helper);
        if(allValid){
            console.log('saveform');
            helper.saveForm(component, event, helper); 
        }else{
            console.log('saveelseform');
            component.set('v.showspinner', false);
        } 
    },
    returnBackPage: function(component, event, helper) { 
      var id = component.get("v.subscription");   
     window.open("/customers/apex/Communities_SubdivisionBuildingForm?id="+id.Name,'_blank');

    },
    
})