public class Communities_OfficeDetails {
    
    public String officeId { get; set; } 
    public Account office { get; set; }
    public Account origOffice { get; set; }
    public Account officeCopy { get; set; }
    public Subscriptions__c subscription { get; set; }
    public Boolean isContactEdit { get; set; }
    public Boolean isAddressEdit { get; set; }
    public Attachment license { get;set; }
    public list<SelectOption> options {get; set;}
    public Boolean message { get; set; }
    public Boolean contactMessage { get; set; }
    public Boolean licenseMessage { get; set; }
    public Boolean addressMessage { get; set; } 
    public Map<String,String> officeIds { get; set; }
    public String relationshipType { get; set; }
    public String contactName { get; set; }
    public Case c { get; set; }

    public Communities_OfficeDetails() {
    
        resetMessageFalgs();
        message = true;
        
        try {
            List<User> currentUser = [SELECT   FederationIdentifier, Name
                                      FROM     User 
                                      WHERE    Id = :Userinfo.getUserId()];
            
            if (currentUser.size() == 0)
                throw new CustomException('Invalid MRIS Subscription ID: No Current User found >> ' + Userinfo.getUserId()); 

           /* String subscriptionId = currentUser[0].FederationIdentifier;*/
            
            String subscriptionId = ApexPages.currentPage().getParameters().get('sid');
            
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: Subscription does not exist' + currentUser);
                
            List<Subscriptions__c> subscriptionList = [SELECT Id,
                                                               Name
                                                        FROM   Subscriptions__c
                                                        WHERE  Name =: subscriptionId];
            if(subscriptionList.Size() != 1)
                throw new CustomException('Invalid subscription id : ' + subscriptionId);
            
            subscription = subscriptionList[0]; 

            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, 
                                     Relationship_Type__c, 
                                     Broker_Office__c,
                                     Broker_Office__r.ParentId,
                                     Broker_Office__r.Name,
                                     Subscription__r.Name, 
                                     Subscription__r.Contact__r.Name  
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription_ID__c  = :subscriptionId
                             AND     Status__c = 'Active'
                             AND	 Broker_Office__r.Status__c = 'Active'];
            
            if(relationships.size() > 0) { 
                officeId = relationships[0].Broker_Office__c;
                office = officeDetails();
                System.debug('*** Office: ' + office);
                
                /* Logic to find offices based on relationship type */
                List<String> parentIds = new List<String>();
                Map<String,String> asOffices = new Map<String,String>();
                Map<String,String> omOffices = new Map<String,String>();
                Boolean isBOR = false;
        
                for(Relationship__c relationship : relationships) {
                    system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
                    system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
                        
                    if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                        parentIds.add(relationship.Broker_Office__r.ParentId);            
                        
                    if(String.IsNotBlank(relationship.Broker_Office__c))
                        parentIds.add(relationship.Broker_Office__c);
                    
                    if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                        isBOR = true;                                  
                    } 
                    else if(relationship.Relationship_Type__c == 'Authorized Signer'){
                        asOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                    }
                    else if(relationship.Relationship_Type__c == 'Office Manager'){
                        omOffices.put(relationship.Broker_Office__c, relationship.Broker_Office__r.Name);
                    }
                } 
                
                if(!isBOR) {
                    if(asOffices.size() > 0){
                        officeIds = new Map<String,String>(asOffices);
                        relationshipType = 'Authorized Signer';
                        contactName = currentUser[0].Name;
                    }
                    else if(omOffices.size() > 0){
                        officeIds = new Map<String,String>(omOffices);
                        relationshipType = 'Office Manager';
                        contactName = currentUser[0].Name;
                    }
                }
                else {
                    List<Account> relatedAccounts = new List<Account>(); 
                    relatedAccounts = [SELECT Id, Name
                                       FROM   Account
                                       WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' 
                                      ];
                                   
                    officeIds = new Map<String,String>();
                                    
                    for(Account a : relatedAccounts)
                        officeIds.put(a.Id, a.Name);
                } 
                
                options = new list<SelectOption>();                                         
                for(String key : officeIds.keySet())
                    options.add(new SelectOption(key, officeIds.get(key)));               
            }
            else
                throw new CustomException('Broker office not found' + subscription.Name);
        }
        catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));              
        }
        
        isContactEdit = false;
        isAddressEdit = false; 
        license =new Attachment(); 
    }
    
    public void resetMessageFalgs() {
        contactMessage = false;
        addressMessage = false;
        licenseMessage = false;
        message = false;
    }
    
    public void reloadAccount() {
        try {
            System.debug('***officeId'+ officeId);
            office = officeDetails();
        }
        catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));              
        }                  
    }
    
    public Account officeDetails() {
        Account a = [SELECT Id,
                         Name,
                         Account_Name__c,
                         Phone, 
                         Status__c,
                         Fax,
                         Street_Number__c, 
                         Street_Name__c, 
                         QAS_Mailing_Street_Type__c, 
                         Street_Number_Suffix__c, 
                         QAS_Mailing_Street_Direction__c, 
                         QAS_Mailing_Unit_Type__c, 
                         Unit__c, 
                         Addl_Display_Name__c, 
                         Zip__c, 
                         Zip_4__c, 
                         City__c, 
                         State__c, 
                         QAS_Mailing_County__c,
                         IsPersonAccount,
                         Office_License_Number__c, 
                         Office_License_Expiration_Date__c,
                         Primary_Service_Jurisdiction__c,
                         Office_Email__c,
                         Website
                  FROM   Account
                  WHERE  Id = :officeId];
        return a;
    }
    
    public void editContactInfo() {
        isContactEdit = true;
    }
    
    public void saveContactInfo() {
        resetMessageFalgs();
        contactMessage = true;
        String notesdata;
        try {
            Account a = new Account();
            a.Id = office.Id;
            a.Phone = office.Phone;
            a.Fax = office.Fax;
            a.Office_Email__c = office.Office_Email__c;
            a.Website = office.Website;
            update a;
            
            officeDetails();             
            isContactEdit = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Contact information updated successfully'));
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
        
    public void cancelContactEdit() {
        office = officeDetails();
        isContactEdit = false;
    }
    
    public void saveLicenseInfo() {
        resetMessageFalgs();
        licenseMessage = true;
        try {
            Account a = new Account();
            a.Id = office.Id;
            a.Office_License_Number__c = office.Office_License_Number__c;
            a.Office_License_Expiration_Date__c = office.Office_License_Expiration_Date__c;
            update a;
            
            officeDetails();                 
            isContactEdit = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'License information updated successfully'));
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    
    public void editAddressInfo() {
        isAddressEdit = true;
        license =new Attachment(); 
    }
    
    public void saveAddressInfo() {
        resetMessageFalgs();
        addressMessage = true;    
        try {
            List<Group> queues = [SELECT Id FROM Group WHERE Name = 'Processing' AND Type = 'Queue'];
            if(!(queues.Size() > 0))
                throw new CustomException('Processing queue not found'); 
           
            Id queueId = queues[0].Id;
            
            origOffice = officeDetails();
            String description = 'Request to update address information. ';
            if(office.Account_Name__c != origOffice.Account_Name__c)
                description += 'Account Name changed from OldValue:"' + origOffice.Account_Name__c + '" to NewValue:"' + office.Account_Name__c + '", ';
            if(office.Street_Number__c != origOffice.Street_Number__c)
                description += 'Street Number from OldValue:"' + origOffice.Street_Number__c + '" to NewValue:"' + office.Street_Number__c + '", ';
            if(office.Street_Name__c!= origOffice.Street_Name__c)
                description += 'Street Name from OldValue:"' + origOffice.Street_Name__c + '" to NewValue:"' + office.Street_Name__c + '", ';
            if(office.QAS_Mailing_Street_Type__c != origOffice.QAS_Mailing_Street_Type__c)
                description += 'Street Type from OldValue:"' + origOffice.QAS_Mailing_Street_Type__c + '" to NewValue:"' + office.QAS_Mailing_Street_Type__c + '", ';
            if(office.Street_Number_Suffix__c != origOffice.Street_Number_Suffix__c)
                description += 'Street Number Suffix from OldValue:"' + origOffice.Street_Number_Suffix__c + '" to NewValue:"' + office.Street_Number_Suffix__c + '", ';
            if(office.QAS_Mailing_Street_Direction__c != origOffice.QAS_Mailing_Street_Direction__c)
                description += 'Street Direction from OldValue:"' + origOffice.QAS_Mailing_Street_Direction__c + '" to NewValue:"' + office.QAS_Mailing_Street_Direction__c + '", ';
            if(office.QAS_Mailing_Unit_Type__c != origOffice.QAS_Mailing_Unit_Type__c)
                description += 'Unit Type from OldValue:"' + origOffice.QAS_Mailing_Unit_Type__c + '" to NewValue:"' + office.QAS_Mailing_Unit_Type__c + '", ';
            if(office.Unit__c != origOffice.Unit__c)
                description += 'Unit from OldValue:"' + origOffice.Unit__c + '" to NewValue:"' + office.Unit__c + '", ';
            if(office.Addl_Display_Name__c!= origOffice.Addl_Display_Name__c)
                description += 'Additional Display Name from OldValue:"' + origOffice.Addl_Display_Name__c+ '" to NewValue:"' + office.Addl_Display_Name__c+ '", ';  
            if(office.Zip__c!= origOffice.Zip__c)
                description += 'Zip from OldValue:"' + origOffice.Zip__c+ '" to NewValue:"' + office.Zip__c+ '", ';  
            if(office.Zip_4__c!= origOffice.Zip_4__c)
                description += 'Zip+4 from OldValue:"' + origOffice.Zip_4__c+ '" to NewValue:"' + office.Zip_4__c+ '", ';  
            if(office.City__c!= origOffice.City__c)
                description += 'City from OldValue:"' + origOffice.City__c+ '" to NewValue:"' + office.City__c+ '", '; 
            if(office.State__c!= origOffice.State__c)
                description += 'State from OldValue:"' + origOffice.State__c+ '" to NewValue:"' + office.State__c+ '", ';
            if(office.QAS_Mailing_County__c!= origOffice.QAS_Mailing_County__c)
                description += 'County from OldValue:"' + origOffice.QAS_Mailing_County__c+ '" to NewValue:"' + office.QAS_Mailing_County__c+ '", ';                                                                                                                                                                           

            c = new Case();
            c.OwnerId = queues[0].Id;
            c.AccountId = office.Id;
            c.Product__c = 'MRIS Connect';
            c.Category__c= 'Contact Information';
            c.Status = 'Not Started';
            c.Origin = 'MRIS Connect';
            c.Priority = 'Normal';
            c.Reason = 'How To';
            c.Subject = 'Address Information Update';
            c.Description = description;
            insert c;
            
            /*
            Attachment a = new Attachment();
            a.Name = license.Name;
            a.Body = license.Body;
            a.ParentId = c.Id;
            insert a;
            */ 
                        
            isAddressEdit = false;
            office = officeDetails();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your request for a change in the Office Address has been succesfully submitted. The changes will be reflected after the Support staff confirms the request.'));
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
    
    @RemoteAction       
    public static String attachFile(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){     
        if(attachmentId == '' || attachmentId == null){     
            Attachment att = new Attachment(        
                ParentId = parentId,        
                Body = EncodingUtil.Base64Decode(base64BlobValue),      
                Name = fileName,        
                ContentType = contentType       
            );      
            insert att;     
            return att.Id;      
        }       
        else{       
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){       
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body       
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));      
            }       
                    
            //Return the Id of the attachment we are currently processing       
            return attachmentId;        
        }                           
    }     
    
    public void cancelAddressEdit() {
        office = officeDetails();
        isAddressEdit = false;
    }
    
    public void addressUpdated() {      
        addressMessage = true;      
        office = officeDetails();           
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your request for a change in the Office Address has been succesfully submitted. The changes will be reflected after the Support staff confirms the request.'));     
    }    
    
    /* TREND account update */
    public void saveTrendAccount() {
        try {
            update office;
            officeDetails(); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Office  information updated successfully.'));           
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }        
    }  
       /* BRIGHT or TREND account update */
    public void saveTrendOrBrightAccount() {
        try {
            update office;
            officeDetails(); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Office  information updated successfully.'));           
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }        
    }
    
    public class CustomException extends Exception {}
}