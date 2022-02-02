({
    getSubscriptionOptions : function(component,event,helper) {
        var action = component.get("c.getSubscriptionOptions ");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.subscriptionOptions',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchBrokerOffice : function(component,event,helper){
        component.set('v.oBrightApplication.Company_Code__c', '');
        component.set('v.brokerCodeAddress',[]);
        var action = component.get("c.getBrokerOffice ");
        var val = component.find('brokerCode').get('v.value');
        action.setParams({ brokerCode : val });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.Brokerlist',response.getReturnValue());
                component.set('v.width',component.find("brokerCodeDiv").getElement().getBoundingClientRect().width+'px');
                
            }
        });
        $A.enqueueAction(action);  
    },
    
    fetchPicklistValues : function(component,event,helper){
        var action = component.get("c.getPicklistValues");
        action.setParams({ field_name : 'Salutation__c', objectName : 'MRIS_Application__c' });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.salutationlist',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    
    fetchsuffixvalues : function(component,event,helper){
        var action = component.get("c.getPicklistValues");
        action.setParams({ field_name : 'Suffix__c', objectName : 'MRIS_Application__c'});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.suffixList',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    
    fetchAgentname : function(component, event, helper, searchKey, cmp){
        var action = component.get("c.getAgentName");
        action.setParams({ AgentName : component.get("v.selectedBrkrCode"), searchKey : searchKey });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.setCustomValidity('');
                cmp.reportValidity();
                component.set('v.AgentNameList',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    
    fetchSubId : function(component,event,helper, contactName){
        component.set('v.oSubscription.Name', '');
        var action = component.get("c.getSubId");
        var val = event.getSource().get('v.value');
        var brokerId = component.get('v.oBrightApplication.Company_Code__c')
        action.setParams({ agentId : contactName, searchText : val, brokerId : brokerId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.SubIdList',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    
    submitApplication : function(component,event,helper) {
        
        var action = component.get("c.submitApplication");
        var agentList = component.get('v.AgentList');
        var agentDetails = '';
        for(var agent of agentList){
            agentDetails += agent.name +' '+ agent.sub+', ';
        }
        component.set('v.oBrightApplication.Related_Agents__c', agentDetails);
        action.setParams({ oApplication : component.get('v.oBrightApplication')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.saved',true);
            }
        });
        $A.enqueueAction(action);
    },
    
    validateComponent : function(cmp) {
        var isValid = true;
        var val = cmp.get('v.value');
        if( val == undefined || val == null || val == '') {
            cmp.setCustomValidity('Enter a value');
            isValid = false;
        }
        else {
            cmp.setCustomValidity('');
        }
        cmp.reportValidity();
        return isValid;
    },
    
    getConstants : function(component,event,helper) {
        var action = component.get("c.getConstants");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.Constants',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})