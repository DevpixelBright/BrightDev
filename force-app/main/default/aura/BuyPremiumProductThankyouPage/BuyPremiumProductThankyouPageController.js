({
    doInit : function(component, event, helper) {
	var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("id");
        var pType = currentUrl.searchParams.get("productType");
        var product = component.get("v.productName");
        if(product == 'CloudCMA'){
            product = 'Cloud CMA';
        }
        if(pType==''){
            window.location = '/customers/apex/Communities_Exception';
        }
        component.set("v.subscriptionId", subId);
        component.set("v.productType", pType);
        helper.getRatePlanList(component);
    },
    
})