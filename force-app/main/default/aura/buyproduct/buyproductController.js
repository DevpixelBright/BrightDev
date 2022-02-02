({
	doInit : function(component, event, helper) {
      
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("id");
        var pType = currentUrl.searchParams.get("productType");
        component.set("v.subscriptionId", subId);
        component.set("v.productType", pType)
        helper.getSubscriptionInfo(component);
    },
})