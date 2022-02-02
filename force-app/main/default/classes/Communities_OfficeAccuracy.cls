public without sharing class Communities_OfficeAccuracy {
    
    @AuraEnabled
    public static list<OfficeAccuracyWrapper> getDetails(String subId){
        try 
        {
            system.debug('subId---'+subId);
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId, Broker_Office__r.Name,
                             Subscription__r.Name, Subscription__r.Contact__r.Name, Subscription__r.Contact__r.Id
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription_ID__c = :subId 
                            ];
            
            List<String> parentIds = new List<String>();
            List<String> asOffices = new List<String>();
            List<String> omOffices = new List<String>();
            List<String> officeIds =new List<String>();
            Boolean isBOR = false;
            String relationshipType = '';
            String officeId = '';
            
            for(Relationship__c relationship : relationships){
                system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
                system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
                
                if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                    parentIds.add(relationship.Broker_Office__r.ParentId);            
                
                if(String.IsNotBlank(relationship.Broker_Office__c))
                    parentIds.add(relationship.Broker_Office__c);
                
                if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                    isBOR = true;
                    
                    relationshipType = relationship.Relationship_Type__c;
                    officeId = relationship.Broker_Office__c;  
                    
                } 
                else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                    asOffices.add(relationship.Broker_Office__c);
                }
                else if(relationship.Relationship_Type__c == 'Office Manager'){
                    omOffices.add(relationship.Broker_Office__c);
                }
            }
            if(!isBOR){
                if(asOffices.size() > 0){
                    officeIds = new List<String>(asOffices);
                    relationshipType = 'Authorized Signer';
                }
                else if(omOffices.size() > 0){
                    officeIds = new List<String>(omOffices);
                    relationshipType = 'Office Manager';
                }
            }
            else{
                List<Account> relatedAccounts = new List<Account>(); 
                relatedAccounts = [SELECT Id, ParentId, Name
                                   FROM   Account
                                   WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' 
                                  ];
                officeIds = new List<String>();
                for(Account a : relatedAccounts){
                    officeIds.add(a.Id);
                    if(a.ParentId != null)
                        officeIds.add(a.ParentId);
                }
                system.debug('*****officeIds*****'+officeIds.size());
                system.debug('*****officeIds*****'+officeIds);
            }
            
            
            list<Compliance_Violation__c> lstComplianceFines = [SELECT Id, Name, Subscription__r.Related_Location_Broker_Office__r.Name,
                                                                (Select  Id, Name, Date_of_Fine__c, Fine_Amount__c,Violation_Number_Formatted__c, 
                                                                 Subscription__c, Subscription__r.Name,Broker_Of_Record__c,Agent_Name__r.Name,
                                                                 Notification_Type__c, Compliance_Violation__r.Name,
                                                                 Full_Address__c, Agent_Name__c,Subscription_ID__c,
                                                                 Subscription__r.Related_Location_Broker_Office__c,
                                                                 Subscription__r.Contact__c,Subscription__r.Contact__r.Name, 
                                                                 Subscription__r.Related_Location_Broker_Office__r.Name,
                                                                 MLS_Number__c,Violation__c, 
                                                                 QC_Fine_Code__c, Listing_Status__c, //used as temp var to store date strings
                                                                 Subscription__r.Primary_Phone__c, Subscription__r.Private_Email__c, Status__c, Last_Date_to_Appeal__c                                                                
                                                                 From Compliance_Fines__r 
                                                                 //WHERE Subscription__r.Related_Location_Broker_Office__c =:officeIds
                                                                 order by createdDate desc) 
                                                                FROM Compliance_Violation__c  
                                                                Where createdDate = last_n_days:60
                                                                AND Subscription__c != null 
                                                                AND Subscription__r.Related_Location_Broker_Office__c =:officeIds
                                                                order by createdDate desc];
            system.debug('*****lstComplianceFines*****'+lstComplianceFines.size());
            
            List<OfficeAccuracyWrapper> wrap = new List<OfficeAccuracyWrapper>();
            for(Compliance_Violation__c cv: lstComplianceFines){
                if(cv.Compliance_Fines__r != null && cv.Compliance_Fines__r.size()>0)
                    wrap.add(new OfficeAccuracyWrapper(cv));
                
            }
            return wrap;
        }
        
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));  
            throw new AuraHandledException(e.getMessage());           
        }
    }
    
    
    public class OfficeAccuracyWrapper 
    {    
        @AuraEnabled  public List<Compliance_Fine__c> childViolations {get; set;}  
        @AuraEnabled  public string violationId {get; set;}
        @AuraEnabled  public string agent {get; set;}
        @AuraEnabled  public string subscriptionId {get; set;}
        @AuraEnabled  public string officeId {get; set;}
        @AuraEnabled  public string mlsNumber {get; set;}
        @AuraEnabled  public string violationType {get; set;}
        @AuraEnabled  public string violationNo {get; set;}
        @AuraEnabled  public string notificationType {get; set;}
        @AuraEnabled  public Date notificationDate {get; set;}
        @AuraEnabled  public Decimal fineAmount {get; set;}
        @AuraEnabled  public string status {get; set;}
        @AuraEnabled  public Date lastDayToAppeal {get; set;}
        @AuraEnabled  public boolean showOldFines { get; set; }
        @AuraEnabled  public String lastDayToAppealStr {get; set;}
        @AuraEnabled  public String notificationDateStr {get; set;}
        
        public OfficeAccuracyWrapper(Compliance_Violation__c cv){
            
            this.childViolations = cv.Compliance_Fines__r;  
            this.violationId = cv.Id;
            this.agent = cv.Compliance_Fines__r[0].Subscription__r.Contact__r.Name;
            this.subscriptionId = cv.Compliance_Fines__r[0].Subscription__r.Name; 
            this.officeId = cv.Subscription__r.Related_Location_Broker_Office__r.Name;
            this.mlsNumber = cv.Compliance_Fines__r[0].MLS_Number__c;
            this.violationType = cv.Compliance_Fines__r[0].Violation__c;
            this.violationNo = cv.Compliance_Fines__r[0].Violation_Number_Formatted__c;
            this.notificationType = cv.Compliance_Fines__r[0].Notification_Type__c;
            if(cv.Compliance_Fines__r[0].Date_of_Fine__c != null){  
                this.notificationDate = cv.Compliance_Fines__r[0].Date_of_Fine__c;
                this.notificationDateStr = cv.Compliance_Fines__r[0].Date_of_Fine__c.format();  
            }
            this.fineAmount = cv.Compliance_Fines__r[0].Fine_Amount__c;    
            this.status = cv.Compliance_Fines__r[0].Status__c;    
            if(cv.Compliance_Fines__r[0].Last_Date_to_Appeal__c != null){  
                this.lastDayToAppeal = cv.Compliance_Fines__r[0].Last_Date_to_Appeal__c;  
                this.lastDayToAppealStr = cv.Compliance_Fines__r[0].Last_Date_to_Appeal__c.format(); 
            }
            this.showOldFines =false; 
            
            for(Integer i = 0; i < cv.Compliance_Fines__r.size(); i++){
                Compliance_Fine__c cFine = new Compliance_Fine__c();
                cFine = cv.Compliance_Fines__r[i];
                if(cFine.Date_of_Fine__c != null)
                    cFine.Listing_Status__c = cFine.Date_of_Fine__c.format();
                else
                    cFine.Listing_Status__c = '';
                
                if(cFine.Last_Date_to_Appeal__c != null)
                    cFine.QC_Fine_Code__c = cFine.Last_Date_to_Appeal__c.format(); 
                else
                    cFine.QC_Fine_Code__c = '';
                
                cv.Compliance_Fines__r[i] = cFine;
            }
            
        }
    }
    
    public class CustomException extends Exception {}
}