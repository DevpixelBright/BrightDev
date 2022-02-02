({
	getSubscriptionDetails : function(component) {
        debugger;
        if(component.get('v.subscriptionId') == '') {
        	var field = component.find('SubscriptionId'); 
            if(!field.get("v.validity").valid) {
                field.showHelpMessageIfInvalid();              
                return;
            }            
        }
        else {
            this.setValidity(component, '')
        }
        
        component.set('v.showSpinner', true);
        var action = component.get("c.getSubscriptionDetails");
        action.setParams({
            'subscriptionId' : component.get('v.subscriptionId')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var reinstateRecord = response.getReturnValue();
                console.log('***reinstateRecord:', reinstateRecord);
                /* Check if subscription is valid or not */
                if(Object.keys(reinstateRecord.subscription).length == 0) {
                    this.setValidity(component,'Subscription ID does not exist.');
                }                 
                else {
                    var subscription = reinstateRecord.subscription;
                    if((subscription.Contact_Type__c == 'Assistant' && (subscription.Subscription_Type__c == 'Personal Assistant' || subscription.Subscription_Type__c == 'Personal Assistant to Appraiser'))
                       || (subscription.Contact_Type__c == 'Staff' && subscription.Subscription_Type__c.includes('Office Secretary'))
                       || (subscription.Contact_Type__c == 'Agent' && (subscription.Subscription_Type__c == 'Licensee/Non Realtor' || subscription.Subscription_Type__c == 'Realtor/Shareholder' || subscription.Subscription_Type__c == 'Realtor/Non Shareholder'))
                       || (subscription.Contact_Type__c == 'Office Manager' && (subscription.Subscription_Type__c == 'Licensee/Non Realtor' || subscription.Subscription_Type__c == 'Realtor/Shareholder' || subscription.Subscription_Type__c == 'Realtor/Non Shareholder'))) 
                    {

                       window.location = '/eProcess/EZJoin_ReactivateSubscription?Id=' + component.get('v.subscriptionId');
                    }
                    else {
                        this.setValidity(component, 'Invalid subscription type');
                    }
                }
            }
            else if(state == 'ERROR') {
                console.log('ERROR');
            }
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);        
	},
    
    setValidity : function(component, errorMsg) {
        component.find('SubscriptionId').setCustomValidity(errorMsg);
        component.find('SubscriptionId').reportValidity();        
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