({
    searchHandler : function (component, event, helper) {
        const searchString = event.target.value;
        if (searchString.length >= 2) {
            component.set("v.openDropDown", true);
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }

            var inputTimer = setTimeout($A.getCallback(function () {
                helper.searchRecords(component, searchString);
            }), 500);
            component.set("v.inputSearchFunction", inputTimer);
        } else{
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },

    optionClickHandler : function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
		const selectedObj = component.get("v.results")[selectedId];
        
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
        component.set("v.selectedObj", selectedObj.obj);
        
        var type = component.get('v.cmpType');
        if(type == 'BrokerCode') {
            helper.fireComponentEvent(component, event);
        }        
    },
    
    addAgentEvtClickHandler: function(component, event, helper) {
        helper.fireComponentEvent(component, event);
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");        
    },

    clearOption : function (component, event, helper) {
        console.log('*** selectedOption:', component.get("v.selectedOption"));
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
    }   
})