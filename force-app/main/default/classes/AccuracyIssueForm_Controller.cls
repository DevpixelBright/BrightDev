public class AccuracyIssueForm_Controller {

    public String mlsNumber { get; set; } 
    public String propertyAddress { get; set; }
    public String fromName { get; set; } 
    public String topic { get; set; } 
    public String description { get; set; }
    public string msg { get; set; }
    //public case newcase {get; set;}
    //public String caseNumber {get; set;}
    public Attachment att {get;set;}
    public List<Attachment> lAtt {get;set;}
    public Subscriptions__c subsCriptionVar {get;set;}
    
    public AccuracyIssueForm_Controller() {
        att = new Attachment();
        lAtt = new List<Attachment>();
        subsCriptionVar = New Subscriptions__c();     
        if(ApexPages.currentPage().getParameters().get('mls') != null)
            mlsNumber = ApexPages.currentPage().getParameters().get('mls');
        if(ApexPages.currentPage().getParameters().get('address') != null)
            propertyAddress = ApexPages.currentPage().getParameters().get('address');
        if(ApexPages.currentPage().getParameters().get('from') != null){
            fromName = ApexPages.currentPage().getParameters().get('from');
            
            //if(fromName.contains('(') && fromName.contains(')') && fromName.split('\\(')[1].split('\\)') != null){
                string subId = fromName.split('\\(')[1].split('\\)')[0];
                system.debug('---subId-->'+subId);
                
                list<Subscriptions__c> lstSubs = [Select Id,Name, Related_Location_Broker_Office__c,Related_Location_Broker_Office__r.Name,Related_Location_Broker_Office__r.Account_Name__c 
                                    From Subscriptions__c Where Name =: subId Limit 1];
                
                if(lstSubs != null && lstSubs.size() >0 )
                    subsCriptionVar = lstSubs[0];
           // }
            
        }
        
        //list<Subscriptions__c> lstSubs = validateSubscription();
           
    }
    
        //Method to save file parts
    @RemoteAction
    public static String attachFile(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue) {
        if(attachmentId == '' || attachmentId == null) {
            Attachment att = new Attachment(
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            system.debug(att.Body);
            att.ParentId = parentId;
            insert att;
            return att.Id;
        }
        else {
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]) {
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }                     
    }
    public list<Subscriptions__c> validateSubscription(){//boolean contr){
        list<Subscriptions__c> lstSubs;
        
        if(fromName.contains('(') && fromName.contains(')') && fromName.split('\\(')[1].split('\\)') != null){
            
            
            string subId = fromName.split('\\(')[1].split('\\)')[0];
            system.debug('---subId-->'+subId);
            lstSubs = [Select Id,Name, Related_Location_Broker_Office__c, Contact__c,Related_Location_Broker_Office__r.Name,Related_Location_Broker_Office__r.Account_Name__c//, Contact__r.Name, Contact__r.Email, Contact__r.Phone
                        From Subscriptions__c Where Name =: subId];
            if(lstSubs == null || lstSubs.isEmpty()){
                throw new CustomException('Invalid Subscription '+subId);
            }
        }
        else{
            throw new CustomException('Invalid Subscription '+fromName);
        }
        return lstSubs;
    }
    
    @RemoteAction
    public static String remoteCreateCase(String mlsNumber, String propertyAddress, String fromSource, String topic, String description) {
        try {
            List<Subscriptions__c> lstSubs = new List<Subscriptions__c>();
            if(fromSource.contains('(') && fromSource.contains(')') && fromSource.split('\\(')[1].split('\\)') != null) {
                string subId = fromSource.split('\\(')[1].split('\\)')[0];
                lstSubs = [SELECT 	Id, Name, Related_Location_Broker_Office__c, Contact__c, Related_Location_Broker_Office__r.Name, Related_Location_Broker_Office__r.Account_Name__c//, Contact__r.Name, Contact__r.Email, Contact__r.Phone
                           FROM 	Subscriptions__c 
                           WHERE 	Name =: subId];
                
                if(lstSubs == null || lstSubs.isEmpty())
                    throw new CustomException('Invalid Subscription ' + subId);
            }
            else
                throw new CustomException('Invalid Subscription ' + fromSource);

            List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                           FROM   QueueSobject 
                                           WHERE  SobjectType = 'Case' 
                                           AND    Queue.DeveloperName = 'Accuracy_Policy'];
            
            Case newcase = new Case();
            newCase.OwnerId = queueIds[0].QueueId;
            newcase.Origin ='Accuracy Issue';
            newcase.Subject='Accuracy Issue - ' + propertyAddress;
            newcase.Status = 'Not Started';
            newcase.MLS_Number__c = mlsNumber;
            newcase.Report_a_Violation_Description__c = description;
            if(lstSubs != null && !lstSubs.isEmpty()) {
                newcase.Subscription_ID__c = lstSubs[0].id;
                newcase.contactId = lstSubs[0].Contact__c;
                newcase.Related_Account__c = lstSubs[0].Related_Location_Broker_Office__c;
            } 

			newcase.MLS__c = 'BRIGHT';
            newcase.Product__c = 'Accuracy & Policy';
            if(topic == 'Incorrect tax identification or legal information') {
                newcase.Product__c = 'Public Records';
                newcase.Category__c ='Bad/No MLSLink';
            }
            else if(topic == 'Listing not entered into system within 3 business days excluding weekends and holidays') {
                newcase.Category__c ='MLS Listing Requirements';
            }
            else if(topic == 'Duplicate Listing') {
                newcase.Category__c ='Duplicate Listing';
            }
            else if(topic == 'Incorrect Contingency' || topic == 'Unavailable for Showing' || topic == 'Incorrect status information') {
                newcase.Category__c ='Listing Changes - Status';
            }
            else if(topic == 'Incorrect data information (i.e. picklist item)' || topic == 'Incorrect Days On Market information (DOM or CDOM)') {
                newcase.Category__c ='Listing Data Questions';
            }
            else if(topic == 'Incorrect settlement information') {
                newcase.Category__c ='Settlement Info (Acc&Pol)';
            }
            else if(topic == 'Other' || topic == 'Uploaded Document' || topic == 'Virtual Tour') {
                newcase.Category__c ='Other';
            }
            else if(topic == 'Photo Violation') {
                newcase.Category__c = 'Photo';
            }
            else if(topic == 'Price') {
                newcase.Category__c = 'Price';
            }
            else if(topic == 'Property advertised prior to entry into Bright ') {
                newcase.Category__c = 'MLS Listing Requirements';
            }
            else if(topic == 'Remarks Violation') {
                newcase.Category__c = 'Remarks Related';
            }
            else if(topic == 'Unauthorized use of Bright system (Pease submit name and circumstance)') {
                newcase.Category__c = 'Rules & Regulations';
            }
            newcase.Report_a_Violation_Topic__c = topic;
           // newcase.Report_a_Violation_Description__c = newcase.Description;
            insert newcase;            
           
            return newcase.Id;
        }
        catch(Exception e) {
            return 'Failed: ' + e.getMessage();
        }
    }
    
    public class CustomException extends Exception {}
}