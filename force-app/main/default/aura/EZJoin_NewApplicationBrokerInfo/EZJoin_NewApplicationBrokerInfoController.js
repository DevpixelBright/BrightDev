({
	onInit : function(component, event, helper) {
        helper.initializeAppData(component);
	},
    
    submitBtnHandler: function(component, event, helper) {
        helper.validateSubmission(component, event);
    },
    
    handleComponentEvent: function(component, event, helper) {
        helper.autoCompleteResponseHandler(component, event);
    },
    
    deleteAgentEvtHandler: function(component, event, helper) {
        helper.deleteAgentFromList(component, event);
    },
    
    handleClearEvent : function(component, event, helper) {
        helper.autoCompleteClearHandler(component, event);
    }
})