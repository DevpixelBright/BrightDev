({
    checkApplicationType: function(component) {
        var url = new URL(window.location);
        var appType = url.searchParams.get("type"); 
        
        if(appType == 'AssociateBroker')
            appType = 'Agent';
        
        if(appType != null && appType != '') {
            component.set('v.applicationType', appType);
            this.setupTestAppConfig(component);		
        }
        else {
            window.location = '/eProcess';
        }
    },
    
    setupTestAppConfig : function(component) {
        let appStructureObj = [
            {
                'name': 'Step 1:',
                'description': (component.get('v.applicationType') == 'PersonalAssistant' ? 'Verify the broker code and select agent(s)' : (component.get('v.applicationType') == 'Agent' ? 'Enter your State Real Estate License information, Broker code and Association Affiliation' : 'Enter the broker code')),
                'status': 'In Progress',
                
                'responsibleComponent': component.get('v.applicationType') == 'Agent'? 'Ezjoin_NewAgentorAssociateBrokerLicense': 'EZJoin_NewApplicationBrokerInfo',
                'applicationType': component.get('v.applicationType'),
                'isInitial': true
            },
            {
                'name': 'Step 2:',
                'description': 'Fill in the required contact information',
                'status': 'Not Started',
                'responsibleComponent': 'EZJoin_NewApplicationContactInfo',
                'applicationType': component.get('v.applicationType'),
                'isInitial': false
            },
            {
                'name': 'Step 3:',
                'description': 'Review application, license agreement and submit',
                'status': 'Not Started',
                'responsibleComponent': 'EZJoin_NewApplicationTerms',
                'applicationType': component.get('v.applicationType'),
                'isInitial': false
            }           
        ];
        
        component.set('v.cmpStructure', appStructureObj);
        this.loadInitialComponent(component);
    },
    
    loadInitialComponent: function(component) {
        var appConfig = component.get('v.cmpStructure');
        var cmpName = '';
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].isInitial) {
                cmpName = appConfig[i].responsibleComponent;
                break;
            }
        }		
        this.initializeComponent(component, cmpName);
    },
    
    handleAppConfigChanges: function(component, event) {
        var appConfig = JSON.parse(JSON.stringify(event.getParam("applicationConfig"))); 
        var appData = JSON.parse(JSON.stringify(event.getParam("applicationData")));
        var currentCmp = event.getParam("currentCmp");
        component.set('v.cmpStructure', appConfig);
        component.set('v.applicationData', appData);
        
        var nextCmpName = '';
        var nextIndex = 0;
        var isSubmit = false;
        for(var i=0; i<appConfig.length; i++) {
            if(appConfig[i].responsibleComponent == currentCmp) {
                if(i < appConfig.length-1) {
                    nextCmpName = appConfig[i+1].responsibleComponent;
                    nextIndex = i + 1;
                    break;
                }
                else if(i == appConfig.length-1) {
                    isSubmit = true;
                }
            }
        }
        
        if(!isSubmit) {
            appConfig[nextIndex].status = 'In Progress';
            component.set('v.applicationConfig', appConfig);
            this.initializeComponent(component, nextCmpName);
        }
        else {
            this.submitNewApplication(component);
        }
    },
    
    initializeComponent: function(component, cmpName) {
        component.set('v.showSpinner', true);
        $A.createComponent('c:' + cmpName, {
            'appConfig': component.get('v.cmpStructure'),
            'appData': component.get('v.applicationData')
        }, function attachModal(modalCmp, status) {
            if (component.isValid() && status === 'SUCCESS') {
                var body = component.get("v.body");
                body.push(modalCmp);
                component.set("v.body", modalCmp); 
                component.set('v.showSpinner', false);
            }
        });         
    },
    
    submitNewApplication: function(component) {
        debugger;
        component.set('v.showSpinner', true);
        var appData = JSON.parse(JSON.stringify(component.get('v.applicationData')));
        var newApplication = JSON.parse(JSON.stringify(component.get('v.application')));
        
        var currentUrl = new URL(window.location);
        var type = currentUrl.searchParams.get("type");
        if(type == 'AssociateBroker')
            newApplication.License_Type__c = 'Associate Broker';
        else if(component.get('v.applicationType') == 'Agent')
            newApplication.License_Type__c = 'Salesperson';
        
        newApplication.First_Name__c = appData.contact.firstName;
        newApplication.Last_Name__c = appData.contact.lastName;
        newApplication.Middle_Name__c = appData.contact.middleName;
        newApplication.Mobile_Phone__c = appData.contact.phone;
        if(appData.contact.nickName != '') {
            newApplication.Nickname__c = appData.contact.nickName;
        }
        else {
            newApplication.Nickname__c = appData.contact.firstName;
        }
        newApplication.Suffix__c= appData.contact.suffix;
        newApplication.Company_Code__c = appData.broker.Id;
        newApplication.Primary_Phone__c = appData.contact.phone;
        newApplication.Private_Email__c = appData.contact.email;
        newApplication.Private_Phone__c = appData.contact.phone;
        if(appData.contact.mobile != '' && appData.contact.mobile != null) {
            newApplication.Mobile_Phone__c = appData.contact.mobile;
        }
        else {
            newApplication.Mobile_Phone__c = appData.contact.phone;
        }
        newApplication.Public_Email__c = appData.contact.email;
        newApplication.Salutation__c = appData.contact.salutation;
        newApplication.State__c = appData.broker.State__c;
        newApplication.City__c = appData.broker.City__c;
        newApplication.Zip__c = appData.broker.Zip__c;
        newApplication.Status__c = 'New'; 
        newApplication.Service_Jurisdiction__c = 'BRIGHT';
        newApplication.Application_Type__c = 'New Agent';
        
        if(appData.license != undefined) {
            newApplication.License_Expiration_Date__c = appData.license.licenseExpirationDate;
            newApplication.License_State__c = appData.license.licenseState;
            newApplication.License_Number__c = appData.license.licenseNumber;
            newApplication.NRDS_ID__c  = appData.license.nrdsId;
        }
        
        if(appData.association != undefined && appData.association.Id != undefined) {
            newApplication.Association_Board_Affiliation__c = appData.association.Id;
        }
        
        if(appData.agents != undefined) {
            if(appData.agents.length > 0) {
                var agentsList = [];
                for(var i=0; i<appData.agents.length; i++) {
                    var agent = appData.agents[i];
                    agentsList.push({'name':agent.Contact__r.Name, 'agentId':agent.Name});
                }
                newApplication.Related_Agents__c = JSON.stringify(agentsList);
            }
        }
        
        var action = component.get("c.submitApplication");
        action.setParams({
            'application' : newApplication,
            'acc': appData.broker,
            'applicationType': component.get('v.applicationType')
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('***response:', response);
                component.set('v.applicationId', response.Name);
                component.set('v.showSuccess', true);
            } 
            else {
                console.log("Something went wrong!! Check server logs!!");
            }
        });
        $A.enqueueAction(action);        
    },
    
    loadComponent: function(component, event) {
        var appConfig = component.get('v.cmpStructure');
        var cmpName = event.getParam('cmpName'); 
        var index = parseInt(event.getParam('index')); 
        appConfig[index].status = 'In Progress';
        
        for(var i=index+1; i<appConfig.length; i++) {
            appConfig[i].status = 'Not Started';
        }        
        component.set('v.cmpStructure', appConfig);
        this.initializeComponent(component, cmpName);
    }
})