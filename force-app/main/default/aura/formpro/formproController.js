({
	getAppealFormData : function(component, event, helper) {
		helper.appealFormData(component);
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	component.set('v.today', today);
	},
    
    saveAppealForm: function(component, event, helper) {
        var appealFormObj = component.get("v.appealFormObj");
        console.log('appealFormObj**-: ' , appealFormObj);
    }
})