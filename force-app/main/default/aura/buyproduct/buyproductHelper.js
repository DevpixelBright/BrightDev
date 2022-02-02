({
    getSubscriptionInfo : function(component) {
        var action = component.get("c.fetchSubscription");
        
        action.setParams({
            subId: component.get("v.subscriptionId"),
            productType: component.get("v.productType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var subscription = response.getReturnValue();
                if(subscription && subscription.Id){
                     component.set("v.subscriptionObj", subscription);
                    var str = component.find("name1").get("v.value");
                    var res = str.substring(0, 1);
                    component.set("v.name", res);
                    var str2 = component.find("name1").get("v.value");
                    var res2 = str2.match(/\b(\w)/g);
                    var result = res2[1];
                    component.set("v.name2", result);
                    
                }
            }
           /* else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }*/
        });
        $A.enqueueAction(action);   	
	},
})