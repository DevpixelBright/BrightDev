({
    searchRecords : function(component, searchString) {
        let comType = component.get('v.cmpType');
        let appType = component.get('v.applicationType')
        var action;
        if(comType == 'BrokerCode' && appType != 'Agent') {
            action = component.get("c.getBrokerOffice");
            action.setParams({
                "searchKey" : searchString,
                "applicationType": component.get('v.applicationType'),
                "subscriptionType": component.get('v.subscriptionType')
            });
        }
        else if(comType == 'BrokerCode' && appType == 'Agent') {
            action = component.get("c.getBrokerIds");
            action.setParams({
                "searchKey" : searchString,
                "applicationType": component.get('v.applicationType'),
                "subscriptionType": component.get('v.subscriptionType')
            });
            
        }
       	else if(comType == 'Association' && appType == 'Agent') {
            action = component.get("c.getAllAssociations");
            action.setParams({
                "searchKey" : searchString,
                "applicationType": component.get('v.applicationType'),
                "subscriptionType": component.get('v.subscriptionType')
            });
        }
        else if(comType == 'Agents' || comType == 'Appraiser') {
            var agents = JSON.parse(JSON.stringify(component.get('v.agents')));
			const brokerCode = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
			var agentIds = [];
            for(var i=0; i<agents.length; i++) {
                agentIds.push(agents[i].Id);
            }
            console.log('***agentIds:', agentIds);
            console.log('***brokerCode:', brokerCode);
            
            action = component.get("c.getAgents");
            action.setParams({
                "broker" : brokerCode,
                "searchKey" : searchString,
                "selectedAgents": agentIds
            });
        }

        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                const results = [];
                console.log('***serverResult', serverResult);
                var i = 0;
                serverResult.forEach(element => {
                    var result;
                    if(comType == 'BrokerCode' || comType == 'Association') {
                    	result = {id : i, value : element['Account_Name__c'] + ' - ' + element['Name'], obj: element};
                    }
                    else if(comType == 'Agents' || comType == 'Appraiser') {
                    	result = {id : i, value : element['Contact__r']['Name'] + ' - ' + element['Name'], obj: element};
                	}
                    results.push(result);
                    i++;
                });
            
                component.set("v.results", results);
            
                if(serverResult.length > 0) {
                    component.set("v.openDropDown", true);
                }
            	else {
                	component.set("v.openDropDown", false);
            	}
            } 
            else {
                console.log("Something went wrong!! Check server logs!!");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }        
            }
        });
        $A.enqueueAction(action);
    },
        
    handleOptionSelection: function(component, event) {

    },
        
    fireComponentEvent : function(component, event) {
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "cmpType" : component.get('v.cmpType'),
            "objSelected": component.get("v.selectedObj")
        });
        cmpEvent.fire();
    },
        
    fireClearEvent : function(component, event) {
        console.log('**** Clear event in auto complete');
        var cmpEvent = component.getEvent("cmpEvent1");
        cmpEvent.setParams({
            "cmpType" : component.get('v.cmpType'),
        });
        cmpEvent.fire();
    }         
})