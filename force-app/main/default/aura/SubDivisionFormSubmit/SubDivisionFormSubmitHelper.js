({
    stateListHelper : function(component, event, helper) {
        console.log('$$$$');
        var action = component.get("c.getStateValues");
        action.setCallback(this, function(response){
            var state = response.getState();    
            console.log(state);
            if(state === "SUCCESS"){
                var results = response.getReturnValue();
                var stateOptions=[];
                results.forEach(function(state){
                    stateOptions.push({
                        "label": state.State__c,
                        "value": state.State__c
                    });
                });
                component.set("v.stateListOptions", stateOptions);
            }
        });
        $A.enqueueAction(action);
    },
    initWrapper : function(component, event, helper) {
        var action = component.get("c.initMethod");
        action.setCallback(this, function(response){
            var state = response.getState();   
            if(state === "SUCCESS"){
                component.set("v.caseDescJson", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getSubscriptionInfo : function(component) {
        var action = component.get("c.fetchSubscription");
        action.setParams({
            subId: component.get("v.subscriptionId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.subscription', response.getReturnValue());
            }
            else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }
        });
        $A.enqueueAction(action);   	
    },
    saveForm: function(component, event, helper) {
        console.log('$$$$saveform');   
        var action = component.get("c.saveSubdivisionBuildingForm");
        //alert('----'+component.get("v.caseDescJson"));
        action.setParams({
            subId: component.get("v.subscriptionId"),
            caseDescJson: component.get("v.caseDescJson"),
            subDivRbuilding: component.get("v.subDivisionOrBuilding"),
            subdivRbuildName: component.get("v.caseDescJson.Subdivisionname")?component.get("v.caseDescJson.Subdivisionname"):component.get("v.caseDescJson.BuildingName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('$$$$state'); 
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
        var action = component.get("c.attachFile");
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
    
    validateForm : function(component, event, reportValidity) 
    {
        var allValid = component.find('subDivisionForm').reduce(function (validSoFar, inputCmp) {
            if(reportValidity){
                inputCmp.reportValidity();
            }
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        var atleastOneChecked = false;
        var allcheckboxs = component.find("requiredCheckbox");
        allcheckboxs.forEach(function(eachbox){
            if(eachbox.get("v.checked")){
                atleastOneChecked = true;
            }
        });
       
        return allValid && atleastOneChecked;;
    },
    handleCheckReadyForSubmit: function(component, event, helper) { 
        var allValid = helper.validateForm(component, event, false);
        if(allValid){
            component.find("submitBtn").set("v.disabled", false);
        }else{
            component.find("submitBtn").set("v.disabled", true);
        }
    },
    removeValidateMsgs : function(component, event, helper) 
    {
        var allInputs = component.find("subDivisionForm");
        allInputs.forEach(function(eachInput){
            if(eachInput.checkValidity()){
                eachInput.reportValidity();
                
            }
            if(eachInput.get("v.disabled") == true){
                eachInput.set("v.value", '');
            }
        });       
        
    },        
})