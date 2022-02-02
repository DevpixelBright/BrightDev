({
	onInit : function(component, event, helper) {

	},
    
    getAppConfigChanges: function(component, event, helper) {
		helper.updateAppConfigChanges(component, event);
    },
    
    navClickEvtHandler: function(component, event, helper) {
		helper.checkNavigationSelection(component, event);
    }
})