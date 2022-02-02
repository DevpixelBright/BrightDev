public Class ContactAddressValidation {
    public String addressString { get; set; }
    public Contact contact { get; set; }
    public ContactAddressValidation() {
        String contactId = ApexPages.currentPage().getParameters().get('id');
        contact = [SELECT Id, 
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
                       QAS_Mailing_County__c 
                FROM Contact WHERE Id = :contactId];                                              
    } 
    
    public PageReference saveAddress() {
        System.debug('***' + contact);
        contact.AddressValidationStatus__c = 'Verified';
        update contact;
        
        PageReference pageRef = new PageReference('/' + contact.Id);
        return pageRef;        
    }
    
    public PageReference useEnteredAddress() {
        Contact c = new Contact();
        c.Id = contact.Id;
        c.AddressValidationStatus__c = 'Not Required';
        update c;  
          
        PageReference pageRef = new PageReference('/' + contact.Id);
        return pageRef;         
    }
}