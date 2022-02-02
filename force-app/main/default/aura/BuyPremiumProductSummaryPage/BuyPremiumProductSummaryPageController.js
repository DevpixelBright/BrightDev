({
	doInit : function(component, event, helper) {
      
        var currentUrl = new URL(window.location);
        //alert(currentUrl);
        var subId = currentUrl.searchParams.get("id");
        var pType = currentUrl.searchParams.get("productType");
        component.set("v.subscriptionId", subId);
        component.set("v.productType", pType);
        window.addEventListener("message", $A.getCallback(function(event) {
            let msg = JSON.parse(event.data);
            if(msg.operation == 'generic_payment_cancel') {
               // alert('cancelEvent');
                component.set('v.isModalOpen', false);
                component.set('v.iFrameUrl', '');
            }
            else if(msg.operation == 'payment_success') {
                //alert('success');
               // helper.updateSubscription(component);
            }
            else if(msg.operation == 'generic_payment_complete') {
                //alert('generic Payment');
               window.location = '/customers/apex/Communities_BuyPremiumProductThankyou?id='+subId+'&productType='+pType;
                //helper.closeOrderModal(component);
            }            
        }), false);        
        helper.getTermsandConditionsCloudCMA(component, event);
        helper.getTermsandConditionsSocialPro(component, event);
        helper.getTermsandConditionsAuthentisign(component, event);
        helper.getTermsandConditionsDefault(component, event);
    },
    handleEvent : function(component, event, helper) {
        var pName = event.getParam("productName");
        var rName = event.getParam("ratePlanName");
        var sName = event.getParam("setupFeeName");
        var oAmount = event.getParam("oneTimeAmount");
        var rAmount = event.getParam("recurringAmount");
      
        component.set("v.productName", pName);
        component.set("v.selectedRecurringRatePlanId", rName);
        component.set("v.selectedOneTimeRatePlanId", sName);
        component.set("v.selectedRecurringAmount", '$ '+rAmount.toFixed(2));
        
        if(sName == null){
            component.set("v.selectedOneTimeRatePlanId", '--NA--');
        }
        if(sName != null || sName != ''){
        component.set("v.selectedOneTimeAmount", '$ '+oAmount.toFixed(2));
        }
        if(sName == null || sName == ''){
        component.set("v.selectedOneTimeAmount", '');
        }
        //helper.getRateplanInfo(component);
    },
    scrolled : function(component, event, helper) {
		helper.checkTermsScroll(component)        
    },
    termsChkBoxEvtHandler: function(component, event, helper) {
        helper.updateTermsValue(component, event);
    },
    openModel: function(component, event, helper) {
        helper.getRateplanInfo(component);
      component.set("v.isModalOpen", true);
        
   },
   closeModel: function(component, event, helper) {
      component.set("v.isModalOpen", false);
   },
    goBack: function(component, event, helper) {
       component.set("v.showPreviousScreen", true);
        location.reload();
   },
})