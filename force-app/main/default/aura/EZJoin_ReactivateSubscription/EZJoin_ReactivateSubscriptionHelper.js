({
    getSubscriptionId : function(component) {
        component.set('v.showSpinner', true);
        var currentUrl = new URL(window.location);
        var subscriptionId = currentUrl.searchParams.get("Id");
        //var subscriptionId = window.location.search.substring(1).replace('Id=', '');
        if(subscriptionId == '') {
            window.location = '/eProcess/EZJoin_Reactivate';
            return;
        }
        else {        
            this.getSubscriptionDetails(component, subscriptionId);
            this.getSalutationValues(component);
            this.getSuffixValues(component);
        }
    },
    
	getSubscriptionDetails : function(component, subscriptionId) { 
        var currentUrl = new URL(window.location);
        
        component.set('v.showSpinner', true);
        var action = component.get("c.getSubscriptionDetails");
        action.setParams({
            'subscriptionId' : subscriptionId
        });
        
        action.setCallback(this, function(response) {
            component.set('v.showSpinner', false);
            var state = response.getState();
            if (state === 'SUCCESS') {
                var reinstateRecord = response.getReturnValue();
                console.log('***reinstateRecord:', reinstateRecord);

                /* Check if subscription is valid or not */
                if(Object.keys(reinstateRecord.subscription).length == 0) {
                    window.location = '/eProcess/EZJoin_Reactivate';
                    return;
                }

                var subscription = reinstateRecord.subscription;
                if(!((subscription.Contact_Type__c == 'Assistant' && (subscription.Subscription_Type__c == 'Personal Assistant' || subscription.Subscription_Type__c == 'Personal Assistant to Appraiser'))
                     || (subscription.Contact_Type__c == 'Staff' && subscription.Subscription_Type__c.includes('Office Secretary'))
                     || (subscription.Contact_Type__c == 'Agent' && (subscription.Subscription_Type__c == 'Licensee/Non Realtor' || subscription.Subscription_Type__c == 'Realtor/Shareholder' || subscription.Subscription_Type__c == 'Realtor/Non Shareholder'))
                     || (subscription.Contact_Type__c == 'Office Manager' && (subscription.Subscription_Type__c == 'Licensee/Non Realtor' || subscription.Subscription_Type__c == 'Realtor/Shareholder' || subscription.Subscription_Type__c == 'Realtor/Non Shareholder')))) {
                    window.location = '/eProcess/EZJoin_Reactivate';
                }                
                
                /* Check already any application exists */
                if(Object.keys(reinstateRecord.application).length > 0) {
                    component.set('v.prevApplicationId', reinstateRecord.application.Name);
                }
                
                /* Create Broker Code as an Account sObjectType */
                var brokerRecord = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
                brokerRecord.Id = reinstateRecord.subscription.Related_Location_Broker_Office__c;
                brokerRecord.Name = reinstateRecord.subscription.Related_Location_Broker_Office__r.Name;
                brokerRecord.Account_Name__c = reinstateRecord.subscription.Related_Location_Broker_Office__r.Account_Name__c;
				brokerRecord.Type = reinstateRecord.subscription.Related_Location_Broker_Office__r.Type;
                
                /* Create agents list as an Susscriptions__c sObjectType */
                var agents = [];
                if(reinstateRecord.subscription.Subscription_Type__c == 'Personal Assistant' || reinstateRecord.subscription.Subscription_Type__c == 'Personal Assistant to Appraiser') {
                    if(reinstateRecord.agents.length > 0) {
                        for(var i=0; i<reinstateRecord.agents.length; i++) {
                            var agent = JSON.parse(JSON.stringify(component.get('v.agent')));
                            agent.Id = reinstateRecord.agents[i].Subscription__c;
                            if(reinstateRecord.agents[i].Subscription__r != undefined) {
                                agent.Name = reinstateRecord.agents[i].Subscription__r.Name;
                                agent.Contact__c = reinstateRecord.agents[i].Subscription__r.Contact__c;                            
                                agent.Contact__r = {'Name': reinstateRecord.agents[i].Subscription__r.Contact__r.Name};
                            }
                            agents.push(agent);
                        }
                    }
                }
                
                /* Get application type based on subscription subtype */
                if(reinstateRecord.subscription.Subscription_Type__c == 'Personal Assistant' || reinstateRecord.subscription.Subscription_Type__c == 'Personal Assistant to Appraiser') {
                    component.set('v.appType', 'PersonalAssistant');
                }
                else if(reinstateRecord.subscription.Subscription_Type__c == 'Office Secretary') {
                    component.set('v.appType', 'OfficeSecretary');
                }
                else if(reinstateRecord.subscription.Subscription_Type__c == 'Agent') {
                    component.set('v.appType', 'Agent');    
                }
                
                component.set('v.subscription', reinstateRecord.subscription);
                component.set('v.agents', agents);
                component.set('v.brokerCode', brokerRecord);
                component.set('v.sublicense', reinstateRecord.sublicense);
                component.set('v.relAssociation', reinstateRecord.relAssociation);
                component.set('v.existingApplication', reinstateRecord.application);
            }
            else if(state == 'ERROR') {
                console.log('Subscription ID does not exist.');
            }
        });
        
        $A.enqueueAction(action);        
	},
    
    getSalutationValues : function(component) {
        var subscription = component.get('v.subscription');
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'objectName' : 'MRIS_Application__c',
            'fieldName': 'Salutation__c'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                component.set('v.salutations', response);
                component.get('v.subscription', subscription);
            } 
        });
        $A.enqueueAction(action);         
    },
    
    getSuffixValues : function(component) {
        var subscription = component.get('v.subscription');
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'objectName' : 'MRIS_Application__c',
            'fieldName': 'Suffix__c'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                component.set('v.suffixes', response);
                component.get('v.subscription', subscription);
            } 
        });
        $A.enqueueAction(action);         
    },

    autoCompleteResponseHandler: function(component, event) {
        var type = event.getParam('cmpType');
        var obj = event.getParam('objSelected');
		component.set('v.errorMsg', '');
        
        if(type == 'BrokerCode') {
        	component.set('v.brokerCode', JSON.parse(JSON.stringify(obj)));
            component.set('v.agents', []);
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
            var agents = JSON.parse(JSON.stringify(component.get('v.agents')));
            var brokerCode = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
            if(agents.length > 0) {
                component.set('v.showConfirm', true);
                component.set('v.tempBrokerCode', brokerCode);
                component.set('v.brokerCode', {});
            }
            else {
				this.clearBrokerCode(component);
            }
        }
        else if(type == 'Appraiser') {
            component.set('v.agents', []);
        }        
    },
    
    clearBrokerCode : function(component) {
        component.set('v.brokerCode', {});
        component.set('v.agents', []);
        component.set('v.showConfirm', false);
        document.getElementById('combobox-id-21-BrokerCode').value = '';
        document.getElementById('combobox-id-21-BrokerCode').readOnly = false;
        try{
        	if(component.get('v.subscription.Subscription_Type__c') && component.get('v.subscription.Subscription_Type__c') == 'Personal Assistant to Appraiser'){
                document.getElementById('combobox-id-21-Appraiser').readOnly = false;
            }    
        }catch(e){}
        
        component.set('v.reload', false);
        component.set('v.reload', true);
    },
    
    cancelClearingBrokerCode : function(component) {
        var brokerCode = component.get('v.tempBrokerCode');
        component.set('v.brokerCode', brokerCode);
        component.set('v.showConfirm', false);
    },

    deleteAgentFromList: function(component, event) {
        var index = event.target.getAttribute('data-index');
        var agents = component.get('v.agents');
        agents.splice(index, 1);
        component.set('v.agents', agents);     
    },
    
    validateSubmission : function(component, event) {
		var isEdit = component.get('v.isEdit');
        
        if(!isEdit) {
            this.validateDirectSubmission(component, event);
            return;
        }
        
        var requiredFields = ['Salutation', 'FirstName', 'LastName', 'Email', 'Phone'];
        var isValid = true;
        for(var i=0; i<requiredFields.length; i++) {
        	var field = component.find(requiredFields[i]); 
            if(!field.get("v.validity").valid) {
                field.showHelpMessageIfInvalid();              
                isValid = false;
            }
        }
        
		var broker = component.get('v.brokerCode');
        if(!broker.Name) {
            isValid = false;
        }

        if(component.get('v.appType') == 'PersonalAssistant') {
            var agents = component.get('v.agents');
            if(agents.length == 0) {
                isValid = false;
            }
        }

        if(isValid) {
        	var mobileField = component.find('Mobile'); 
            if(!mobileField.get("v.validity").valid) {
                mobileField.showHelpMessageIfInvalid();              
                isValid = false;
            }
        }
        
        if(isValid) {        
            this.submitApplication(component, event);       
        }       
    },
    
    validateDirectSubmission : function(component, event) {
        debugger;
        component.set('v.errorMsg', '');
        var contactFields = ['Salutation', 'FirstName', 'LastName'];
        var subscriptionFields = ['Private_Email__c', 'Primary_Phone__c', 'Related_Location_Broker_Office__c', 'Mobile_Phone__c'];
        var isValid = true;
        var subscription = JSON.parse(JSON.stringify(component.get('v.subscription')));
        console.log('***subscription:', subscription);
        
        for(var i=0; i<contactFields.length; i++) {
            if(subscription.Contact__r[contactFields[i]] == undefined) {
                isValid = false;
            }
        }
        
        for(var i=0; i<subscriptionFields.length; i++) {
            if(subscription[subscriptionFields[i]] == undefined) {
                isValid = false;
            }
        }        
        
        if(component.get('v.appType') == 'PersonalAssistant') {
            var agents = component.get('v.agents');
            if(agents.length == 0) {
                isValid = false;
            }
        }        
        
        if(isValid) {
            this.submitApplication(component, event);
        }
        else {
			component.set('v.errorMsg', 'Missing required fields information. Please edit the details and submit the application.');
        }
    },

	submitApplication: function(component, event) {
        debugger;
        component.set('v.showSpinner', true);
        let subscription = JSON.parse(JSON.stringify(component.get('v.subscription')));
        let broker = JSON.parse(JSON.stringify(component.get('v.brokerCode')));
        let agents = JSON.parse(JSON.stringify(component.get('v.agents')));
        let sublicense = JSON.parse(JSON.stringify(component.get('v.sublicense')));
        let relAssociation = JSON.parse(JSON.stringify(component.get('v.relAssociation')));
        var newApplication = JSON.parse(JSON.stringify(component.get('v.application')));
        
        if(subscription.Subscription_Type__c == 'Personal Assistant to Appraiser') {
            agents.splice(1, 1);
        }        
        
        newApplication.First_Name__c = subscription.Contact__r.FirstName;
        newApplication.Last_Name__c = subscription.Contact__r.LastName;
        newApplication.Middle_Name__c = subscription.Contact__r.Middle_Name__c;

        if(subscription.Contact__r.Nickname__c != '') {
            newApplication.Nickname__c = subscription.Contact__r.Nickname__c;
        }
        else {
            newApplication.Nickname__c = subscription.Contact__r.FirstName;
        }
        
        newApplication.Suffix__c = subscription.Contact__r.Suffix__c;
        newApplication.Company_Code__c = broker.Id;
        newApplication.Primary_Phone__c = subscription.Primary_Phone__c;
        newApplication.Private_Email__c = subscription.Private_Email__c;
        newApplication.Private_Phone__c = subscription.Primary_Phone__c;
        if(subscription.Mobile_Phone__c != '' && subscription.Mobile_Phone__c != null) {
        	newApplication.Mobile_Phone__c = subscription.Mobile_Phone__c;
        }
        else {
            newApplication.Mobile_Phone__c = subscription.Primary_Phone__c;
        }
        newApplication.Public_Email__c = subscription.Private_Email__c;
        newApplication.Salutation__c = subscription.Contact__r.Salutation;
        newApplication.State__c = subscription.State__c;
        newApplication.City__c = subscription.City__c;
        newApplication.County__c = subscription.County__c;
        newApplication.Zip__c = subscription.Zip__c;
        newApplication.Status__c = 'New'; 
        newApplication.Service_Jurisdiction__c = subscription.Service_Jurisdiction__c;
        newApplication.Billing_Jurisdiction__c = subscription.Billing_Jurisdiction__c;
        newApplication.Application_Type__c = 'Reinstatement';
        newApplication.Subscription_Type__c = subscription.Subscription_Type__c;
        newApplication.Type__c = subscription.Contact_Type__c; 
        
        newApplication.License_Expiration_Date__c = (sublicense.License__r)?sublicense.License__r.License_Expiration_Date__c:null;
        newApplication.License_State__c = (sublicense.License__r)?sublicense.License__r.License_State__c:null;
        newApplication.License_Type__c = (sublicense.License__r)?sublicense.License__r.License_Type__c:null;
        newApplication.License_Number__c = (sublicense.License__r)?sublicense.License__r.Name:null;
        newApplication.NRDS_ID__c = subscription.NRDS_ID__c;
		newApplication.Agent_Subscription_ID__c = subscription.Id;
        newApplication.Association_Board_Affiliation__c = relAssociation.Association__c;

        if(agents.length > 0) {
            var agentsList = [];
            for(var i=0; i<agents.length; i++) {
                var agent = agents[i];
                agentsList.push({'name':agent.Contact__r.Name, 'agentId':agent.Name});
            }
        	newApplication.Related_Agents__c = JSON.stringify(agentsList);
        }
        console.log('***newApplication:', newApplication);


        var action = component.get("c.submitApplication");
        action.setParams({
            'application' : newApplication
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
            else if (state === "ERROR") {
                console.log("Something went wrong!! Check server logs!!");
                this.handleServerErrors(component, response.getError());
            }
        });
        $A.enqueueAction(action);         
    },
    
    handleServerErrors : function(component, errors) {
        component.set('v.showServerError', true);
        let message = 'Unknown error';
        if (errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
        }
        console.error(message);         
    }
})