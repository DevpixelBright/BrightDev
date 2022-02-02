({
	appealFormData : function(component) {
		var action = component.get("c.formController");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var objValue = response.getReturnValue();
                console.log("ComplianceForm-: ", objValue);
            }
        });
        $A.enqueueAction(action);
	}
})