({
    onInit : function(component, event, helper) {
        window.addEventListener("load", function() {
            console.log('***Testing');
        });
    },
    
    onloadDocument : function(component, event, helper) {
        
    },
    
	submitClickEvtHandler : function(component, event, helper) {
		helper.getApplicationDetails(component);
	}
})