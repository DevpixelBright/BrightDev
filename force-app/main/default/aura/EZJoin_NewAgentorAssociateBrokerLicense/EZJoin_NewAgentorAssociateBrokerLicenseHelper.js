({
    initializeAppData: function(component) {
        var appConfig = JSON.parse(JSON.stringify(component.get('v.appConfig')));
        var appData = JSON.parse(JSON.stringify(component.get('v.appData')));
        var currentConfig = null;
        component.set('v.appType', appConfig[0].applicationType);
        
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'Ezjoin_NewAgentorAssociateBrokerLicense') {
                appConfig[i].status = 'In Progress';
                currentConfig = appConfig[i];
                break;
            }
        } 
        currentConfig.status = 'In Progress';
        component.set('v.currentConfig', currentConfig);
        
        if(appData.license == undefined) {
            appData = {};
            var currentUrl = new URL(window.location);
            var appSubType = currentUrl.searchParams.get("type");
            appData['license'] = {licenseNumber: '', licenseExpirationDate: '', licenseState: '', nrdsId: '', licenseType: appSubType};
        }
        else {
            component.set('v.brokerCode', appData.broker);
            component.set('v.association', appData.association);
        }
        console.log('***appData:', appData);
        
        component.set('v.appData', appData);
        component.set('v.appConfig', appConfig);        
    },
    
    getStateValues : function(component) {
        var appData = component.get('v.appData');
        if(appData.states != undefined) {
            component.set('v.states', appData.states);
        	return;
        }        
        
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'objectName' : 'License__c',
            'fieldName': 'License_State__c'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                component.set('v.states', response);
                
                if(appData.states == undefined) {
                    appData['states'] = response;
                }
                component.set('v.appData', appData);                
            } 
        });
        
        $A.enqueueAction(action);         
    },
    
    
    validateSubmission : function(component, event) {
        component.find("LicenseExpiration").setCustomValidity('');
        component.find("LicenseExpiration").reportValidity();
        component.find("NRDSId").setCustomValidity('');
        component.find("NRDSId").reportValidity();
		component.set('v.errorMsg', '');       
        document.getElementById('AssociationError').innerHTML = '';
        document.getElementById('combobox-id-21-Association').style.boxShadow = '';
        document.getElementById('combobox-id-21-Association').style.border = '1px solid #ccc';        
        
        var appData = JSON.parse(JSON.stringify(component.get('v.appData')));
        var brokerInfo = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
        var association = JSON.parse(JSON.stringify(component.get('v.association')));

        var requiredFields = ['LicenseNumber', 'LicenseExpiration', 'LicenseState'];
        var isValid = true;
        for(var i=0; i<requiredFields.length; i++) {
        	var field = component.find(requiredFields[i]); 
            if(!field.get("v.validity").valid) {
                field.showHelpMessageIfInvalid();              
                isValid = false;
            }
        }        
        
        if(appData.license.licenseExpirationDate != undefined && appData.license.licenseExpirationDate != '') {
            var selectedDate = new Date(appData.license.licenseExpirationDate);
            var dt = new Date();
            if(selectedDate < dt) {
                component.find("LicenseExpiration").setCustomValidity(' Expiration must be future date');
                component.find("LicenseExpiration").reportValidity(); 
                isValid = false;
            }
        }
        
        if(appData.license.nrdsId != undefined && appData.license.nrdsId != '' && association.Name == undefined) {
            document.getElementById('combobox-id-21-Association').style.boxShadow = 'rgb(194, 57, 52) 0 0 0 1px inset, 0 0 3px #0070d2';
            document.getElementById('combobox-id-21-Association').style.border = '1px solid red';
            document.getElementById('AssociationError').innerHTML = 'Please select Association along with NRDS ID';
            isValid = false;
        }
        
        if((appData.license.nrdsId == undefined || appData.license.nrdsId == '') && association.Name != undefined) {
            component.find("NRDSId").setCustomValidity('Please enter NRDS ID along with Association');
            component.find("NRDSId").reportValidity(); 
            isValid = false;
        } 
        
        if(isValid) { 
            //console.log('***', appData.license);
            component.set('v.showSpinner', true);
            var action = component.get("c.verifyLicenseDetails");
            action.setParams({
                'licenseNumber' : appData.license.licenseNumber,
                'licenseState': appData.license.licenseState,
                'licenseType': appData.license.licenseType == 'Agent' ? 'Salesperson' : 'Associate Broker'
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state == 'SUCCESS') {
                    component.set('v.showSpinner', false);
                    var response = response.getReturnValue();
                    //console.log('***Existing:', response);
                    
                    if(response.application.length > 0) {
                        component.set('v.errorMsg', 'Application already exists with these license details. Please<a style="" href="/eProcess/EZJoin_ApplicationDetails?Id=' + response.application[0].Name + '">click here</a>to view.');
                    }
                    else if(response.subLicense.length > 0) {
                        component.set('v.errorMsg', 'Subscription already exists with these license details. Please<a style="" href="/eProcess/EZJoin_ReactivateSubscription?Id=' + response.subLicense[0].Subscription__r.Name + '">click here</a>to view.');
                    }
                    else {
                        this.handleSubmission(component, event);     
                    }
                }
            });
            $A.enqueueAction(action);       
        }        
    },
    
	handleSubmission : function(component, event) {
        var appData = component.get('v.appData');       
        appData.broker = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
        if(component.get('v.association').Name != undefined)
        	appData.association = JSON.parse(JSON.stringify(component.get('v.association')));
        else
            appData.association = {};
        component.set('v.appData', appData);
        
        var currentConfig = component.get('v.currentConfig');
        currentConfig.status = 'Completed';
        
        var appConfig = component.get('v.appConfig');
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'Ezjoin_NewAgentorAssociateBrokerLicense') {
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
            'currentCmp': 'Ezjoin_NewAgentorAssociateBrokerLicense',
            'applicationConfig': component.get('v.appConfig'),
            'applicationData': component.get('v.appData')
        });
        applicationEvent.fire();        
    },
    
    gotoPrevious : function(component, event) {
        var index = 0;
        let appConfig = component.get('v.appConfig');
        
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'Ezjoin_NewAgentorAssociateBrokerLicense') {
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
    },
    
    autoCompleteClearHandler: function(component, event) {
        var type = event.getParam('cmpType');

        if(type == 'BrokerCode') {
            component.set('v.brokerCode', {});
        }
        else if(type == 'Association') {
            component.set('v.association', {});
        }
    }    
})