/*
Created By: BLT India Team
*/
public class WF_BusinessView{
    
    @RemoteAction
    public static List<WorkflowDetail> getWorkflowMetaDate(list<string> wfIds){
        try{
            String apiWorkflowRules = 'Some Random Text';
            Map<String, String> triggerCondition = new Map<String, String>();
            String querybyOffset;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            
            triggerCondition.put('onCreateOrTriggeringUpdate', 'Evaluate the rule when a record is created, and any time it\'s edited to subsequently meet criteria');
            triggerCondition.put('onAllChanges', 'Evaluate the rule when a record is created, and every time it\'s edited');
            triggerCondition.put('onCreateOnly', 'Evaluate the rule when a record is created');
            List<WorkflowDetail> WorkflowDetails = new List<WorkflowDetail>();
            system.debug('----wfIds--->'+wfIds);
            for(string rd : wfIds){
                querybyOffset =  'Select Id, Name, TableEnumOrId, Metadata From WorkflowRule WHERE id = \''+ rd +'\'';
                QueryResult subQueryResult = query(querybyOffset);
                
                List<Record> subrecords = new List<Record>();
                if(subQueryResult != null){
                    subrecords = subQueryResult.records;
                    for(Record srd : subrecords){
                        
                        system.debug('---srd.Metadata--->'+srd.Metadata);
                        system.debug('---srd.Metadata.description.contains("SJ")--->'+srd.Metadata.description);
                        if(srd.Metadata.description != null && srd.Metadata.description.contains('"SJ"') ){
                            WorkflowDetail wd = new WorkflowDetail();  
                            wd.Id = srd.Id;
                            wd.objectName = srd.TableEnumOrId;
                            Schema.SObjectType leadSchema = schemaMap.get(wd.objectName);
                            Schema.DescribeSObjectResult rs = leadSchema.getDescribe();
                            wd.objectName = rs.getLabel();
                            wd.Name = srd.Name;
                            wd.booleanFilter = srd.Metadata.booleanFilter;
                            wd.triggerType = triggerCondition.get(srd.Metadata.triggerType);
                            wd.formula = srd.Metadata.formula;
                            
                            
                            system.debug('---desWrap--->'+srd.Metadata.description);
                            DescriptionWrap desWrap = (DescriptionWrap) System.JSON.deserialize(srd.Metadata.description, DescriptionWrap.class);
                            
                            if(desWrap != null){
                                wd.SJ = desWrap.SJ;
                                wd.BJ = desWrap.BJ;
                                wd.TE = desWrap.TE;
                                wd.BE = desWrap.BE;
                                wd.DES = desWrap.DES;
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
                                QueryResult alertQueryResult = query(querybyOffset);
                                List<Record> alertRecords = new List<Record>();
                                alertRecords = alertQueryResult.records;
                                for(Record alr : alertRecords){
                                    
                                    boolean sfEmail = false;
                                    for(string adEmail : alr.Metadata.ccEmails){
                                        //if(adEmail.contains('sandbox.salesforce.com'))
                                        if(adEmail.contains(Label.WF_BusinessView_SFemail_check))    
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
                                        
                                        QueryResult alertQueryResult = query(querybyOffset);
                                        List<Record> alertRecords = new List<Record>();
                                        alertRecords = alertQueryResult.records;
                                        for(Record alr : alertRecords){
                                            
                                            system.debug('---alrTime-->'+alr);
                                            boolean sfEmail = false;
                                            for(string adEmail : alr.Metadata.ccEmails){
                                                //if(adEmail.contains('sandbox.salesforce.com'))
                                                if(adEmail.contains(Label.WF_BusinessView_SFemail_check))
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
                }
            }  
            system.debug('---WorkflowDetails-->'+WorkflowDetails);
            return WorkflowDetails;
        }
        catch(Exception ex){
            system.debug('---exception-->'+ex.getLinenumber());
            system.debug('---exception-->'+ex.getMessage());
            return null;
        }
    }
    
    public static QueryResult query(string querybyOffset){
        
        String encoded = EncodingUtil.urlEncode(querybyOffset, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v36.0/tooling/query/?q='+encoded);
        req.setMethod('GET');
        system.debug('---endoded--->'+encoded);
        system.debug('----endoint--->'+URL.getSalesforceBaseUrl().getHost());
        string autho = 'Bearer '+ userInfo.getsessionId();
        req.setHeader('Authorization', autho);
        
        
        Http http = new Http();
        System.HttpResponse res = new System.HttpResponse();
        if(!test.isRunningTest())
            res = http.send(req);
        else
            res = WF_Mockgenerator.generateMockData(req);
        
        system.debug('----res--->'+res);
        string response = res.getBody();
        System.debug(response);
        QueryResult queryResult = (QueryResult) System.JSON.deserialize(response, QueryResult.class);
        return queryResult;
    }
    
    @RemoteAction
    public static list<string> queryWFIds(){
        try{
            list<string> wfIds = new list<string>();
            string querybyOffset =  'Select Id, Name, TableEnumOrId From WorkflowRule Where NamespacePrefix = null'; 
            QueryResult queryResult = query(querybyOffset);
            if(queryResult != null ){
                List<Record> records = new List<Record>();
                records = queryResult.records;
                for(Record red : records){
                    wfIds.add(red.Id);
                }
                system.debug('---wfIds--->'+wfIds.size()+'---'+wfIds);
            }
            return wfIds;
        }
        catch(Exception ex){
            system.debug('---exception---->'+ex.getMessage());
            return null;
        }
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