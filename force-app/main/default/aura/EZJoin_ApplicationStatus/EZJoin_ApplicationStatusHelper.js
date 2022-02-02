({
	getApplicationDetails : function(component) {
        debugger;
        if(component.get('v.applicationId') == '') {
        	var field = component.find('ApplicationId'); 
            if(!field.get("v.validity").valid) {
                field.showHelpMessageIfInvalid();              
                return;
            }            
        }
        else {
            this.setValidity(component, '')
        }
        
        component.set('v.showSpinner', true);
        var action = component.get("c.getApplicationDetails");
        action.setParams({
            'applicationId' : component.get('v.applicationId')
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('*** application:', result);
                
                /* Check if subscription is valid or not */
                if(Object.keys(result.application).length == 0) {
                    this.setValidity(component, 'Invalid Application ID.');
                }                 
                else {

                    window.location = '/eProcess/EZJoin_ApplicationDetails?Id=' + component.get('v.applicationId');
                }                
            }
            else if(state == 'ERROR') {
                this.setValidity(component, 'Invalid Application ID.');
            }
        });
        
        $A.enqueueAction(action);        
	},
    
    setValidity : function(component, errorMsg) {
        component.find('ApplicationId').setCustomValidity(errorMsg);
        component.find('ApplicationId').reportValidity();        
    },
    
    handleServerErrors : function(component, errors) {
        component.set('v.showServerError', true);
        let message = 'Unknown error';
        if (errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
        }
        console.error(message);         
    }
})