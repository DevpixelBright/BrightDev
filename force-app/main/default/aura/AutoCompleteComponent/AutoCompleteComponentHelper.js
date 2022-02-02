({
    searchRecords : function(component, searchString) {
        let comType = component.get('v.cmpType');
        var action;
        if(comType == 'BrokerCode') {
            action = component.get("c.getBrokerOffice");
            action.setParams({
                "searchKey" : searchString
            });
        }
        else if(comType == 'Agents') {
			const brokerCode = component.get('v.brokerCode');
            console.log('***brokerCode:', brokerCode);
            action = component.get("c.getAgents");
            action.setParams({
                "broker" : brokerCode,
                "searchKey" : searchString
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
                    if(comType == 'BrokerCode') {
                    	result = {id : i, value : element['Account_Name__c'] + ' - ' + element['Name'], obj: element};
                    }
                    else if(comType == 'Agents') {
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
    }         
})