({
    onInit : function(component, event, helper) {
        helper.initializeAppData(component);
	},
    
    termsChkBoxEvtHandler: function(component, event, helper) {
        helper.updateTermsValue(component, event);
    },
    
    submitBtnHandler: function(component, event, helper) {
        helper.validateSubmission(component, event);
    },
    
    scrolled : function(component, event, helper) {
		helper.checkTermsScroll(component)        
    },
    
    previousBtnEvtHandler : function(component, event, helper) {
        helper.gotoPrevious(component, event);
    }    
})