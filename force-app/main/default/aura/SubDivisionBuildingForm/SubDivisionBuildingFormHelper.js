({
	getSubscriptionInfo : function(component) {
        var action = component.get("c.fetchSubscription");
        action.setParams({
            subId: component.get("v.subscriptionId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var subscription = response.getReturnValue();
                if(subscription && subscription.Id){
                    component.find("continueBtn").set("v.disabled", false);
                }else{
                    component.find("continueBtn").set("v.disabled", true);
                    window.location = '/customers/apex/Communities_Exception';
                }
            }
            else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }
        });
        $A.enqueueAction(action);   	
	},
})