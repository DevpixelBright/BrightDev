({
    onInit: function(component, event, helper) {
        if(component.get("v.inputValue") != undefined) {
            if(component.get("v.inputValue") == ' - ') {
                component.set("v.inputValue", "")
            }
        }
        
        var type = component.get('v.cmpType');
        if(type == 'Agents') {
            console.log('*** selectedOption:', component.get("v.selectedOption"));
            component.get("v.selectedOption", '');
        }
    },
    
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
        } 
        else if(component.get("v.results").length > 0 && searchString.length < 2) {
            component.set("v.results", []);
            component.set("v.openDropDown", false);
            component.set("v.selectedObj", {});
            helper.fireClearEvent(component, event);
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
        document.getElementById('combobox-id-21-' + component.get('v.cmpType')).readOnly = true;
        
        var type = component.get('v.cmpType');
        if(type == 'BrokerCode' || type == 'Appraiser') {
            helper.fireComponentEvent(component, event);
        }        
    },
    
    addAgentEvtClickHandler: function(component, event, helper) {
        if(component.get("v.selectedOption") && component.get("v.selectedOption") != '') {
            helper.fireComponentEvent(component, event);
            component.set("v.results", []);
            component.set("v.openDropDown", false);
            component.set("v.inputValue", "");
            component.set("v.selectedOption", "");
            document.getElementById('combobox-id-21-' + component.get('v.cmpType')).readOnly = false;
        }
        else {
            
        }
    },

    clearOption : function (component, event, helper) {
        
        if(component.get('v.transaction') == 'Reinstatement' && component.get('v.cmpType') == 'BrokerCode') {
            console.log('***Ignore clearing');
            helper.fireClearEvent(component, event);
        }
        else {
            //console.log('*** selectedOption:', component.get("v.selectedOption"));
            component.set("v.results", []);
            component.set("v.openDropDown", false);
            component.set("v.inputValue", "");
            component.set("v.selectedOption", "");
            component.set("v.selectedObj", {});
            component.find('AutoInput').set('v.value', '');
            document.getElementById('combobox-id-21-' + component.get('v.cmpType')).value = '';
            document.getElementById('combobox-id-21-' + component.get('v.cmpType')).readOnly = false;            
            helper.fireClearEvent(component, event);
        }
    }   
})