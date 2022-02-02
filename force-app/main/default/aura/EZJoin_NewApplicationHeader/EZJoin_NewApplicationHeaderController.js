({
	onInit : function(component, event, helper) {
        var appTypes = {'PersonalAssistant': 'as a Personal Assistant', 'OfficeSecretary': 'as an Office Secretary', 'Agent': 'as an Agent', 'AssociateBroker': 'as an Associate Broker'};
        var currentUrl = new URL(window.location);
        var appType = currentUrl.searchParams.get("type");  
        var appSubType = currentUrl.searchParams.get("subtype");
        if(appType != '' && appType != null) {
        	component.set('v.applicationType', appTypes[appType]);	
        }
        
        if(appSubType != null && appSubType != '') {
            component.set('v.applicationType', appTypes[appSubType]);
        }
        
        let url = window.location.pathname;
        if(url.includes('EZJoin_ApplicationDetails')) {
            component.set('v.isApplicationProgress', true);
            component.set('v.progress', 1);
        }
        else if(url.includes('EZJoin_CreateLogin')) {
            component.set('v.isApplicationProgress', true);
            component.set('v.progress', 2);            
        }
        else if(url.includes('EZJoin_ApplicationPayment')) {
            component.set('v.isApplicationProgress', true);
            component.set('v.progress', 3);            
        }        
	},
    
    getAppConfigChanges: function(component, event, helper) {
        var appConfig = JSON.parse(JSON.stringify(event.getParam("applicationConfig"))); 
        var appData = JSON.parse(JSON.stringify(event.getParam("applicationData")));
        
        var completed = 0;
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].status == 'Completed') {
                completed++;
            }
        }

		component.set('v.statusPercent', Math.ceil((completed/appConfig.length) * 100));        
    },

    logoClickEvtHandler: function(component, event, helper) {        
        window.location = '/eProcess';
    }    
})