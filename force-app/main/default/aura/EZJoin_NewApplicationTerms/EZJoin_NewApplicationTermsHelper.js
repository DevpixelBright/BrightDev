({
    initializeAppData: function(component) {
        var appConfig = JSON.parse(JSON.stringify(component.get('v.appConfig')));
        var appData = JSON.parse(JSON.stringify(component.get('v.appData')));
        console.log('***Init term', appData);
        var currentConfig = null;
        
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationTerms') {
                appConfig[i].status = 'In Progress';
                currentConfig = appConfig[i];
                break;
            }
        } 
        currentConfig.status = 'In Progress';
        component.set('v.currentConfig', currentConfig);
        
        if(appData.acceptTerms == undefined) {
            appData['acceptTerms'] = false;
        }
        
		component.set('v.appData', appData);
        console.log('***Init after'+appData);
        component.set('v.appConfig', appConfig);
    },
    
    updateTermsValue: function(component, event) {
        var appData = component.get('v.appData');
        appData.acceptTerms = !appData.acceptTerms;
        component.set('v.appData', appData)
        console.log(appData);
    },
    
    validateSubmission: function(component, event) {
        var appData = JSON.parse(JSON.stringify(component.get('v.appData')));
        var helper = this;
        var currentConfig = component.get("v.currentConfig");
        //console.log('currentConfig---'+ JSON.stringify(component.get("v.currentConfig")));
        if(!appData.acceptTerms) {
            component.set('v.errorMsg', 'Please read and accept the terms and conditions');
            window.scrollTo(0, 0);
        }else if(currentConfig && (currentConfig.applicationType == 'Agent' || currentConfig.applicationType == 'AssociateBroker')){
            var action = component.get("c.getDuplicateSubscriptions");
            action.setParams({
                phoneStr: component.get("v.appData.contact.phone"),
                mobileStr: component.get("v.appData.contact.mobile"),
                emailStr: component.get("v.appData.contact.email")
            }); 
            //console.log('params---'+JSON.stringify(action.getParams()));
            action.setCallback(this, function(response) {
                var state = response.getState();
                //console.log('state------'+state);
                if (state === "SUCCESS") 
                {
                    var response = response.getReturnValue();
                    console.log("From server: " + response);
                    if(response && response.length>0){
                       component.set('v.dupSubscripErrorMsg', 'Our records indicate that you already have a subscription with Bright MLS.  You will need to <a href="https://dev-mrisonboarding.cs10.force.com/eProcess/EZJoin_Reactivate">Reactive Your Existing Subscription</a> online. If you do not know your Bright Subscription ID, please call our Customer Support Center at 1-844-55-BRIGHT (1-844-552-7444) for assistance.'); 
                    }else{
                        helper.handleSubmission(component, event);
                    }
                }else{
                    console.log("Error message: " + response.getError()[0].message);
                }
            });
            $A.enqueueAction(action);
        }else{
            helper.handleSubmission(component, event);
        }
    },
    
	handleSubmission : function(component, event) {
        var appConfig = component.get('v.appConfig');
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationTerms') {
                appConfig[i].status = 'Completed';
                break;
            }
        }
        component.set('v.appConfig', appConfig);
        this.fireApplicationEvent(component);
    },
    
    fireApplicationEvent: function(component) {
        var applicationEvent  = $A.get("e.c:EZJoin_NewApplicationAppConfigEvent");
        applicationEvent.setParams({
            'currentCmp': 'EZJoin_NewApplicationTerms',
            'applicationConfig': component.get('v.appConfig'),
            'applicationData': component.get('v.appData')
        });
        applicationEvent .fire(); 
    },
    
    checkTermsScroll : function(component) {
        let offset = document.getElementById('terms-div').offsetHeight;
        let scrollTop = document.getElementById('terms-div').scrollTop;
        let scrollHeight = document.getElementById('terms-div').scrollHeight;
        if(offset + scrollTop >= scrollHeight) {
            component.set('v.enableTerms', true);
        }
    },
    
    gotoPrevious : function(component, event) {
        var index = 0;
        let appConfig = component.get('v.appConfig');
        
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationTerms') {
                index = i;
                break;
            }
        }         
        
        if(index > 0) {
            var cmpEvent = component.getEvent("cmpEvent");
            cmpEvent.setParams({
                'cmpName' : appConfig[index-1].responsibleComponent,
                'index': index-1
            });
            cmpEvent.fire();            
        }      
    }    
})