({
    doInit : function(component, event, helper) {
      
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("id");
        var pType = currentUrl.searchParams.get("productType");
        
        if(pType == 'CloudCMA' || pType == 'Authentisign'){
            component.set('v.setupFeeDisabled',true);
        }
        
        if(pType==''){
            window.location = '/customers/apex/Communities_Exception';
        }
        
        component.set("v.subscriptionId", subId);
        component.set("v.productType", pType)
        
       // helper.getSubscriptionInfo(component);
        helper.getRatePlanList(component);
        //helper.getNewRatePlans(component);
        var action = component.get("c.getExistingProduct");
        //alert('1action'+action);
        action.setParams({
            subId: component.get("v.subscriptionId"),
            productName: component.get("v.productType")
        });
        
        action.setCallback(this, function(response) {
            console.log('***response:' + response);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var subscription = response.getReturnValue();
                if(subscription == 'CloudCMA Paid'){
                    //alert('***subscription***'+subscription);
                    var subId = component.get("v.subscriptionId");
                    var productName= component.get("v.productType");
                    var cloudCMAProductName = component.get("v.productName");
                    var hereLink = $A.get("$Label.c.BuyNowHereLink");
                    //alert(hereLink);
                    component.set('v.errorMsg', 'You&#39ve already placed an order for  '+ cloudCMAProductName +'. Please contact support if you need additional assistance.');
                    component.set('v.existDisabled',true);
                }
                if(subscription == 'CloudCMA Paid MRIS'){
                   // alert('***subscription***'+subscription);
                    var subId = component.get("v.subscriptionId");
                    var productName= component.get("v.productType");
                    var hereLink = $A.get("$Label.c.BuyNowHereLink");
                    //alert(hereLink);
                    component.set('v.errorMsg', 'You&#39ve already placed an order for  '+ cloudCMAProductName +'. You can review the products you are currently subscribed to <a style="" href="' + hereLink +'' + subId +'" target="_blank">here</a>. Please contact support if you need additional assistance.');
                    component.set('v.existDisabled',true);
                }
                   
            }
            else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }
        });
        $A.enqueueAction(action);
    },
    
    gotoNextPage : function(component, event, helper) {
        //alert(component.get("v.productName"));
       //alert(component.get("v.oneTimeRatePlanAmount"));
       //alert(component.get("v.recurringRatePlanAmount"));
        var product = component.get("v.productName");
        //Promo Code Validation
        /*var promo = component.find('promoCode');
        var promoVal = component.find('promoCode').get('v.value');
        if(promoVal != null || promoVal == '11111'){
            component.set("v.showSecondScreen", false);
           promo.setCustomValidity("Invalid Promo Code entered");
        }
        else {
                promo.setCustomValidity("");
        }
        promo.reportValidity(); 
        //Promo Code Validation
        
        var selectedvalue = component.get("v.selected");
        var inputText = component.find("selPlan").get("v.value");
        //alert('continuec');
         if(selectedvalue && (promoVal == null||promoVal == '12345' || promoVal == '' || promoVal.indexOf(' ') == 0)){
            promo.setCustomValidity("");
            component.set("v.showSecondScreen", true);
        }*/
        component.set("v.showSecondScreen", true);
        var ratePlanId = component.get("v.selectedRecurringRatePlanId");
        var setupFeeId = component.get("v.selectedOneTimeRatePlanId");
        var rAmount = component.get("v.selectedRecurringRatePlanAmount");
        var oAmount = component.get("v.selectedOneTimeRatePlanAmount");
        var rpMap = component.get("v.oneTimeRatePlanMap");
        console.log('rpMap'+JSON.stringify(rpMap));
        var appEvent = $A.get("e.c:BuyProductEvent");
        console.log('Rate Plan Id'+ratePlanId);
        console.log('Setup Fee'+setupFeeId);
        console.log(component.get("v.recurringRatePlanMap")[ratePlanId]);
        console.log(component.get("v.oneTimeRatePlanMap")[setupFeeId]);
        console.log(component.get("v.recurringRatePlanAmountMap")[ratePlanId]);
        console.log(component.get("v.oneTimeRatePlanAmountMap")[setupFeeId]);
        
        appEvent.setParams({"productName" : component.get("v.productName"),
                           "ratePlanId" : ratePlanId,
                           "setupFeeId" : setupFeeId,
                            "ratePlanName" : component.get("v.recurringRatePlanMap")[ratePlanId],
                           "setupFeeName" : component.get("v.oneTimeRatePlanMap")[setupFeeId],
                            "recurringAmount" : component.get("v.recurringRatePlanAmountMap")[ratePlanId],
                           "oneTimeAmount" : component.get("v.oneTimeRatePlanAmountMap")[setupFeeId]
                           });
        
        appEvent.fire();
    },
    
    validate : function(component, event, helper) {
       
        let inputText = component.find("selPlan").get("v.value");
        if(inputText != null){
            component.set('v.disabled',false);
        }       
    },
    getNewRatePlans: function(component){
        //alert('Hi')
        var setupFeeId = component.get("v.selectedOneTimeRatePlanId");
        var action = component.get("c.newSetupFeeMapping");
        action.setParams({
            subId:    component.get("v.subscriptionId"),
            productType: component.get("v.productType"),
            selectPlan: component.get("v.selectedRecurringRatePlanId")
        });
        console.log('***action:' + action);
        action.setCallback(this, function(response) {
            console.log('***response Rateplans:' + response);
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                alert(results.Zuora_OnetimeProductRatePlan_Id__c)
                component.set('v.newSetupFeeMapping', results.Zuora_OnetimeProductRatePlan_Id__c);
            }
                else if(state == 'ERROR'){
                    console.log('***state:' + state);
               // window.location = '/customers/apex/Communities_Exception';
            }
            
        });
        $A.enqueueAction(action);
    }
})