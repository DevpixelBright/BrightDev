/*
 * Author		: Mounika
 * Class		: Communities_W9Form_Controller
 * Description	: Contains methods related to IRS W9 Form functionality
 * Created Date	: 09/06/2020
 */

public class Communities_W9Form_Controller {
    public List<W_9__c> w9records { get; set; }
    public Boolean isAccessible { get; set; }
    
    //Controller initialize the default existing W9 records submitted by logged in user
    public Communities_W9Form_Controller() {
        try {
            String subscriptionId = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found ');

            List<Relationship__c>  relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId,
                                                            Subscription__r.Name, Subscription__r.Contact__r.Name, Broker_Office__r.Name
                                                    FROM    Relationship__c
                                                    WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                                                    AND     (Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY)
                                                    AND     Subscription_ID__c = :subscriptionId];
			if(relationships.Size() == 0) 
                throw new CustomException('We’re sorry, but you do not appear to have access to this page.');

            isAccessible = true;
            brokerSubmittedForms();
        }
        catch(Exception e) {
            isAccessible = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));   
        }
    }
    
    //Method to query 
    public void brokerSubmittedForms() {
        User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        w9records = [SELECT Id, Name, Company_Name__c, Office_ID__c, Office_ID__r.Name, TIN_Number__c, Submitted_By__c, Submitted_By__r.Name, Submitted_Date__c, CreatedDate
                     FROM 	W_9__c
                     WHERE 	Submitted_By__c = :u.ContactId];        
    }
    
    //Method to result the Broker Offices information based on search input
    @RemoteAction
    public static List<Account> searchBrokerOffices(String searchInput) {
        searchInput = String.escapeSingleQuotes(searchInput) + '%';
        List<Account> brokerOffices = [SELECT 	Id, Name, Account_Name__c 
                                       FROM 	Account 
                                       WHERE 	Name LIKE :searchInput //OR Account_Name__c LIKE :searchInput) 
                                       AND 		Status__c = 'Active'
                                       AND 		IsPersonAccount = false
                                       ORDER BY	Account_Name__c ASC
                                       LIMIT	50];
        return brokerOffices;
    }
    
    //Method to save W-9 data
    @RemoteAction
    public static String saveIRSData(String officeId, String officeName, String TIN) {
        User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        W_9__c record = new W_9__c();
        record.Company_Name__c = officeName;
      	record.Office_ID__c = officeId;
        record.TIN_Number__c = TIN;
        record.Submitted_By__c = u.ContactId;
        record.Submitted_Date__c = DateTime.now();
        insert record;
        return record.Id;
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

    //Method to get file id related to W9 record
    @RemoteAction
    public static String viewIRSUploadedDoc(String w9Id) {
        Attachment a = [SELECT Id, ParentId FROM Attachment WHERE ParentId =: w9Id];
        return a.Id;
    }
    
    public class CustomException extends Exception {}
}