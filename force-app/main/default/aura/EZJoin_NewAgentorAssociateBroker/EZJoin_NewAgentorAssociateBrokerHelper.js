({
    initializeAppData: function(component) {
        var appConfig = JSON.parse(JSON.stringify(component.get('v.appConfig')));
        var appData = JSON.parse(JSON.stringify(component.get('v.appData')));
        var currentConfig = null;
        component.set('v.appType', appConfig[0].applicationType);
        
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationBrokerInfo') {
                appConfig[i].status = 'In Progress';
                currentConfig = appConfig[i];
                break;
            }
        } 

        currentConfig.status = 'In Progress';
        component.set('v.currentConfig', currentConfig);

        var data = {};
        var isNew = false;
        if(appData.broker == undefined) {
            data['broker'] = {};
            isNew = true;
        }
        else
            component.set('v.brokerCode', appData.broker);
        
        if(appData.agents == undefined)
            data['agents'] = [];
        else
            component.set('v.agents', appData.agents);        
        
        if(isNew)
			component.set('v.appData', data);
        component.set('v.appConfig', appConfig);
    },
    
    validateSubmission: function(component, event) {
        let brokerSelected = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
        let agentsSelected = JSON.parse(JSON.stringify(component.get('v.agents')));
        let appType = component.get('v.appType');
        
        if(brokerSelected.Id == undefined) {
            component.set('v.errorMsg', 'Missing broker code');
            return;
        }
        
        if(appType == 'PersonalAssistant') {
            if(agentsSelected.length == 0) {
                component.set('v.errorMsg', 'Please select atleast one agent');
                return;
            }
        }
        
        this.handleSubmission(component, event);
    },
    
	handleSubmission : function(component, event) {
        var appData = component.get('v.appData');
        var agents = JSON.parse(JSON.stringify(component.get('v.agents')));
        var brokerCode = component.get('v.brokerCode');
        
        if(brokerCode.Type == 'Appraiser') {
            agents.splice(1, 1);
        }
        
        appData.broker = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
        appData.agents = agents;
        component.set('v.appData', appData);
        
        var currentConfig = component.get('v.currentConfig');
        currentConfig.status = 'Completed';
        
        var appConfig = component.get('v.appConfig');
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == 'EZJoin_NewApplicationBrokerInfo') {
                appConfig[i] = currentConfig;
                break;
            }
        }
        component.set('v.appConfig', appConfig);
        this.fireApplicationEvent(component);
    },
    
    fireApplicationEvent: function(component) {
        var applicationEvent  = $A.get("e.c:EZJoin_NewApplicationAppConfigEvent");
        applicationEvent.setParams({
            'currentCmp': 'EZJoin_NewApplicationBrokerInfo',
            'applicationConfig': component.get('v.appConfig'),
            'applicationData': component.get('v.appData')
        });
        applicationEvent.fire();        
    },
    
    autoCompleteResponseHandler: function(component, event) {
        var type = event.getParam('cmpType');
        var obj = event.getParam('objSelected');
		component.set('v.errorMsg', '');
        
        if(type == 'BrokerCode') {
        	component.set('v.brokerCode', JSON.parse(JSON.stringify(obj)));
        }
        else if(type == 'Agents' || type == 'Appraiser') {
            var agents = component.get('v.agents');
            if(agents.length < 5) {
                agents.push(JSON.parse(JSON.stringify(obj)));
                component.set('v.agents', agents);
            }
            else {
                component.set('v.errorMsg', 'You can add upto 5 agents only');
                window.scrollTo(0, 0);
            }
        }
    },
    
    autoCompleteClearHandler: function(component, event) {
        var type = event.getParam('cmpType');
        if(type == 'BrokerCode') {
            component.set('v.brokerCode', {});
            component.set('v.agents', []);

            if(document.getElementById('combobox-id-21-Agents')) {
                document.getElementById('combobox-id-21-Agents').value = '';
            }
            if(document.getElementById('combobox-id-21-Appraiser')) {
                document.getElementById('combobox-id-21-Appraiser').value = '';
            }
            
            component.set('v.reload', false);
            component.set('v.reload', true);
        }
        else if(type == 'Appraiser') {
            component.set('v.agents', []);
        }
    },    
    
    deleteAgentFromList: function(component, event) {
        var index = event.target.getAttribute('data-index');
        var agents = component.get('v.agents');
        agents.splice(index, 1);
        component.set('v.agents', agents);     
    }
})