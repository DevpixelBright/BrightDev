({
	onInit : function(component, event, helper) {
        helper.getSubscriptionId(component);        
	},
    
    editBtnClickEvtHandler : function(component, event, helper) {
        component.set('v.isEdit', true);       
    },
    
    handleComponentEvent: function(component, event, helper) {
        helper.autoCompleteResponseHandler(component, event);
    },

    handleClearEvent : function(component, event, helper) {
        helper.autoCompleteClearHandler(component, event);
    },

    deleteAgentEvtHandler: function(component, event, helper) {
        helper.deleteAgentFromList(component, event);
    },

    submitBtnHandler : function(component, event, helper) {
        helper.validateSubmission(component, event);
    },
    
    cancelEvtHandler : function(component, event, helper) {
        window.location = '';
    },
    
    backToHomeEvtHandler : function(component, event, helper) {
       window.location = '/eProcess';
    },
    
    confirmYesEvtHandler : function(component, event, helper) {
        helper.clearBrokerCode(component);
    },
    
    confirmCancelEvtHandler : function(component, event, helper) {
        helper.cancelClearingBrokerCode(component);
    },
    
    viewApplicationEvtHandler : function(component, event, helper) {
      window.location = '/eProcess/EZJoin_ApplicationDetails?Id=' + component.get('v.prevApplicationId');
    }
})