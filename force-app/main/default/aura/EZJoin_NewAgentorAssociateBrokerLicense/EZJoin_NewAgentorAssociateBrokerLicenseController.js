({
	onInit : function(component, event, helper) {
        helper.initializeAppData(component);
        helper.getStateValues(component);
        },
    
    submitBtnHandler: function(component, event, helper) {
        helper.validateSubmission(component, event);
    },
    
    confirmEmailBlurHandler : function(component, event, helper) {
        helper.checkEmailsMatch(component, event);
    },
    
    previousBtnEvtHandler : function(component, event, helper) {
        helper.gotoPrevious(component, event);
    },
    
    handleClearEvent : function(component, event, helper) {
        helper.autoCompleteClearHandler(component, event);
    }
})