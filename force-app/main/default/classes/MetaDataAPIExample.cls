public class MetaDataAPIExample {
    
    public list<fromJSON> wrapObjects {get; set;}
    public list<cls_records> wrapWorkflows {get; set;}
    
    public List<String> selectedBJs {get; set;}
    public List<SelectOption> BJOptions { get; set;}    
    public List<String> selectedSJs { get; set;}
    public List<SelectOption> SJOptions { get; set;}
    public boolean statusSelected {get; set;}
    
    public MetaDataAPIExample(){
        
        selectedSJs = new List<String>();
        Schema.DescribeFieldResult SJfield = Subscriptions__c.Service_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> SJvalues = SJfield.getPicklistValues();        
        SJOptions = new List<SelectOption>();        
        for(Schema.PicklistEntry e : SJvalues) {
            SJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
        
        selectedBJs = new List<String>();        
        Schema.DescribeFieldResult BJfield = Subscriptions__c.Billing_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> BJvalues = BJfield.getPicklistValues();
        BJOptions = new List<SelectOption>();
        
        for(Schema.PicklistEntry e : BJvalues) {
            BJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
        
        wrapObjects = new list<fromJSON>();
        wrapWorkflows = new list<cls_records>();
        workflowDetails();
    }
    
    public void workflowDetails(){
        
        string query = 'Select Id, Name From WorkflowRule limit 10';
		fromJSON objfromJson = exmple1(query);
        system.debug('---objfromJson--->'+objfromJson);
        list<cls_records> lstobjRec = objfromJson.records;
        system.debug('---obj records-->>'+lstobjRec);
        for(cls_records rec : lstobjRec){
            system.debug('----rec id--'+rec.Id);
            query = 'Select Id, Name, TableEnumOrId, MetaData From WorkflowRule Where id = \''+rec.Id+'\'';
			fromJSON objJson = exmple1(query);
            system.debug('---objJson-->>'+objJson);
            wrapObjects.add(objJson);
        }
        system.debug('---wrapObjects-->'+wrapObjects);
        for(fromJSON wrp : wrapObjects ){
            wrapWorkflows.addAll(wrp.records);
            for(cls_records rec : wrp.records){
                system.Debug('---rec name--->>'+rec.Name);
            }
        }
    }
    
    public fromJSON exmple1(string query){
        
        String encoded = EncodingUtil.urlEncode(query, 'UTF-8');
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
            fromJSON objfromJson = parse(response);
            return objfromJson;
        }catch(Exception e){
            system.debug('---exception-->>'+e.getMessage());
            return null;
        }
    }
    
    public fromJSON parse(String json){
        fromJSON objfromJson;
        objfromJson = (fromJSON) System.JSON.deserialize(json, fromJSON.class);
        return objfromJson;
    }
    
    public class fromJSON{
        public Integer size;
        public Integer totalSize;
        public boolean done;
        public string queryLocator;
        public String entityTypeName;	//WorkflowRule
        public cls_records[] records {get; set;}
        
    }
    
    class cls_records {
        public cls_attributes attributes;
        public String Id {get; set;}	//01QJ0000000EZBvMAO
        public String Name {get; set;}	//BRIGHT Coastal/Sussex Outstanding Balance Notification
        public cls_Metadata Metadata {get; set;}
        public String TableEnumOrId {get; set;}		// Object Name
    }
    class cls_attributes {
        public String type;
        public String url;
    }
    class cls_Metadata {
        public cls_actions[] actions {get; set;}
        public cls_booleanFilter booleanFilter;
        public cls_criteriaItems[] criteriaItems;
        public String formula {get; set;}	//IF(ISPICKVAL(Subscription__r.Status__c , 'Active') &&  Zuora__Balance__c > 0 && (ISPICKVAL( Subscription__r.Billing_Jurisdiction__c , 'Sussex') || ISPICKVAL( Subscription__r.Billing_Jurisdiction__c , 'Coastal')) && Oldest_Invoice_Due__c == DATE(2018,04,18) && Zuora__CreditBalance__c == 100, true, false )
        public string urls;
        public cls_workflowTimeTriggers[] workflowTimeTriggers {get; set;}
        public boolean active {get; set;}
        public String description;	//Workflow to send emails for Sussex or Coastal which were billed on 18th April,2018
        public String triggerType;	//onCreateOrTriggeringUpdate
    }
    class cls_actions {
        public String name {get; set;}	//BRIGHT_MLS_Email_to_Salesforce_Outstanding_Balance_Final_Notice
        public String type {get; set;}	//Alert
    }
    class cls_booleanFilter {
    }
    class cls_criteriaItems {
    }
    class cls_workflowTimeTriggers {
        public cls_actions[] actions{get; set;}
        public String offsetFromField;	//Zuora__CustomerAccount__c.Oldest_Invoice_Due__c
        public String timeLength;	//40
        public String workflowTimeTriggerUnit;	//Days
    }
}