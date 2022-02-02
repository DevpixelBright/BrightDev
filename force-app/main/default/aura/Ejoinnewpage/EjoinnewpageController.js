({
	submitBtnEvtHandler : function(component, event, helper) {
        var action = component.get("c.method1");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('***state:', state);
            console.log('***state:', response.getReturnValue());
            if(state == 'ERROR') {
                var errors = response.getError();
                let message = 'ERROR: ';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = message + errors[0].message;
                }
                console.log(message);                
            }

        });
        
        $A.enqueueAction(action);  		
	}   
})