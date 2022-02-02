({
	onInit : function(component, event, helper) {
        helper.getApplicationId(component);
        window.addEventListener("message", $A.getCallback(function(event) {
            let msg = JSON.parse(event.data);
            if(msg.operation == 'generic_payment_cancel') {
                component.set('v.showIFrame', false);
                component.set('v.iFrameUrl', '');
            }
            else if(msg.operation == 'payment_success') {
                helper.updateSubscription(component);
            }
            else if(msg.operation == 'generic_payment_complete') {
                helper.closeOrderModal(component);
            }            
        }), false);        
	},
    
    makePaymentBtnEvtHandler : function(component, event, helper) {
        helper.setupOrder(component);
    },
    
    backToHomeEvtHandler : function(component, event, helper) {
      s
            window.location = '/eProcess';
    }
})