({
    getSubscriptionInfo : function(component) {
        var action = component.get("c.fetchSubscription");
        
        action.setParams({
            subId: component.get("v.subscriptionId"),
            productType: component.get("v.productType")
        });
        
        action.setCallback(this, function(response) {
            console.log('***response:' + response);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var subscription = response.getReturnValue();
                if(subscription && subscription.Id){
                     component.set("v.subscriptionObj", subscription);
                }
            }
            else if(state == 'ERROR'){
                window.location = '/customers/apex/Communities_Exception';
            }
        });
        $A.enqueueAction(action);   	
	},
    
    getRatePlanList : function(component){
        var action = component.get("c.populateProductRatePlans");
        action.setParams({
            subId:    component.get("v.subscriptionId"),
            productType: component.get("v.productType") 
        });
        console.log('***action:' + action);
        action.setCallback(this, function(response) {
            console.log('***response Rateplans:' + response);
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                var results = response.getReturnValue(); 
                var oneTimeRatePlanList = [];
                var recurringRatePlanList = [];
               //var productName = [];
                //component.set("v.recurringRatePlanList", results);
                console.log('***results:' + JSON.stringify(results));
               // alert('***results:' + JSON.stringify(results));
                if (results != null) {
                    var listLength = results.length;
                    var recurringRatePlanMap = {};
                    var oneTimeRatePlanMap = {};
                    var oneTimeRatePlanAmountMap = {};
                    var recurringRatePlanAmountMap = {};
                    for (var i=0; i < listLength; i++) {
                        console.log('results[i].rateplanName: ' + results[i].rateplanName);
                        console.log('results[i].rateplanId: ' + results[i].rateplanId);
                        console.log('results[i].chargeType: ' + results[i].chargeType);
                        console.log('results[i].chargeAmount: ' + results[i].chargeAmount);
                        if(results[i].chargeType == 'OneTime'){
                            oneTimeRatePlanList.push({ value: results[i].rateplanId, label: results[i].rateplanName, amount: results[i].chargeAmount });
                        oneTimeRatePlanMap[results[i].rateplanId] = results[i].rateplanName;
                        oneTimeRatePlanAmountMap[results[i].rateplanId] = results[i].chargeAmount;
                        }
                        
                        if(results[i].chargeType == 'Recurring'){
                            recurringRatePlanList.push({ value: results[i].rateplanId, label: results[i].rateplanName, amount: results[i].chargeAmount });
                            recurringRatePlanMap[results[i].rateplanId] = results[i].rateplanName;
                            //alert(JSON.stringify(recurringRatePlanList))
                            var cloudCMASuppress = $A.get("$Label.c.Suppressed_CloudCMA");
                            var cloudCMASuppress2Year = $A.get("$Label.c.Suppressed_CloudCMA_2_Year");
                            var cloudCMAHomebeatMonthly = $A.get("$Label.c.Suppressed_CloudCMA_Homebeat_Monthly");
                            if(results[i].rateplanId == cloudCMASuppress){
                             recurringRatePlanList.pop({ value: results[i].rateplanId, label: results[i].rateplanName, amount: results[i].chargeAmount });
                            }
                            if(results[i].rateplanId == cloudCMASuppress2Year){
                             recurringRatePlanList.pop({ value: results[i].rateplanId, label: results[i].rateplanName, amount: results[i].chargeAmount });
                            }
                            if(results[i].rateplanId == cloudCMAHomebeatMonthly){
                             recurringRatePlanList.pop({ value: results[i].rateplanId, label: results[i].rateplanName, amount: results[i].chargeAmount });
                            }
                        recurringRatePlanAmountMap[results[i].rateplanId] = results[i].chargeAmount;
                        }
                    }
                    console.log('recurringRatePlanAmountMap'+JSON.stringify(recurringRatePlanAmountMap));
                    console.log('oneTimeRatePlanAmountMap'+JSON.stringify(oneTimeRatePlanAmountMap));
                    console.log('recurringRatePlanMap'+JSON.stringify(recurringRatePlanMap));
                    console.log('oneTimeRatePlanMap'+JSON.stringify(oneTimeRatePlanMap));
                    //alert('***recurringRatePlanList:' + JSON.stringify(recurringRatePlanList));
                    component.set('v.recurringRatePlanList',recurringRatePlanList);  
                    component.set('v.oneTimeRatePlanList',oneTimeRatePlanList);  
                    component.set('v.productName',results[listLength-1].productName);
                    if(results[listLength-1].productName=='CloudCMA'){
                        component.set('v.productName','Cloud CMA');
                    }
                    component.set('v.oneTimeRatePlanMap',oneTimeRatePlanMap);
                    component.set('v.recurringRatePlanMap',recurringRatePlanMap);
                    component.set('v.oneTimeRatePlanAmountMap',oneTimeRatePlanAmountMap);
                    component.set('v.recurringRatePlanAmountMap',recurringRatePlanAmountMap);
                }
            }
                else if(state == 'ERROR'){
                    console.log('***state:' + state);
                window.location = '/customers/apex/Communities_Exception';
            }
            
        });
        $A.enqueueAction(action);
    },
    getRatePlanAmount: function(component){
    var action = component.get("c.populateProductRatePlanAmount");
        action.setParams({
            
        });
        
        console.log('***action:' + action);
        
        action.setCallback(this, function(response) {
            console.log('***response Rateplans:' + response);
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue(); 
            }
        })
    },
    
})