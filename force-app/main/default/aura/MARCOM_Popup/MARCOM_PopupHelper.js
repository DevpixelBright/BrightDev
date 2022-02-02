({
    getTemplateDetails : function(component, event, helper) {
        var action = component.get("c.getEmailDetails");
        action.setParams({ 
            EmailId : component.get('v.emailTemplateId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                helper.processBody(component, resp);
                component.set('v.emailDetails', resp);
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
    },
    
    getEmailNotes : function(component, event, helper) {
        var action = component.get("c.getNotes");
        action.setParams({ 
            EmailId : component.get('v.emailTemplateId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.notes', response.getReturnValue());
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
    },
    
    getStatusValues : function(component, event, helper) {
        var action = component.get("c.getPicklist");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.options', response.getReturnValue());
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
    },
    
    processBody : function(component, resp){
        if(resp.HtmlValue && resp.HtmlValue != null && resp.HtmlValue != ""){
            var ref = resp.HtmlValue.match(/{!\$Label.(.*?)}/g);
            var labels = resp.HtmlValue.match(/{!\$Label.(.*?)}/g);
            if(labels && labels != null && labels.length > 0){
                for(var i = 0; i< labels.length; i++){
                    labels[i] = labels[i].replace('$Label', '$Label.c')
                }
                for(var i = 0; i< labels.length; i++){
                    labels[i] = labels[i].replace('{!', '')
                    labels[i] = labels[i].replace('}', '')
                }
                for(var i = 0; i< labels.length; i++){
                    var labelReference = $A.getReference(labels[i]);
                    component.set("v.tempLabelAttr", labelReference);
                    var dynamicLabel = component.get("v.tempLabelAttr");
                    console.log(ref[i], dynamicLabel);
                    resp.HtmlValue = resp.HtmlValue.replace(ref[i], dynamicLabel);
                }
            }
        }
    }
})