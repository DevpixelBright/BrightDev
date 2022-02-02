({
    getSubscriptionValues : function(component) {
        var action = component.get("c.submitSubscription");
        action.setParams({
            url: window.location.href
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue()',response.getReturnValue());
            console.log('response.getErrors()',response.getError());
            if (state === "SUCCESS") {
            	component.set('v.subscription', response.getReturnValue());
            }
            else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }
        });
        $A.enqueueAction(action);   	
	},
    getActionValues: function(component) {
        var subscription = component.get('v.subscription');
        try {
            if(subscription.Contact_Type__c == 'Agent') {
                window.open($A.get('$Label.c.Ezjoin_agent_Redirect') + subscription.Name, '_blank');
            } 
            else if((subscription.Contact_Type__c == 'Assistant' && subscription.Subscription_Type__c == 'Personal Assistant') || (subscription.Contact_Type__c == 'Assistant' && subscription.Subscription_Type__c == 'Personal Assistant to Appraiser')){
                window.open($A.get('$Label.c.Ezjoin_PA_Redirect') + subscription.Name, '_blank');
            }
            else if((subscription.Contact_Type__c == 'Staff' && subscription.Subscription_Type__c == 'Office Secretary') || (subscription.Contact_Type__c == 'Staff' && subscription.Subscription_Type__c == 'Office Secretary - NC')){
                window.open($A.get('$Label.c.Ezjoin_PA_Redirect') + subscription.Name, '_blank');
            }
            else {
            	window.open($A.get('$Label.c.Ezjoin_redirect') , '_blank');   
            } 
        }
        catch(err) {
            alert('Error:' + err.message);
        }
	}
})