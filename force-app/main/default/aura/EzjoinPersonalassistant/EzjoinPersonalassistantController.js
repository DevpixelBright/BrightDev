({
    init : function(component,event,helper){
        helper.getSubscriptionOptions(component,event,helper);
        var objDetails = component.get("v.oBrightApplication");
        helper.fetchPicklistValues(component,event,helper);
        helper.fetchsuffixvalues(component,event,helper);
        helper.getConstants(component,event,helper);
    },
    
    handleBrokerOffice : function(component,event,helper){
        if(event.code != 'Tab'){
            component.set('v.secB', false);
            component.set('v.AgentList', [{'name':'', 'brokerOffice' : '', 'sub' : ''}]);
            component.set('v.secC', false);
            helper.fetchBrokerOffice(component,event,helper);
        }
        
    },
    
    selBrokerCode : function(component,event,helper){
        var dataset = event.target.dataset;
        component.set("v.selectedBrkrCode",dataset.id);
        var address = dataset.code+' '+dataset.name+' '+dataset.city+' '+dataset.state+' '+dataset.zip;
        var brokerCodeAcc = dataset.name +'-'+ dataset.code;
        component.set('v.brokerName',dataset.name);
        component.set('v.brokerCodeName',brokerCodeAcc);
        component.set('v.brokerCodeAddress',address);
        component.set('v.oBrightApplication.Company_Code__c', dataset.id);
        component.set('v.brokerCode', dataset.code);
        component.set('v.code', dataset.code);
        component.set('v.city', dataset.city);
        component.set('v.state', dataset.state);
        component.set('v.zip', dataset.zip);
        component.find('brokerCode').setCustomValidity('');
        component.find('brokerCode').reportValidity();
        component.set('v.Brokerlist',[]);
        
    },
    
    selectSubscriptionType : function(component,event,helper){
        component.set('v.secA', false);
    },
    
    selAgentName : function(component,event,helper){
        var dataset = event.target.dataset;
        component.set("v.selectedAgentCode",dataset.id);
        var agentDetails = component.get('v.AgentList');
        var agents = component.find('AgentName');
        if(agents.length > 0){
            component.find('AgentName')[component.get('v.idx')].set('v.value', dataset.name);
        }else{
            component.find('AgentName').set('v.value', dataset.name);
        }
        agentDetails[component.get('v.idx')].name = dataset.name;
        agentDetails[component.get('v.idx')].brokerOffice = component.get('v.brokerCodeName');
        agentDetails[component.get('v.idx')].agentid = dataset.id;
        
        component.set('v.AgentList', agentDetails);
        component.set('v.AgentNameList',[]);
    },
    
    selSubId : function(component,event,helper){ 
        var dataset = event.target.dataset;
        var agentDetails = component.get('v.AgentList');
        var subids = component.find('SubscriptionName');
        if(subids.length > 0){
            component.find('SubscriptionName')[component.get('v.idx')].set('v.value', dataset.name);
        }else{
            component.find('SubscriptionName').set('v.value', dataset.name);
        }
        agentDetails[component.get('v.idx')].sub = dataset.name;
        component.set('v.AgentList', agentDetails);
        component.set('v.SubIdList',[]);
    },
    
    Section1 : function(component,event,helper){
        var subType = component.get('v.oBrightApplication.Subscription_Type__c');
        if( subType != undefined && subType != null && subType != ''){
            component.set('v.secA', true);
            component.set("v.PAsection",'B');
        }else{
            component.set('v.secA', false);
        }
        
    },
    
    Section2 : function(component,event,helper){
        
        var broklist = component.get('v.oBrightApplication.Company_Code__c');
        if( broklist != undefined && broklist != null && broklist != ''){
            component.find('brokerCode').setCustomValidity('');
            component.set('v.secB', true);
            component.set("v.PAsection",'C');
        }
        
        
        else{
            component.find('brokerCode').setCustomValidity('Enter a value');
            component.set('v.secB', false);
        }
        component.find('brokerCode').reportValidity();
    },
    
    Section3 : function(component,event,helper){  
        
        var agents = component.get('v.AgentList');
        var agentList = component.find('AgentName');
        var SubIdList = component.find('SubscriptionName');
        component.set('v.secC', true);
        
        //Validation of agents null value
        if(agentList.length > 0) {
            for(var i = 0; i < agentList.length; i++) {
                var cmp = agentList[i];
                if(!helper.validateComponent(cmp)){
                    component.set('v.secC', false);
                }
            }
        }
        else {
            if(!helper.validateComponent(agentList)){
                component.set('v.secC', false);
            }
        }
        
        if(SubIdList.length > 0) {
            for(var i = 0; i < SubIdList.length; i++) {
                var cmp = SubIdList[i];
                if(!helper.validateComponent(cmp)){
                    component.set('v.secC', false);
                }
            }
        }
        else {
            if(!helper.validateComponent(SubIdList)){
                component.set('v.secC', false);
            }
        }
        
        //check for data consistency
        for(var i=0; i<agents.length; i++) {
            var agent = '';
            var subId = '';
            if(agentList.length > 0) {
                agent = agentList[i];
                subId = SubIdList[i];
            }else{
                agent = agentList;
                subId = SubIdList;
            }
            if(agent.get('v.value') != '' && agents[i].name != agent.get('v.value')){
                agent.setCustomValidity('Invalid Agent Name');
                agent.reportValidity();
                component.set('v.secC', false);
            }
            
            if(subId.get('v.value') != '' && agents[i].sub != subId.get('v.value')){
                subId.setCustomValidity('Invalid Subscription ID');
                subId.reportValidity();
                component.set('v.secC', false);
            }
            /*
            if(agents[i].sub == ''  || agents[i].name == '') {
                var agentVal = agent.get('v.value');
                var subVal = agent.get('v.value');
                if(agents[i].name == '' && (agentVal != undefined && agentVal != null && agentVal != '')) {
                    agent.setCustomValidity('Invalid Agent Name');
                    agent.reportValidity();
                }
                
                if(agents[i].sub == '' && (subVal != undefined && subVal != null && subVal != '') ) {
                    subId.setCustomValidity('Invalid Subscription ID');
                    subId.reportValidity();
                }
                
                component.set('v.secC', false);                        
            }*/
        }
        
        
        let subIdSet = new Set();
        for(var i=0; i<SubIdList.length; i++) {
            var cmp = SubIdList[i];
            var subVal = cmp.get('v.value');
            if(subVal != undefined && subVal != null && subVal != ''){
                if(subIdSet.has(subVal)){
                    cmp.setCustomValidity('Subscription already selected');
                    cmp.reportValidity();
                    component.set('v.secC', false);                        
                }else{
                    subIdSet.add(cmp.get('v.value'))
                }
            }
        }
        if(component.get('v.secC') == true){
            component.set("v.PAsection",'D');
        }
    },
    
    Section4 : function(component,event,helper) {
        var fields = ['FirstName', 'Email', 'Phone','LastName', 'Salutation', 'confirmEmail'];
        
        var isValid = true;
        for(var i=0; i<fields.length; i++) {
            var cmp = component.find(fields[i]);
            var val = cmp.get('v.value');
            if( val == undefined || val == null || val == ''){
                cmp.setCustomValidity('Enter a value');
                isValid = false;
            }else{
                if(fields[i] == 'Email') {
                    var emailRegex = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
                    if(emailRegex.test(val) != true){
                        cmp.setCustomValidity('Invalid email address format');
                        isValid = false;
                    }
                    else {
                        cmp.setCustomValidity('');
                    }
                }else if(fields[i] == 'Phone') {
                    var PhoneRegex = /^[0-9]{10,10}$/;
                    //var PhoneRegex = /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/;
                    if(PhoneRegex.test(val) != true){
                        cmp.setCustomValidity('Invalid Phone Number format');
                        isValid = false;
                    }
                    else {
                        cmp.setCustomValidity('');
                    }                    
                }else if(fields[i] == 'confirmEmail') {
                    var EmailValidate = component.find('Email').get('v.value');
                    var ConfirmEmailValidate = component.find('confirmEmail').get('v.value');   
                    if(EmailValidate != ConfirmEmailValidate){
                        cmp.setCustomValidity('Email doesn\'t match');
                        isValid = false;
                    }
                    else {
                        cmp.setCustomValidity('');
                    }                    
                }else{
                    cmp.setCustomValidity('');
                }
            }
            cmp.reportValidity();
        }
        
        if(isValid) {
            component.set('v.secD', true);
            component.set("v.PAsection",'E');
        }
        else {
            component.set('v.secD', false);
        }
        
    },
    
    Section5 : function(component,event,helper){
        component.set('v.secE', true);
        component.set("v.PAsection",'F');
    },
    
    
    accordionValidate : function(component,event,helper){
        var previousSection = component.get("v.previousPAsection");
        var section = component.get("v.PAsection");
        var isValid = false;
        if(previousSection < section){
            if(previousSection == 'A' && component.get('v.secA') == true){
                isValid = true;
            }else if(previousSection == 'B' && component.get('v.secB') == true){
                isValid = true;
            }else if(previousSection == 'C' && component.get('v.secC') == true){
                isValid = true;
            }else if(previousSection == 'D' && component.get('v.secD') == true){
                isValid = true; 
            }else if(previousSection == 'E' && component.get('v.secE') == true){
                isValid = true ; 
            }else if(previousSection == 'F'){
                isValid = true; 
            }
        }else{
            isValid = true;
        }
        if(!isValid){
            component.find("accordion").set('v.activeSectionName', previousSection)
        }else{
            component.set("v.previousPAsection",component.find("accordion").get('v.activeSectionName'));
        }
        
    },
    
    
    addAgent : function(component,event,helper){
        var agentList = component.get('v.AgentList');
        if(agentList && agentList.length < 5){
            var agent = new Object();
            agent.name = '';
            agent.brokerOffice = '';
            agent.sub = '';
            agent.agentid = '';
            agentList.push(agent);
            component.set('v.AgentList', agentList);
            component.set('v.secC',false);
        }
    },
    
    handleAgentName : function(component,event,helper){
        component.set('v.secC', false);
        var index = event.getSource().get('v.class');
        var subList = component.find('SubscriptionName');
        var agentList = component.find('AgentName');
        var cmp = agentList[index];
        var sub = subList[index];
        if(cmp == undefined) {
            cmp = component.find('AgentName');
        }
        if(sub == undefined) {
            component.find('SubscriptionName').set('v.value', '');
        }else{
            sub.set('v.value', '');
        }
        var val = cmp.get('v.value');
        var agList = component.get('v.AgentList');
        agList[index].name = '';
        agList[index].sub = '';
        component.set('v.AgentList', agList);
        if(val == undefined || val == null || val == ''){
            component.set('v.AgentNameList',[]);
        }else{
            component.set('v.idx', index);
            helper.fetchAgentname(component, event, helper, val, cmp);
        }
        component.set('v.width',component.find("agentDiv")[0].getConcreteComponent().getElement().getBoundingClientRect().width+'px');
    },
    
    handleSubId : function(component,event,helper){
        component.set('v.secC', false);
        var index = event.getSource().get('v.class');
        var agentList = component.get('v.AgentList');
        component.set('v.idx', index);
        var subCmp = component.find('SubscriptionName');
        if(subCmp.length > 0){
            subCmp = subCmp[index];
        }
       	agentList[index].sub = '';
        component.set('v.AgentList', agentList);
        subCmp.setCustomValidity('');
        subCmp.reportValidity();
        
        helper.fetchSubId(component,event,helper, agentList[index].agentid);
        component.set('v.width',component.find("subDiv")[0].getConcreteComponent().getElement().getBoundingClientRect().width+'px');
    },
    
    handleSubmit : function(component,event,helper){
        component.set('v.disabledSave', true);
        helper.submitApplication(component,event,helper);
    },
    
    deleteRow : function(component,event,helper){
        var row = event.currentTarget.getAttribute('class');
        var agentList = component.get('v.AgentList');
        if(agentList.length > 1){
            var al = [];
            delete agentList[row];
            for(var a of agentList){
                if(a != undefined){
                    al.push(a);
                }
            }
            component.set('v.AgentList', al);
        }
        
    }
})