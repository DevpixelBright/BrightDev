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
                console.log('***response:', response);
                /* Check already any application exists */
                if(Object.keys(response.application).length > 0) {
                    component.set('v.application', response.application);
                    if(response.application.Related_Agents__c != undefined) {
                        var agents = JSON.parse(response.application.Related_Agents__c);
                        component.set('v.agents', agents);
                    }
                    
                    if(Object.keys(response.subscription).length > 0) {
                        component.set('v.subscription', response.subscription);
                    }
                    
                    if(document.getElementById('ApplicationProgressBar') && (response.application.Status__c != 'In Progress' || response.application.Status__c != 'Approved')) {
                        console.log('*** Progress bar');
                        document.getElementById('ApplicationProgressBar').style.display = 'none';
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
	}
})