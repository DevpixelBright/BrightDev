({
    getApplicationId : function(component) {
        component.set('v.showSpinner', true);
        var currentUrl = new URL(window.location);
        var applicationId = currentUrl.searchParams.get("Id");
        //var applicationId = window.location.search.substring(1).replace('Id=', '');
        if(applicationId == '') {
                window.location = '/eProcess/EZJoin_ApplicationStatus';
            return;
        }
        else {        
            this.fetchApplicationDetails(component, applicationId);
        }
    },
    
	fetchApplicationDetails : function(component, applicationId) {  
        var currentUrl = new URL(window.location);
        component.set('v.showSpinner', true);
        var action = component.get("c.getApplicationDetails");
        action.setParams({
            'applicationId' : applicationId
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            if (state === 'SUCCESS') {
				var response = response.getReturnValue();
                console.log('***', response);
                
                /* Check already any application exists */
                if(Object.keys(response.application).length > 0 && Object.keys(response.subscription).length > 0) {
                    if(response.application.Status__c == 'Approved' || response.application.Status__c == 'Completed') {
                        component.set('v.application', response.application);
                        component.set('v.subscription', response.subscription);
                        if(response.application.Related_Agents__c != undefined) {
                            var agents = JSON.parse(response.application.Related_Agents__c);
                            component.set('v.agents', agents);
                        }
                        
                        if(response.agents.length > 0) {
                            component.set('v.subscriptionAgents', response.agents);
                        }
                    }
                    else {
                        window.location = '/eProcess/EZJoin_ApplicationStatus';
                    }
                }                
                else {
                     window.location = '/eProcess/EZJoin_ApplicationStatus';  
                }
            }
            else if(state == 'ERROR') {
                window.location = '/eProcess/EZJoin_ApplicationStatus';
            }
        });
        
        $A.enqueueAction(action);        
	},
    
    setupOrder : function(component) {
        component.set('v.showSpinner', true);
        var action = component.get("c.createOrder");
        console.log(component.get('v.subscription').Id);
        action.setParams({
            'subscriptionId' : component.get('v.subscription').Id
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            if(state === 'SUCCESS') {
				var response = response.getReturnValue();
                console.log('***', response);
                component.set('v.showIFrame', true);
                component.set('v.iFrameUrl', response);
            }
            else if(state === 'ERROR') {
                this.handleServerErrors(component, response.getError());
            }
            else if(state === 'INCOMPLETE') {
                this.handleServerErrors(component, 'Unable to complete the process. Please check network connection.');
            }
        });
        
        $A.enqueueAction(action);              
    },
    
    updateSubscription : function(component) {
        var action = component.get("c.activateSubscription");
        action.setParams({
            'subscriptionId': component.get('v.subscription').Id,
            'isActivateNoPayment': false,
            'applicationId': component.get('v.application').Id
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('*** Activate Result:', state);
            
            if(state === 'SUCCESS') {
				var response = response.getReturnValue();
                if(response == 'Success') {
                    component.set('v.showSuccess', true);
                }
            }
            else if(state === 'ERROR') {
                this.handleServerErrors(component, response.getError());
            }
            else if(state === 'INCOMPLETE') {
                this.handleServerErrors(component, 'Unable to complete the process. Please check network connection.');
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    closeOrderModal : function(component) {
        component.set('v.showIFrame', false);
        component.set('v.iFrameUrl', '');
        if(component.get('v.errorMsg') == '')
			component.set('v.showSuccess', true);        
    },
    
    handleServerErrors : function(component, errors) {
        component.set('v.showServerError', true);
        let message = 'ERROR: ';
        if (errors && Array.isArray(errors) && errors.length > 0) {
            message = message + errors[0].message;
        }
        component.set('v.errorMsg', message);    
    }    
})