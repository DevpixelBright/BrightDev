public class VendorCommunity_OfficeDetails_Controller {
    
    public String officeId { get; set; } 
    public Account office { get; set; }
    public Boolean message { get; set; }
    public Boolean contactMessage { get; set; }
    public Boolean addressMessage { get; set; } 
    public string accountId {get; set;}

    public VendorCommunity_OfficeDetails_Controller() {
    
        resetMessageFalgs();
        message = true;
        
        try {
            List<User> currentUser = [SELECT   FederationIdentifier, Name
                                      FROM     User 
                                      WHERE    Id =: Userinfo.getUserId()];
            
            if (currentUser.size() == 0)
                throw new CustomException('Invalid User ID: No Current User found >> ' + Userinfo.getUserId()); 
            
            accountId = ApexPages.currentPage().getParameters().get('id');
            
            if (String.IsBlank(accountId))
                throw new CustomException('Invalid Account ID: Account does not exist' + currentUser);                
           
            office = officeDetails();
            
            if(office != null && office.Id != null) {
                
                System.debug('*** Office: ' + office);
                officeId = office.Id;
                
                
            }
            else
                throw new CustomException('Vendor office not found: ' + Office.Name);
        }
        catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));              
        } 
    }
    
    public void resetMessageFalgs() {
        contactMessage = false;
        addressMessage = false;
        message = false;
    }
    
    public Account officeDetails() {
        Account a = [SELECT Id,
                         Name,
                         Account_Name__c,
                         Phone, 
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
                         Primary_Service_Jurisdiction__c
                  FROM   Account
                  WHERE  Name =: accountId]; // officeId];
        return a;
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
            update a;
            
            officeDetails();             
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Contact information updated successfully'));
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
    }
        
    public void cancelContactEdit() {
        office = officeDetails();
    }
     
    public void cancelAddressEdit() {
        office = officeDetails();
    }
    
    public void saveAccount() {
        try { 
            if(String.isNotBlank(office.State__c)){           
                update office;
                officeDetails(); 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Office  information updated successfully.')); 
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'State: You must enter a value.'));
            }
           
        }
        catch(Exception e) {
          
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }        
    }                 
    
    public class CustomException extends Exception {}
}