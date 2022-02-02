({
    gotoNextPage : function(component, event, helper) {
        var selectedvalue = component.get("v.selected");
        if(selectedvalue){
            component.set("v.showSecondScreen", true);
        }
        /*
        if(selectedvalue=="Subdivision"){
            component.set("v.isSubdivision",true);
        }
        else if(selectedvalue=="Building"){
            component.set("v.isBuilding",true);
        }*/
    },
    doInit : function(component, event, helper) {
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("Id");
        component.set("v.subscriptionId", subId);
        helper.getSubscriptionInfo(component);
    },
    
    onRadio: function(cmp, evt) {
        resultCmp = cmp.find("radioGroupResult");
		 resultCmp.set("v.value", selected);
        var selected = evt.getSource().get("v.label");
        alert(selected);
        if(selected == "Add a new Subdivision")
        	cmp.set("v.selected", "Subdivision");
        else if(selected == "Add a new Building Name")
        	cmp.set("v.selected", "Building");
    },    
})