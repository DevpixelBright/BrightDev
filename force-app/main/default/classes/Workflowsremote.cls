public class Workflowsremote{
        public List<QueryResult> totalQueryResults { get; set; }
        public String querybyOffset { get; set; }
        public String apiWorkflowRules { get; set; }  
        private Map<String,String> triggerCondition;
        public String body {set; get;}
       
          public QueryResult query(){
            
            String encoded = EncodingUtil.urlEncode(querybyOffset, 'UTF-8');
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v36.0/tooling/query/?q='+encoded);
            req.setMethod('GET');
            system.debug('---endoded--->'+encoded);
            system.debug('----endoint--->'+URL.getSalesforceBaseUrl().getHost());
            string autho = 'Bearer '+ userInfo.getsessionId();
            req.setHeader('Authorization', autho);
            
            try{
                Http http = new Http();
                HTTPResponse res = http.send(req);
                string response = res.getBody();
                System.debug(response);
                QueryResult queryResult = (QueryResult) System.JSON.deserialize(response, QueryResult.class);
                //totalQueryResults.add(queryResult);
                
                return queryResult;
            }catch(Exception e){
                system.debug('---exception-->>'+e.getMessage());
                return null;
            }
        }
    @RemoteAction
    Public static   list<string> Getworkflowsids(){
            string querybyOffset = 'Select Id, Name, TableEnumOrId From WorkflowRule';
            String encoded = EncodingUtil.urlEncode(querybyOffset, 'UTF-8');
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v36.0/tooling/query/?q='+encoded);
            req.setMethod('GET');
            system.debug('---endoded--->'+encoded);
            system.debug('----endoint--->'+URL.getSalesforceBaseUrl().getHost());
            string autho = 'Bearer '+ userInfo.getsessionId();
            req.setHeader('Authorization', autho);
            
            try{
                Http http = new Http();
                HTTPResponse res = http.send(req);
                string response = res.getBody();
                System.debug(response);
                QueryResult queryResult = (QueryResult) System.JSON.deserialize(response, QueryResult.class);
                List<Record> records = new List<Record>();
                records = queryResult.records;
                list<string> qureyResultValue = new list<string>();
                for(Record rec : records){
                  qureyResultValue.add(rec.Id);
                }
                
                return qureyResultValue;
            }catch(Exception e){
                system.debug('---exception-->>'+e.getMessage());
                return null;
            }   
    }
    @RemoteAction
        Public static list<string> Getworkflowsdetails(){
             List<WorkflowDetail> WorkflowDetails = new List<WorkflowDetail>();
             List<Record> records = new List<Record>();
             Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
             List<Record> subrecords = new List<Record>();  
             list<string> qureyresult = new list<string>();
            // triggerCondition = new Map<String,String>();
            for(Record rd : records){
                    string querybyOffset =  'Select Id, Name, Metadata From WorkflowRule WHERE id = \''+ rd.Id +'\'';
            for(Record srd : subrecords){
                        WorkflowDetail wd = new WorkflowDetail();  
                        wd.Id = srd.Id;
                        wd.objectName = rd.TableEnumOrId;
                        Schema.SObjectType leadSchema = schemaMap.get(wd.objectName);
                        Schema.DescribeSObjectResult rs = leadSchema.getDescribe();
                        wd.objectName = rs.getLabel();
                        wd.Name = rd.Name;
                        wd.booleanFilter = srd.Metadata.booleanFilter;
                       // wd.triggerType = triggerCondition.get(srd.Metadata.triggerType);
                        wd.formula = srd.Metadata.formula;
                        
                        if(srd.Metadata.description != null){
                            system.debug('---desWrap--->'+srd.Metadata.description);
                            //system.debug('---desWrap serialize--->'+JSON.serialize(srd.Metadata.description));
                            
                            DescriptionWrap desWrap = (DescriptionWrap) System.JSON.deserialize(srd.Metadata.description, DescriptionWrap.class);
                            system.debug('---desWrap--->'+desWrap);
                            if(desWrap != null){
                                wd.SJ = desWrap.SJ;
                                wd.BJ = desWrap.BJ;
                                wd.TE = desWrap.TE;
                                wd.BE = desWrap.BE;
                                wd.DES = desWrap.DES;
                            }
                        }
    
                       
                        wd.actions = new List<Action>();
                        list<Action> allActions = new list<Action>();
                        allActions = srd.Metadata.actions;
                        system.debug('action--'+srd.Metadata.actions);
                        if(srd.Metadata.active)
                            wd.status = 'Active';
                        else
                            wd.status = 'Inactive';
                        
                        
                        system.debug('-----Recipient-----' +srd.Metadata);
                        list<TimeDependentDetails> lstDepdetails = new list<TimeDependentDetails>();
                        
                        for(Action ac : allActions){
                            
                            querybyOffset =  'select id, Description, DeveloperName, Metadata, TemplateId from WorkflowAlert Where DeveloperName = \''+ ac.name +'\'';
                            //QueryResult alertQueryResult = query();
                            List<Record> alertRecords = new List<Record>();
                            //alertRecords = alertQueryResult.records;
                            for(Record alr : alertRecords){
                                
                                boolean sfEmail = false;
                                for(string adEmail : alr.Metadata.ccEmails){
                                    if(adEmail.contains('sandbox.salesforce.com'))
                                        sfEmail = true;
                                }
                                if(!sfEmail){
                                    TimeDependentDetails obj = new TimeDependentDetails();
                                    system.debug('---alr-->'+alr);
                                    obj.TemplateId = alr.TemplateId;
                                    obj.template = alr.Metadata.template.split('/')[1].replace('_', ' ');
                                    obj.name = alr.Description;
                                    obj.timeLength = 'Immediate Action';
                                    
                                    for(recipient rec: alr.Metadata.recipients){
                                        system.debug('rec.recipient----'+alr.Metadata.recipients);
                                        if(rec.recipient != null){
                                            if(obj.recipient != null)
                                                obj.recipient += ', '+rec.recipient;
                                            else
                                                obj.recipient = rec.recipient;
                                                
                                        }
                                        if(rec.field != null){   
                                            if(obj.recipient != null)
                                                obj.recipient += ', '+rec.field;
                                            else
                                                obj.recipient = rec.field;
                                        }
                                    }
                                    lstDepdetails.add(obj);
                                }
                            }
                            
                        }
                        
                        if(srd.Metadata.workflowTimeTriggers != null && srd.Metadata.workflowTimeTriggers.size() > 0){
                            
                            system.debug('---srd.Metadata.workflowTimeTriggers--->'+srd.Metadata.workflowTimeTriggers);
                            for(workflowTimeTriggers wftVar : srd.Metadata.workflowTimeTriggers ){
                                
                                for(Action ac : wftVar.actions){
                                    querybyOffset =  'select id, Description, DeveloperName, Metadata, TemplateId from WorkflowAlert Where DeveloperName = \''+ ac.name +'\'';
                                
                                   // QueryResult alertQueryResult = query();
                                    List<Record> alertRecords = new List<Record>();
                                    //alertRecords = alertQueryResult.records;
                                    for(Record alr : alertRecords){
                                        
                                        system.debug('---alrTime-->'+alr);
                                        boolean sfEmail = false;
                                        for(string adEmail : alr.Metadata.ccEmails){
                                            if(adEmail.contains('sandbox.salesforce.com'))
                                                sfEmail = true;
                                        }
                                        if(!sfEmail){
                                            TimeDependentDetails obj = new TimeDependentDetails();
                                            obj.name = alr.Description;                                
                                            obj.TemplateId = alr.TemplateId;
                                            obj.template = alr.Metadata.template.split('/')[1].replace('_', ' ');
                                            
                                            for(recipient rec: alr.Metadata.recipients){
                                                
                                                system.debug('rec.recipient----'+alr.Metadata.recipients);
                                                if(rec.recipient != null){
                                                    if(obj.recipient != null)
                                                        obj.recipient += ', '+rec.recipient;
                                                    else
                                                        obj.recipient = rec.recipient;
                                                }
                                                if(rec.field != null){
                                                    if(obj.recipient != null)
                                                        obj.recipient += ', '+rec.field;
                                                    else
                                                        obj.recipient = rec.field;
                                                }
                                            }
                                            
                                            
                                            leadSchema = schemaMap.get(wftVar.offsetFromField.split('\\.')[0]);
                                            Schema.DescribeSObjectResult objDesc = leadSchema.getDescribe();
                                            string objLabel = objDesc.getLabel();
                                            
                                            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                                            
                                            string fieldLabel = fieldMap.get(wftVar.offsetFromField.split('\\.')[1]).getDescribe().getLabel();
                                                                                      
                                                                                       
                                            obj.offsetFromField = objLabel+' : '+fieldLabel;
                                            obj.timeLength = wftVar.timeLength;
                                            obj.workflowTimeTriggerUnit = wftVar.workflowTimeTriggerUnit;
                                            
                                            lstDepdetails.add(obj);
                                        }
                                        
                                    }
                                    
                                    system.debug('lstDepdetails' +lstDepdetails);
                                }
                            }
                            
                           system.debug('lstDepdetails' +lstDepdetails);
                            if(!lstDepdetails.isEmpty()){
                                wd.timedependentDetials = new list<TimeDependentDetails>();
                                wd.timedependentDetials = lstDepdetails;
                                system.debug('***Wd-->'+wd.timedependentDetials);
                            }
                        }
                        
                        WorkflowDetails.add(wd); 
                         
                    }                 
        }
           system.debug('---WorkflowDetails-->'+WorkflowDetails);
            String apiWorkflowRules = JSON.serialize(WorkflowDetails);
            //system.debug(totalQueryResults.size());  
            return qureyresult ; 
        }
        public class QueryResult{
            public Integer size;  //1
            public Integer totalSize;  //1
            public boolean done;
            public String queryLocator;
            public String entityTypeName;  //WorkflowRule
            public List<Record> records {get; set;}
            
        }
        
        public class WorkflowDetail{
            public String name { get; set; }
            public String status { get; set; }
            public String Id { get; set; }
            public String objectName { get; set; }
            public String booleanFilter { get; set; }
            public String formula { get; set; }
            public String triggerType { get; set; }
            public List<Action> actions {get; set;}
            public String description {get; set;}
            public String SJ {get; set;}
            public String BJ {get; set;}
            public String TE {get; set;}
            public String BE {get; set;}
            public String DES {get; set;}
            public List<workflowTimeTriggers> timeTriggerList {get;set;}
            public List<recipient> recipientList{get; set;}
            public list<TimeDependentDetails> timedependentDetials {get; set;} 
        }
        
        class TimeDependentDetails{         // time dependent actions final wrapper 
            public String name { get; set; }
            //public String type { get; set; }
            public String TemplateId {get; set;}
            public String template {get; set;}
            public String offsetFromField;  //Zuora__CustomerAccount__c.Oldest_Invoice_Due__c
            public String timeLength;  //40
            public String workflowTimeTriggerUnit;  //Days
            public String field {get; set;}
            public String recipient {get; set;}
        }
            
        class Record{
            public Attributes attributes;
            public String Id {get; set;}  //01QJ0000000EZBvMAO
            public String Name {get; set;}  //BRIGHT Coastal/Sussex Outstanding Balance Notification
            public String TableEnumOrId {get; set;}
            public Metadata Metadata {get; set;}
            public String Description {get; set;}
            public String DeveloperName {get; set;}
            public String EntityDefinitionId {get; set;}
            public String FullName {get; set;}
            public String ManageableState {get; set;}
            public String TemplateId {get; set;}
           
        }
        
        class Metadata{
            public List<Action> actions {get; set;}
            public String booleanFilter {get; set;}
            //public cls_criteriaItems[] criteriaItems;
            public String formula {get; set;}  //IF(ISPICKVAL(Subscription__r.Status__c , 'Active') &&  Zuora__Balance__c > 0 && (ISPICKVAL( Subscription__r.Billing_Jurisdiction__c , 'Sussex') || ISPICKVAL( Subscription__r.Billing_Jurisdiction__c , 'Coastal')) && Oldest_Invoice_Due__c == DATE(2018,04,18) && Zuora__CreditBalance__c == 100, true, false )
            public string urls;
            public list<workflowTimeTriggers> workflowTimeTriggers {get; set;}
            public boolean active {get; set;}
            public string description;  //Workflow to send emails for Sussex or Coastal which were billed on 18th April,2018
            public String triggerType {get; set;}
            public String senderAddress {get; set;}
            public list<String> ccEmails {get; set;}
            public list<recipient> recipients {get; set;}
            public String template {get; set;}
        }
        
        Class DescriptionWrap{
            public String SJ {get; set;}
            public String BJ {get; set;}
            public String TE {get; set;}
            public String BE {get; set;}
            public String DES {get; set;}
            
        }
            
        Class recipient{
            public String field {get; set;}
            public String recipient {get; set;}
            public String type {get; set;}   
        }
        
        class Action{
            public String name { get; set; }
            public String type { get; set; }
            public String TemplateId {get; set;}
            public String template {get; set;}
            public String recipient {get; set;}
        }
        class workflowTimeTriggers {
            public list<Action> actions{get; set;}
            public String offsetFromField;  //Zuora__CustomerAccount__c.Oldest_Invoice_Due__c
            public String timeLength;  //40
            public String workflowTimeTriggerUnit;  //Days
        }
        
        
        class Attributes {
            public String type;
            public String url;
        }
        
    }