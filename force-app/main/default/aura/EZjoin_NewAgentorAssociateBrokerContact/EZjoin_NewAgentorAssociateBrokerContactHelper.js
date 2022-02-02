({
    initializeAppData: function(component) {
        var appConfig = JSON.parse(JSON.stringify(component.get('v.appConfig')));
        var appData = JSON.parse(JSON.stringify(component.get('v.appData')));
        var currentConfig = null;
        
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationContactInfo') {
                appConfig[i].status = 'In Progress';
                currentConfig = appConfig[i];
                break;
            }
        } 

        currentConfig.status = 'In Progress';
        component.set('v.currentConfig', currentConfig);
        console.log('***appData:', appData);
        if(appData.contact == undefined) {
            appData['contact'] = {firstName: '', lastName: '', middleName: '', suffix: '', salutation: '', nickName: '', email: '', confirmEmail: '', phone: null, mobile: null};
        }
        
		component.set('v.appData', appData);
        component.set('v.appConfig', appConfig);
    },
    
    getSalutationValues : function(component) {
        var appData = component.get('v.appData');
        if(appData.salutations != undefined) {
            component.set('v.salutations', appData.salutations);
        	return;
        }
        
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'objectName' : 'MRIS_Application__c',
            'fieldName': 'Salutation__c'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('*** Salutations action');
                var response = response.getReturnValue();
                component.set('v.salutations', response);
                
                if(appData.salutations == undefined) {
                    appData['salutations'] = response;
                }
                component.set('v.appData', appData);
            } 
        });
        $A.enqueueAction(action);         
    },
    
    getSuffixValues : function(component) {
        var appData = component.get('v.appData');
        if(appData.suffixes != undefined) {
            component.set('v.suffixes', appData.suffixes);
        	return;
        }
        
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'objectName' : 'MRIS_Application__c',
            'fieldName': 'Suffix__c'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                component.set('v.suffixes', response);
                var appData = component.get('v.appData');
                if(appData.suffixes == undefined) {
                    appData['suffixes'] = response;
                }
				component.set('v.appData', appData);                
            } 
        });
        $A.enqueueAction(action);         
    },    
    
    validateSubmission: function(component, event) {
        component.set('v.errorMsg', '');

        var requiredFields = ['Salutation', 'FirstName', 'LastName', 'Email', 'ConfirmEmail', 'Phone'];
        var isValid = true;
        for(var i=0; i<requiredFields.length; i++) {
        	var field = component.find(requiredFields[i]); 
            if(!field.get("v.validity").valid) {
                field.showHelpMessageIfInvalid();              
                isValid = false;
            }
        }

        if(isValid) {
        	var mobileField = component.find('Mobile'); 
            if(!mobileField.get("v.validity").valid) {
                mobileField.showHelpMessageIfInvalid();              
                isValid = false;
            }
        }
        
        if(isValid) {        
            this.handleSubmission(component, event);       
        }
        else {
            component.set('v.errorMsg', 'Please review and fill in the required fields.');
        }        
    },
    
	handleSubmission : function(component, event) {
        var currentConfig = component.get('v.currentConfig');
        currentConfig.status = 'Completed';
        
        var appConfig = component.get('v.appConfig');
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationContactInfo') {
                appConfig[i] = currentConfig;
                break;
            }
        }
        component.set('v.appConfig', appConfig);
        this.fireApplicationEvent(component);
    },
    
    fireApplicationEvent: function(component) {
        var applicationEvent  = $A.get("e.c:EZJoin_NewApplicationAppConfigEvent");
        applicationEvent.setParams({
            'currentCmp': 'EZJoin_NewApplicationContactInfo',
            'applicationConfig': component.get('v.appConfig'),
            'applicationData': component.get('v.appData')
        });
        applicationEvent .fire();        
    },
    
    checkEmailsMatch: function(component, event) {
        if(component.find('Email').get('v.value') != '' && component.find('ConfirmEmail').get('v.value') != '' && component.find('Email').get('v.value') != component.find('ConfirmEmail').get('v.value')) {
            component.find('ConfirmEmail').setCustomValidity('Emails did not match');
            component.find('ConfirmEmail').reportValidity();
        }
        else {
            component.find('ConfirmEmail').setCustomValidity('');
            component.find('ConfirmEmail').reportValidity();            
        }        
    },
    
    gotoPrevious : function(component, event) {
        var index = 0;
        let appConfig = component.get('v.appConfig');
        
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationContactInfo') {
                index = i;
                break;
            }
        }         
        
        if(index > 0) {
            var cmpEvent = component.getEvent("cmpEvent");
            cmpEvent.setParams({
                'cmpName' : appConfig[index-1].responsibleComponent,
                'index': index-1
            });
            cmpEvent.fire();            
        }      
    }
})