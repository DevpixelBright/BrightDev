({
	onInit : function(component, event, helper) {
        helper.getApplicationId(component);        
	},
    
	checkAvailabilityEvtHandler : function(component, event, helper) {
		helper.validateLoginName(component);
	},
    
    loginNameChangeEvtHandler : function(component, event, helper) {
        helper.resetDefaults(component);
    },
    
    submitBtnEvtHandler : function(component, event, helper) {
        helper.createNewSubscription(component);
    }
})