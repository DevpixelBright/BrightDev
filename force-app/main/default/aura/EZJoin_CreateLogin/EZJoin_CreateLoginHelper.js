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
        component.set('v.showSpinner', true);
        var action = component.get("c.getApplicationDetails");
        action.setParams({
            'applicationId' : applicationId
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            if (state === 'SUCCESS') {
				var result = response.getReturnValue();
                console.log('***result:', result);
                
                /* Check already any application exists */
                if(Object.keys(result.application).length > 0 && Object.keys(result.subscription).length == 0) {
                    if(result.application.Status__c == 'Approved') {
                        component.set('v.application', result.application);
                    }
                    else {
                        window.location = '/eProcess/EZJoin_ApplicationStatus';   
                    }
                } 
                else if(Object.keys(result.application).length > 0 && Object.keys(result.subscription).length > 0) {
                    window.location = '/eProcess/EZJoin_ApplicationPayment?Id=' + result.application.Name;   
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
    
	validateLoginName : function(component) {
        this.resetDefaults(component);
        var field = component.find('LoginName'); 
        if(!field.get('v.validity').valid) {
            return;
        }
        
		var loginName = component.get('v.loginName');
        var patt = /^[A-Za-z0-9 @.-]*$/;
        if(!patt.test(loginName)) {
        	this.setValidity(component, 'Login name rules not matching.');
            return;
        }
        else {
            this.checkLoginNameAvailability(component);
        }        
	},
    
    checkLoginNameAvailability : function(component) {
        component.set('v.showSpinner', true);
        var action = component.get("c.validateLoginName");
        action.setParams({
            'loginNameStr' : component.get('v.loginName')
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            console.log('***state:', state);
            if (state === 'SUCCESS') {
                component.set('v.isAvailable', true);
            }
            else if(state == 'ERROR') {
                component.set('v.isTaken', true);
                //this.handleServerErrors(component, response.getError());
            }
        });
        
        $A.enqueueAction(action);   
    },
    
    createNewSubscription : function(component) {
        component.set('v.showSpinner', true);
        var action = component.get("c.createSubscription");
        action.setParams({
            'applicationId' : component.get('v.application').Name,
            'loginName' : component.get('v.loginName')
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            console.log('***state:', state);
            if (state === 'SUCCESS') {
                
                window.location = '/eProcess/EZJoin_ApplicationPayment?Id=' + component.get('v.application').Name;
            }
            else if(state == 'ERROR') {
                this.handleServerErrors(component, response.getError());
            }
        });
        
        $A.enqueueAction(action);        
    },
    
    resetDefaults : function(component) {
    	component.set('v.isAvailable', false);
        component.set('v.isTaken', false); 
        this.setValidity(component, '');
    },
    
    setValidity : function(component, errorMsg) {
        component.find('LoginName').setCustomValidity(errorMsg);
        component.find('LoginName').reportValidity();        
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