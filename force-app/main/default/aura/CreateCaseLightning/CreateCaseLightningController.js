({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.initiliseCase");
        action.setCallback(this,function(response) {
            var state = response.getState();
            var initilisedCase = response.getReturnValue();
            //check if result is successfull
            if(state == "SUCCESS") {
                //Reset Form
                var inputCase = component.get("v.inputCase");
                component.set("v.inputCase", response.getReturnValue());
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
        }); 
        $A.enqueueAction(action);               
        
        var rt = component.get("c.getRequestType");
        var requestType = component.find("requestType");
        var rtopts=[];
        rt.setCallback(this, function(a) {
            rtopts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                rtopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            requestType.set("v.options", rtopts);    
        });
        $A.enqueueAction(rt);
        
        var cc = component.get("c.getCURECustomer");
        var cureCustomer = component.find("cureCustomer");
        var ccopts=[];
        cc.setCallback(this, function(a) {
            ccopts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                ccopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            cureCustomer.set("v.options", ccopts);    
        });
        $A.enqueueAction(cc);
        
        /*
        var cc = component.get("c.getCURECustomer");
        var cureCustomer = component.find("cureCustomer");
        var ccopts=[];
        var inputCase = component.get("v.inputCase"); 
        inputCase.sobjectType  = 'Case'; 
        if(inputCase.CURE_Group__c == 'WIREX'){
            
            ccopts.push({"class": "optionClass",label: "Multiple" , value: "Multiple" });
                         ccopts.push({"class": "optionClass",label: "MET" ,value: "MET" });
                         ccopts.push({"class": "optionClass",label: "RANW" ,value: "RANW" });
                         ccopts.push({"class": "optionClass",label: "SCW" ,value: "SCW" });
                         ccopts.push({"class": "optionClass",label: "CWBR" ,value: "CWBR" });
                         ccopts.push({"class": "optionClass",label: "DCBR" ,value: "DCBR" });
                         ccopts.push({"class": "optionClass",label: "MET" ,value: "MET" });
                         ccopts.push({"class": "optionClass",label: "MCBR" ,value: "MCBR" });
                         ccopts.push({"class": "optionClass",label: "NWW" ,value: "NWW" });
                         ccopts.push({"class": "optionClass",label: "SAAR" ,value: "SAAR" });
                         ccopts.push({"class": "optionClass",label: "WWRA" ,value: "WWRA" });
                        }
                         if(inputCase.CURE_Group__c == 'CARETS'){
                         
                         ccopts.push({"class": "optionClass",label: "Multiple" ,value: "Multiple" });
                         ccopts.push({"class": "optionClass",label: "CLAW" ,value: "CLAW" });
                         ccopts.push({"class": "optionClass",label: "COOP" ,value: "COOP" });
                         ccopts.push({"class": "optionClass",label: "CRISNET" ,value: "CRISNET" });
                         ccopts.push({"class": "optionClass",label: "ITECH" ,value: "ITECH" });
                         ccopts.push({"class": "optionClass",label: "PALM" ,value: "PALM" });
                         ccopts.push({"class": "optionClass",label: "VCRDS" ,value: "VCRDS" });
                        }
                         if(inputCase.CURE_Group__c == 'GLR'){
                         
                         ccopts.push({"class": "optionClass",label: "Multiple" ,value: "Multiple" });
                         ccopts.push({"class": "optionClass",label: "MISPE" ,value: "MISPE" });
                         ccopts.push({"class": "optionClass",label: "RCO" ,value: "RCO" });
                         ccopts.push({"class": "optionClass",label: "AAABOR" ,value: "AAABOR" });
                         ccopts.push({"class": "optionClass",label: "DRAR" ,value: "DRAR" });
                         ccopts.push({"class": "optionClass",label: "FAAR" ,value: "FAAR" });
                         ccopts.push({"class": "optionClass",label: "HCBR" ,value: "HCBR" });
                         ccopts.push({"class": "optionClass",label: "JAAR" ,value: "JAAR" });
                         ccopts.push({"class": "optionClass",label: "LCAR" ,value: "LCAR" });
                         ccopts.push({"class": "optionClass",label: "MCAR" ,value: "MCAR" });
                         ccopts.push({"class": "optionClass",label: "SAOR" ,value: "SAOR" });
                         ccopts.push({"class": "optionClass",label: "SBR" ,value: "SBR" });
                        }
                         if(inputCase.CURE_Group__c == 'TREND'){
                         
                         ccopts.push({"class": "optionClass",label: "TREND" ,value: "TREND" });
                         
                        }
                         
                         
                         
                         category.set("v.options", ctopts);
                         
                 */        
        var ct = component.get("c.getCategory");
        var category = component.find("category");
        var ctopts=[];
        ct.setCallback(this, function(a) {
            ctopts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                ctopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            category.set("v.options", ctopts);    
        });
        $A.enqueueAction(ct);
        
        var cp = component.get("c.getComponent");
        var component1 = component.find("component1");
        var cpopts=[];
        cp.setCallback(this, function(a) {
            cpopts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                cpopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component1.set("v.options", cpopts);    
        });
        $A.enqueueAction(cp);
        
        var en = component.get("c.getEnvironment");
        var environment = component.find("environment");
        var enopts=[];
        en.setCallback(this, function(a) {
            enopts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                enopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            environment.set("v.options", enopts);    
        });
        $A.enqueueAction(en);
        
        var rl = component.get("c.getReload");
        var reload = component.find("reload");
        var rlopts=[];
        rl.setCallback(this, function(a) {
            rlopts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                rlopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            reload.set("v.options", rlopts);    
        });
        $A.enqueueAction(rl);
        
        var im = component.get("c.getImpact");
        var impact = component.find("impact");
        var imopts=[];
        im.setCallback(this, function(a) {
            imopts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                imopts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            impact.set("v.options", imopts);    
        });
        $A.enqueueAction(im);
        
        var ur = component.get("c.getUrgency");
        var urgency = component.find("urgency");
        var uropts=[];
        ur.setCallback(this, function(a) {
            uropts.push({"class": "optionClass", label: "-- None --", value: ""});
            for(var i=0;i< a.getReturnValue().length;i++){
                uropts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            urgency.set("v.options", uropts);    
        });
        $A.enqueueAction(ur);
    },
    
	onChangeFunction : function(cmp,event) {
       var toggleField = cmp.find("details");
       var toggleLabel = cmp.find("detailsLabel");
        if(event.getSource().get("v.value") == 'No') {
           $A.util.addClass(toggleField, "toggle");
           $A.util.addClass(toggleLabel, "toggle");
           cmp.set('v.inputCase.Reload_Details__c', '');
        }
        else {
           $A.util.removeClass(toggleField, "toggle");
           $A.util.removeClass(toggleLabel, "toggle");
        }
    }, 
    
    create : function(component, event, helper) {

		var hasError = false;        
		var inputCmp = component.find("requestType");
        var value = inputCmp.get("v.value");
        if(value == null || value == '') {
            inputCmp.set("v.errors", [{message:"Complete this field"}]);
            hasError = true;
        }else{
            inputCmp.set("v.errors", null);
        }
		inputCmp = component.find("subject");
        value = inputCmp.get("v.value");
        if(value == null || value == '') {
            inputCmp.set("v.errors", [{message:"Complete this field"}]);
            hasError = true;
        } else{
            inputCmp.set("v.errors", null);
        }
        inputCmp = component.find("cureCustomer");
        value = inputCmp.get("v.value");
        if(value == null || value == '') {
            inputCmp.set("v.errors", [{message:"Complete this field"}]);
            hasError = true;
        }else{
            inputCmp.set("v.errors", null);
        }
        inputCmp = component.find("category");
        value = inputCmp.get("v.value");
        if(value == null || value == '') {
            inputCmp.set("v.errors", [{message:"Complete this field"}]);
            hasError = true;
        } else{
            inputCmp.set("v.errors", null);
        }
        inputCmp = component.find("component1");
        value = inputCmp.get("v.value");
        if(value == null || value == '') {
            inputCmp.set("v.errors", [{message:"Complete this field"}]);
            hasError = true;
        }else{
            inputCmp.set("v.errors", null);
        }
        inputCmp = component.find("environment");
        value = inputCmp.get("v.value");
        if(value == null || value == '') {
            inputCmp.set("v.errors", [{message:"Complete this field"}]);
            hasError = true;
        } else{
            inputCmp.set("v.errors", null);
        }
        inputCmp = component.find("reload");
        value = inputCmp.get("v.value");
        if(value == null || value == '') {
            inputCmp.set("v.errors", [{message:"Complete this field"}]);
            hasError = true;
        }else{
            inputCmp.set("v.errors", null);
        }
        
        if(hasError)
            return;
        
        console.log('Create record');
        
        //getting the candidate information
        var inputCase = component.get("v.inputCase"); 
        inputCase.sobjectType  = 'Case'; 
        if(inputCase.Reload_Data_Refresh__c == 'Yes' && ($A.util.isEmpty(inputCase.Reload_Details__c) || $A.util.isUndefined(inputCase.Reload_Details__c))){
            alert('Reload Details should be filled when Reload/Data Refresh is Yes');
            return;
        } 
        
        console.log(inputCase);
        //Calling the Apex Function
        var action = component.get("c.createRecord");
        
        //Setting the Apex Parameter
        action.setParams({
            inputCase : inputCase
        });
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                //Reset Form                
                alert(a.getReturnValue());
                component.set("v.parentId", a.getReturnValue());
                console.log("v.parentId");
                component.saveAtt();
            } else if(state == "ERROR"){
                alert(a.getError());
                console.log(a.getError());
            }
        });
        
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
        
    },
    
    save2 : function(component, event, helper) {
        console.log("before attachment save");
        helper.savefile(component);
        console.log("after attachment save");
    },
    
    waiting: function(component, event, helper) {
        $A.util.addClass(component.find("uploading").getElement(), "uploading");
        $A.util.removeClass(component.find("uploading").getElement(), "notUploading");
    },
    
    doneWaiting: function(component, event, helper) {
        $A.util.removeClass(component.find("uploading").getElement(), "uploading");
        $A.util.addClass(component.find("uploading").getElement(), "notUploading");
    }
})