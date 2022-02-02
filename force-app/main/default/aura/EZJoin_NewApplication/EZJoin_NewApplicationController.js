({
	onInit : function(component, event, helper) {
        helper.checkApplicationType(component);        
	},
    
    getAppConfigChanges: function(component, event, helper) {
		helper.handleAppConfigChanges(component, event);
    },
    
    backToHomeEvtHandler: function(component, event, helper) {
        window.location = '/eProcess';
    },
    
    loadComponentEvent: function(component, event, helper) {
        console.log('****Load Component');
    	helper.loadComponent(component, event);
    }
})