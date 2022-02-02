({
	myAction : function(component, event, helper) {
		
	},
    
    toggleFunction1 : function(component, event, helper) {
        var toggleValue = component.get("v.toggle1");
        console.log(toggleValue);
        if(toggleValue == true) {
            component.set("v.toggle1", false);
        } else {
            component.set("v.toggle1", true);
        }       
	},
    
    toggleFunction2 : function(component, event, helper) {
        var toggleValue = component.get("v.toggle2");
        console.log(toggleValue);
        if(toggleValue == true) {
            component.set("v.toggle2", false);
        } else {
            component.set("v.toggle2", true);
        }       
	},
    
    toggleFunction3 : function(component, event, helper) {
        var toggleValue = component.get("v.toggle3");
        console.log(toggleValue);
        if(toggleValue == true) {
            component.set("v.toggle3", false);
        } else {
            component.set("v.toggle3", true);
        }       
	},
    
})