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
    getRateplanInfo : function(component) {
        var action = component.get("c.orderConfirm");
      // alert(component.get("v.productName"));
       //alert(component.get("v.selectedRecurringRatePlanId"));
       // alert(component.get("v.selectedOneTimeRatePlanId"));
        //alert(component.get("v.subscriptionId"));
        var subsId = component.get("v.subscriptionId");
        var productName = component.get("v.productName");
        if(productName == 'Cloud CMA'){
            productName = 'CloudCMA';
        }
        action.setParams({
            productName: productName,
            ratePlanName: component.get("v.selectedRecurringRatePlanId"),
            subId: subsId,
            onetimeRatePlanName: component.get("v.selectedOneTimeRatePlanId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var iframeURL = response.getReturnValue();
                console.log('****iframeURL***'+iframeURL);
                component.set('v.isModalOpen', true);
                component.set('v.iFrameUrl', iframeURL);
                //alert(iframeURL);
            }
            /* else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }*/
        });
        $A.enqueueAction(action);   	
    },
    updateSubscription : function(component) {
        var action = component.get("c.activateSubscription");
        action.setParams({
            'subscriptionId': component.get('v.subscription').Id,
            'isActivateNoPayment': false,
            'applicationId': component.get('v.application').Id
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('*** Activate Result:', state);
            
            if(state === 'SUCCESS') {
				var response = response.getReturnValue();
                if(response == 'Success') {
                    component.set('v.showSuccess', true);
                }
            }
            else if(state === 'ERROR') {
                this.handleServerErrors(component, response.getError());
            }
            else if(state === 'INCOMPLETE') {
                this.handleServerErrors(component, 'Unable to complete the process. Please check network connection.');
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    closeOrderModal : function(component) {
        component.set('v.showIFrame', false);
        component.set('v.iFrameUrl', '');
        if(component.get('v.errorMsg') == '')
			component.set('v.showSuccess', true);        
    },
    checkTermsScroll : function(component) {
        let offset = document.getElementById('terms-div').offsetHeight;
        let scrollTop = document.getElementById('terms-div').scrollTop;
        let scrollHeight = document.getElementById('terms-div').scrollHeight;
        if(offset + scrollTop >= scrollHeight) {
            component.set('v.enableTerms', true);
        }
    },
    updateTermsValue: function(component, event) {
        var appData = component.get('v.subscriptionObj');
        appData.acceptTerms = !appData.acceptTerms;
        component.set('v.subscriptionObj', appData)
        console.log(appData);
    },
    getTermsandConditionsCloudCMA: function(component, event) {
        var action = component.get("c.termsConditionsCloudCMA");
     
        var subsId = component.get("v.subscriptionId");
        action.setParams({
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state)
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var resValue = result.Content__c;
                //alert(resValue)
                component.set('v.cloudCMAcontent', resValue);
            }
            /* else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }*/
        });
        $A.enqueueAction(action); 
        
    },
    getTermsandConditionsSocialPro: function(component, event) {
        var action = component.get("c.termsConditionsSocialPro");
     
        var subsId = component.get("v.subscriptionId");
        action.setParams({
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state)
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var resValue = result.Content__c;
                //alert(resValue)
                component.set('v.socialProContent', resValue);
            }
            /* else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }*/
        });
        $A.enqueueAction(action); 
        
    },
    getTermsandConditionsAuthentisign: function(component, event) {
        var action = component.get("c.termsConditionsAuthentisign");
     
        var subsId = component.get("v.subscriptionId");
        action.setParams({
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state)
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var resValue = result.Content__c;
                //alert(resValue)
                component.set('v.authentisignContent', resValue);
            }
            /* else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }*/
        });
        $A.enqueueAction(action); 
        
    },
getTermsandConditionsDefault: function(component, event) {
        var action = component.get("c.termsConditionsDefault");
     
        var subsId = component.get("v.subscriptionId");
        action.setParams({
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state)
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var resValue = result.Content__c;
                //alert(resValue)
                component.set('v.defaultContent', resValue);
            }
            /* else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }*/
        });
        $A.enqueueAction(action); 
        
    },
    
})