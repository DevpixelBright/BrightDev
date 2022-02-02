({
    doInit : function(component, event, helper){
        var action = component.get('c.getTemplateList');
        action.setParams({url: component.get('v.emailParams')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.emailList', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})