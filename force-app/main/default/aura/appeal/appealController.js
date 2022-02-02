({
	doInit : function(component, event, helper) {
		helper.appealFormData(component, event, helper);                       
	},
    
    saveAppealForm: function(component, event, helper) {
        var reason = component.find('reason');
        var phone = component.find('phone');
        var email = component.find('email');
        var flag = true;
        if (component.find("fuploader").get("v.files") != null && component.find("fuploader").get("v.files").length > 0) {
            if(flag && reason.checkValidity() && phone.checkValidity() && email.checkValidity()){
                helper.saveForm(component, event, helper);    
            }else{
                reason.reportValidity();
                email.reportValidity();
                phone.reportValidity();
            }
        } else {
            flag = false;
            alert('Please Select a Valid File');
        }
        
        
        
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
                files.push(file);
                component.set('v.files', files);
            }
            component.find("fuploader").set("v.files", null);
        }
    },
     
})