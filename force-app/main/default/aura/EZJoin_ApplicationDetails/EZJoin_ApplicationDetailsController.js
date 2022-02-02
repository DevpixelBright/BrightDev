({
	onInit : function(component, event, helper) {
        helper.getApplicationId(component);        
	},
    
    createLoginBtnEvtHandler : function(component, event, helper) {
       window.location = '/eProcess/EZJoin_CreateLogin?Id=' + component.get('v.application').Name;
    },
    
    reviewBtnEvtHandler : function(component, event, helper) {
        window.location = '/eProcess/EZJoin_ApplicationPayment?Id=' + component.get('v.application').Name;
    },
    
    ezjoinLandingBtnHandler : function(component, event, helper) {
            window.location = '/eProcess';
    }
})