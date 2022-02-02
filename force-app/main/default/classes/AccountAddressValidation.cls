public Class AccountAddressValidation {

    public Account account { get; set; }
    
    public AccountAddressValidation() {
        String accountId = ApexPages.currentPage().getParameters().get('id');
        account = [SELECT Id, 
                       Name, 
                       Street_Number__c, 
                       Street_Number_Suffix__c,
                       Street_Name__c,
                       Street_Type__c,
                       Street_Direction__c,
                       Unit_Type__c,
                       Unit__c,
                       City__c,
                       State__c,
                       Zip__c,
                       Zip_4__c,
                       Country__c,
                       Box__c,
                       Addl_Display_Name__c,
                       County__c,
                       QAS_Mailing_Street_Type__c,
                       QAS_Mailing_Street_Direction__c,
                       QAS_Mailing_Unit_Type__c,
                       QAS_Mailing_POBox__c,
                       QAS_Mailing_County__c,
                       IsPersonAccount
                FROM Account WHERE Id = :accountId AND IsPersonAccount = false]; 
                
                system.debug(account);                                             
    } 
    
    public PageReference saveAddress() {
        system.debug('****' + account);
        system.debug('Save address is called');
        account.AddressValidationStatus__c = 'Verified';
        update account;
        
        PageReference pageRef = new PageReference('/' + account.Id);
        return pageRef;        
    }
    
    public PageReference useEnteredAddress() {
        system.debug('****' + account);
        Account a = new Account();
        a.Id = account.Id;
        a.AddressValidationStatus__c = 'Not Required';
        System.debug('***' + a);
        update a;  
          
        PageReference pageRef = new PageReference('/' + account.Id);
        return pageRef;         
    }
}