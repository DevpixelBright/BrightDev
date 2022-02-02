({  
    appealFormData : function(component, event, helper) {
        var action = component.get("c.getDetails");
        var vid = window.location.search;
        vid = vid.split('vid=')[1];
        action.setParams({
            violationId: vid
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getReturnValue());
            if(state === "SUCCESS") {
                var objValue = response.getReturnValue();
                component.set("v.appealFormObj", objValue); 
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                component.set('v.today', today);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveForm: function(component, event, helper) {
        var appealForm = component.get("v.appealFormObj");
        var action = component.get("c.saveCase");
        action.setParams({
            "fine": appealForm,
            "reason": component.get('v.Reason_For_Appeal')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('--state--'+response.getReturnValue());
                component.set('v.caseId', response.getReturnValue());
                for(var file of component.get('v.files')){
                	this.getBase64(component, file);    
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Unfortunately, there was a problem updating the record."
                });
                console.log("error msg-: ", errors[0].message);
            }           
        });
        $A.enqueueAction(action)
    },
    
    getBase64: function (component, file) {
        var reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = function () {
            let temp = this.result;
            temp = temp.split('base64,')[1];
			console.log('temp', temp);
            var action = component.get("c.attachFile2");
            action.setParams({
                parentId: component.get("v.caseId"),
                fileName: file.name,
                contentType: file.type,
                base64BlobValue: temp
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    console.log('Successfully file uploaded');
                    component.set('v.showSuccess', true);
                } else if(state === "ERROR") {
                    var errors = response.getError();
                    
                    console.log("error msg-: ", errors[0].message);
                }           
            });
            $A.enqueueAction(action)
        };
        reader.onerror = function (error) {
            console.log('Error: ', error);
        };
    }
})