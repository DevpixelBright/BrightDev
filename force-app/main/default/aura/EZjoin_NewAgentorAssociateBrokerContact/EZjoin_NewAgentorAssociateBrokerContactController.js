({
	onInit : function(component, event, helper) {
        console.log('***', component.get('v.salutations'));
        helper.initializeAppData(component);
        helper.getSalutationValues(component);
        helper.getSuffixValues(component);
	},
    
    submitBtnHandler: function(component, event, helper) {
        helper.validateSubmission(component, event);
    },
    
    confirmEmailBlurHandler : function(component, event, helper) {
        helper.checkEmailsMatch(component, event);
    },
    
    previousBtnEvtHandler : function(component, event, helper) {
        helper.gotoPrevious(component, event);
    }
})