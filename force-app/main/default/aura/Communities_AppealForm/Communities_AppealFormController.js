({
    doInit : function(component, event, helper) {
        helper.appealFormData(component, event, helper);                       
    },
    
    saveAppealForm: function(component, event, helper) {        
        var reason = component.find('reason');

        var flag = true;
        //if (component.get('v.files').length > 0) {
            if(flag && reason.checkValidity()){
                component.set('v.showspinner', true);
                helper.saveForm(component, event, helper);   
            }else{
                reason.reportValidity();
            }
       /* } else {
            flag = false;
            alert('Please Select a Valid File');            
        }   */    
        
    },
    
    validateField : function(component, event, helper){
        helper.validate(component, event, helper);
       	
    },
    
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            var fileInput = component.find("fuploader").get("v.files");
            var file = fileInput[0];
            if(file.size > 2097152) { //2 * 1024 * 1024
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
        }/*else{
            if(component.get('v.files').length == undefined || component.get('v.files').length == 0){
               component.find('fuploader').setCustomValidity('Please upload a file');
               component.find('fuploader').reportValidity(); 
            }
        }*/
        helper.validate(component, event, helper);
    },
    
    validateFile: function(component, event, helper){
        console.log('validateFile');
        component.find('fuploader').setCustomValidity('');
       /*if(component.get('v.files').length == 0){
            component.find('fuploader').setCustomValidity('Please upload a file');
        } */
        component.find('fuploader').reportValidity();
    }
    
})