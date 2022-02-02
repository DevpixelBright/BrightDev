({
	updateAppConfigChanges : function(component, event) {
        var appConfig = JSON.parse(JSON.stringify(event.getParam("applicationConfig"))); 
        var appData = JSON.parse(JSON.stringify(event.getParam("applicationData")));
        component.set('v.appConfig', appConfig);		
	},
    
    checkNavigationSelection: function(component, event) {
        var index = event.currentTarget.getAttribute('data-index');
        let appConfig = component.get('v.appConfig');
        let currentSelection = appConfig[index];
        
        if(currentSelection.status == 'Completed') {
            this.fireComponentEvent(component, event, currentSelection.responsibleComponent, index);
        }
    },
    
    fireComponentEvent : function(component, event, cmpName, index) {
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            'cmpName' : cmpName,
            'index': index
        });
        cmpEvent.fire();
    }    
})