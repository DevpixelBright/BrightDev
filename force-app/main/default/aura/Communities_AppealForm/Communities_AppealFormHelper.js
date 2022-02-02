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
        var action = component.get("c.saveAppealCase");
        action.setParams({
            "fine": appealForm,
            "reason": component.get('v.Reason_For_Appeal')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('--state--'+response.getReturnValue());
                component.set('v.caseId', response.getReturnValue());
                if(component.get('v.files') && component.get('v.files').length >0){
                for(var file of component.get('v.files')){
                	this.getBase64(component, file);    
                }
                }else{
                   component.set('v.showspinner', false);  
                   component.set('v.showSuccess', true);
                }
                    
            } else if(state === "ERROR") {
                component.set('v.showspinner', false);
                component.set('v.hasError', true);
                window.scrollTo(0,0); 
                var errors = response.getError();
                console.log("error msg-: ", errors[0].message);
            }           
        });
        $A.enqueueAction(action)
    },
    
    upload: function(component, file, fileContents) {
        var action = component.get("c.attachFile2");
        action.setParams({
            parentId: component.get("v.caseId"),
            fileName: file.name,
            contentType: file.type,
            base64BlobValue: fileContents
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
            component.set('v.showspinner', false);
        });
        $A.enqueueAction(action);
    },
    
    getBase64: function (component, file) {
        var fr = new FileReader();
        console.log('getBase64 start ???');
        var self = this;
       	fr.onload = function() {
            console.log('getBase64 calback ???');
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            
            fileContents = fileContents.substring(dataStart);
            //timeout is used to avoid long running chained apex calls
            window.setTimeout(
                $A.getCallback(function() {
                    self.upload(component, file, fileContents);
                }), 50
            );
        };
        fr.readAsDataURL(file);
    },
    
    validate: function(component, event, helper){
        var reason = component.find('reason');
       // if (component.get('v.files').length > 0) {
            if(reason.checkValidity()){
                component.set('v.disabled',false);
            }else{
                component.set('v.disabled',true);
            }
       /* } else {
            component.set('v.disabled',true);            
        } */
    }
})