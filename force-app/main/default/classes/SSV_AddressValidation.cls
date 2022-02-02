public Class SSV_AddressValidation {
    /* Smart Street Validation*/
    
    public sObject record { get; set; }
    public Id recordId { get; set; }
    public String objectName { get; set; }
    
    public SSV_AddressValidation(){
        recordId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
        if(String.isNotBlank(recordId)){
            objectName = recordId.getSObjectType().getDescribe().getName();
        
            String query = 'SELECT Name, Street_Number__c, Street_Number_Suffix__c, Street_Name__c, Street_Type__c, Street_Direction__c,';
                  query += 'Unit_Type__c, Unit__c, City__c, State__c, Zip__c, Zip_4__c, Country__c, Box__c, County__c,';
                  query += 'Addl_Display_Name__c, QAS_Mailing_Street_Type__c, QAS_Mailing_Street_Direction__c, QAS_Mailing_Unit_Type__c,';
                  if(objectName == 'Subscriptions__c') {
                      query += 'Service_Jurisdiction__c,  Billing_Street_Number__c, Billing_Street_Suffix__c, Billing_Street_Name__c,'; 
                      query += 'QAS_Billing_Street_Type__c, QAS_Billing_Street_Direction__c, QAS_Billing_Unit_Type__c, Billing_Unit_Number__c,';
                      query += 'Billing_City__c, Billing_State__c, Billing_Zip__c, Billing_Zip_4__c, Billing_Country__c, Billing_Box__c,';
                      query += 'Billing_Addl_Display_Name__c, QAS_Billing_County__c,';
                  }
                  if(objectName == 'Account'){
                      query += 'Account.IsPersonAccount,';
                  }
                  query += 'QAS_Mailing_POBox__c, QAS_Mailing_County__c FROM ' + objectName + ' WHERE Id = :recordId';
                  
            record = Database.query(query);
        }
        
    }
    
    public PageReference saveAddress() {
        system.debug('****' + record);
        system.debug('Save address is called');
        record.put('AddressValidationStatus__c', 'Verified');
        update record;
        
        PageReference pageRef = new PageReference('/' + record.Id);
        return pageRef;        
    }
    
    public PageReference useEnteredAddress() {
        system.debug('****' + record);
        Schema.SObjectType sot = record.getSObjectType();
        SObject r = sot.newSObject() ;
        r.Id = record.Id;
        r.put('AddressValidationStatus__c', 'Not Required');
        System.debug('***' + r);
        update r;  
          
        PageReference pageRef = new PageReference('/' + r.Id);
        return pageRef;         
    }
    
    public static void setAddressValidationStatus(Map<Id,sObject> oldRecords, List<sObject> newRecords, Boolean isInsert){
        if(isInsert){
            for(sObject  newRecord : newRecords){
                system.debug('******* newRecord**** '+newRecord.get('AddressValidationStatus__c'));
                if(newRecord.get('AddressValidationStatus__c') != null && newRecord.get('AddressValidationStatus__c')!='Not Required')
                    newRecord.put('AddressValidationStatus__c', 'To be verify'); 
            }
                
        }
        else{
            for(sObject record : newRecords){
                Schema.SObjectType sot = record.getSObjectType();
                SObject oldRecord = sot.newSObject();
                oldRecord = oldRecords.get(record.Id);
                system.debug('Before: ' + record.get('AddressValidationStatus__c'));
                
                if(record.get('AddressValidationStatus__c') != 'Verified' && record.get('AddressValidationStatus__c') != 'Not Required'){
                    if(record.get('Street_Number__c') != oldrecord.get('Street_Number__c') || 
                       record.get('Street_Name__c') != oldrecord.get('Street_Name__c') || 
                       record.get('City__c') != oldrecord.get('City__c') || 
                       record.get('State__c') != oldrecord.get('State__c') || 
                       record.get('Street_Type__c') != oldrecord.get('Street_Type__c')  || 
                       record.get('Street_Direction__c') != oldrecord.get('Street_Direction__c') || 
                       record.get('Unit_Type__c') != oldrecord.get('Unit_Type__c') || 
                       record.get('Unit__c') != oldrecord.get('Unit__c') ||
                       record.get('Street_Number_Suffix__c') != oldrecord.get('Street_Number_Suffix__c') || 
                       record.get('Zip__c') != oldrecord.get('Zip__c') || 
                       record.get('Zip_4__c') != oldrecord.get('Zip_4__c') || 
                       record.get('Country__c') != oldrecord.get('Country__c') || 
                       record.get('Box__c') != oldrecord.get('Box__c')  || 
                       record.get('County__c') != oldrecord.get('County__c') || 
                       record.get('QAS_Mailing_Street_Type__c') != oldrecord.get('QAS_Mailing_Street_Type__c') || 
                       record.get('QAS_Mailing_Street_Direction__c') != oldrecord.get('QAS_Mailing_Street_Direction__c') ||
                       record.get('QAS_Mailing_Unit_Type__c') != oldrecord.get('QAS_Mailing_Unit_Type__c') || 
                       record.get('QAS_Mailing_POBox__c') != oldrecord.get('QAS_Mailing_POBox__c') || 
                       record.get('QAS_Mailing_County__c') != oldrecord.get('QAS_Mailing_County__c') ){
                           record.put('AddressValidationStatus__c', 'To be verify');
                    }
                }
                
                system.debug('After: ' + record.get('AddressValidationStatus__c'));   
                
                if(record.get('AddressValidationStatus__c') != 'To be verify')
                    record.put('AddressValidationStatus__c', null);
                    
                system.debug('Final: ' + record.get('AddressValidationStatus__c'));
    
            }
        }   
    }    
}