@isTest 
private class QASSubscriptionBeforeInsertUpdate {
	public static Account mockAccountRecord(){       
       CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
       cau.addAddrs();    
       Account a = new Account();
       a.name = 'ADA1234';
       a.type = 'Residential';
       a.Account_Name__c = 'Test Account';
       a.City__c = 'Herndon';
       a.Zip__c = '20171';
       a.QAS_Mailing_County__c = 'Fairfax';
       a.County__c = 'Fairfax';
       a.Street_Type__c = '';
       a.Billing_Street_Type__c = 'BLFS';
       a.QAS_Mailing_Street_Type__c ='test';
       insert a;
       return a;
   }
   
   public static Contact mockContactRecords(string AccountId) {     
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = AccountId; 
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20171';
        c.County__c = 'Fairfax';
        insert c;
        return c;
   }
   
    static testMethod void validateTriggerToCopyBillingAddress() {
    	Contact con = mockContactRecords(mockAccountRecord().Id);
    	
   		Subscriptions__c testSubscription = new Subscriptions__c();
            
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'Herndon';
            testSubscription.QAS_Mailing_Country__c = 'USA';
            testSubscription.QAS_Mailing_County__c = 'Fairfax';
            testSubscription.State__c = 'VA';
            testSubscription.QAS_Mailing_Street_Direction__c = 'N';
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;
            testSubscription.QAS_Mailing_Street_Type__c = 'ST';
            testSubscription.Unit__c = '1';
            testSubscription.QAS_Mailing_Unit_Type__c = 'SU';
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.QAS_Mailing_Record_Type__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'P';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            testSubscription.County__c = 'Fairfax';
            testSubscription.Contact__c = con.id;
    //Populate all fields of Subscription example testSubscription.Name = 'xyx' 
    		insert testSubscription;
    }
    /*
    static testMethod void validateTriggerToCopyBillingAddress2() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = 'FAIRFAX';
            testSubscription.State__c = 'DC';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NE';
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;
            testSubscription.QAS_Mailing_Street_Type__c = 'AVE';
            testSubscription.Unit__c = '1';
            testSubscription.QAS_Mailing_Unit_Type__c = 'APT';
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'F';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';  
    //Populate all fields of Subscription example testSubscription.Name = 'xyx' 
   			insert testSubscription;
    
    }
    
      static testMethod void validateTriggerToCopyBillingAddress3() {

		    Subscriptions__c testSubscription = new Subscriptions__c();
            testSubscription.Name = 'test';
            testSubscription.Status__c = 'In Progress';
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NW';
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;
            testSubscription.QAS_Mailing_Street_Type__c = 'BLFS';
            testSubscription.Unit__c = '1';
            testSubscription.QAS_Mailing_Unit_Type__c = 'BSMT';
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'G';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            insert testSubscription;
            
         }
    static testMethod void validateTriggerToCopyBillingAddress4() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';
            testSubscription.QAS_Mailing_Street_Direction__c = 'S';
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;
            testSubscription.QAS_Mailing_Street_Type__c = 'BLTY';
            testSubscription.Unit__c = '1';
            testSubscription.QAS_Mailing_Unit_Type__c = 'BSMT';
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'H';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            insert testSubscription;
         }
         
         static testMethod void validateTriggerToCopyBillingAddress5() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'R';
            testSubscription.QAS_Mailing_Street_Direction__c = 'SE';
            testSubscription.QAS_Mailing_Street_Type__c = 'BRKS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'BLDG';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
         }
         static testMethod void validateTriggerToCopyBillingAddress6() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'SW';
            testSubscription.QAS_Mailing_Street_Type__c = 'BGS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'DEPT';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            insert testSubscription;
            
         }
         static testMethod void validateTriggerToCopyBillingAddress7() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'E';
            testSubscription.QAS_Mailing_Street_Type__c = 'CTRS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'FL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress8() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'CIRS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'FRNT';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';

            insert testSubscription;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress9() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'CLF';
            testSubscription.QAS_Mailing_Unit_Type__c = 'HNGR';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress10() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'CMNS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'KEY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress11() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'CVS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'LBBY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
         }
         
         static testMethod void validateTriggerToCopyBillingAddress12() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'DRS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'LOT';
          testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
           insert testSubscription;  
         }
         
         static testMethod void validateTriggerToCopyBillingAddress13() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'EXTS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'LOWR';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress14() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'FLT';
            testSubscription.QAS_Mailing_Unit_Type__c = 'OFC';
            
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress15() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'W';
            testSubscription.QAS_Mailing_Street_Type__c = 'FRDS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'PH';
            
             insert testSubscription;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress16() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'FRGS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'NULL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress17() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'GDN';
            testSubscription.QAS_Mailing_Unit_Type__c = 'PIER';
            
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress18() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'GLNS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'REAR';
            
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress19() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'GRNS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'RM';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress20() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'GRVS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'SIDE';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress21() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'HBRS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'SLIP';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress22() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'JCTS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'SPC';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress23() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = NULL;
            testSubscription.QAS_Mailing_Street_Type__c = 'LGTS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'STOP';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress24() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'LF';
            testSubscription.QAS_Mailing_Unit_Type__c = 'STE';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress25() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'MNRS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'TRLR';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress26() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'MTWY';
            testSubscription.QAS_Mailing_Unit_Type__c = 'UNIT';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress27() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'OPAS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'UPPR';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress28() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'PARK';
            testSubscription.QAS_Mailing_Unit_Type__c = NULL;
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress29() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'PKWY';
            testSubscription.QAS_Mailing_Unit_Type__c = 'NULL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress30() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'PNE';
            testSubscription.QAS_Mailing_Unit_Type__c = 'NULL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress31() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'PTS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'NULL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress32() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = 'NULL';
            testSubscription.QAS_Mailing_Street_Type__c = 'PRTS';
            testSubscription.QAS_Mailing_Unit_Type__c = 'NULL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress33() {

    Subscriptions__c testSubscription = new Subscriptions__c();
              
            testSubscription.Name = 'test';
                
            testSubscription.Status__c = 'In Progress';
                  
            testSubscription.Addl_Display_Name__c = 'xyz';
            testSubscription.Box__c = NULL;
            testSubscription.City__c = 'WASHINGTON';
            testSubscription.QAS_Mailing_Country__c = 'CAN';
            testSubscription.QAS_Mailing_County__c = NULL;
            testSubscription.State__c = 'DC';            
            testSubscription.Street_Name__c = 'First';
            testSubscription.Street_Number__c ='1275';
            testSubscription.Street_Number_Suffix__c = NULL;            
            testSubscription.Unit__c = '1';            
            testSubscription.Zip__c ='20002';
            testSubscription.Zip_4__c = NULL;
            testSubscription.QAS_Mailing_POBox__c = NULL;
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Record_Type__c = 'S';
            testSubscription.QAS_Mailing_Street_Direction__c = NULL;
            testSubscription.QAS_Mailing_Street_Type__c = 'RAMP';
            testSubscription.QAS_Mailing_Unit_Type__c = NULL;
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress34() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'RPD';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress35() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'RDGS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress36() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'RDS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress37() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'RUE';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress38() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'RUE';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress39() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'SKWY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress40() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'SPUR';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress41() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'SGS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress42() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'TRWY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress43() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'TRAK';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress44() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'TRFY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress45() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'UPAS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress46() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'UNS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress47() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VLYS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress48() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VLGS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress49() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'WALK';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress50() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'WAYS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress51() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'WL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress52() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = NULL;
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress53() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'ALY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress54() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'ANX';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress55() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'ARC';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress56() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'BYU';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress57() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'BCH';
            
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress58() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'SQS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress59() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'WLS';
            
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress590() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'WAY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress60() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VIS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress61() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress62() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VLG';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress63() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VW';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress64() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VIA';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress65() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'VLY';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress66() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'UN';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress67() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'TPKE';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress68() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'TUNL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress69() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'TRLR';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress70() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'TRCE';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress71() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'XRDS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
          static testMethod void validateTriggerToCopyBillingAddress72() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'XRDS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress73() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'CURV';
            
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
             insert testSubscription;
        
         }
         
          static testMethod void validateTriggerToCopyBillingAddress74() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'DL';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
          static testMethod void validateTriggerToCopyBillingAddress75() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'DM';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }
         
          static testMethod void validateTriggerToCopyBillingAddress76() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'DV';
            
            
             insert testSubscription;
        
         }
         
          static testMethod void validateTriggerToCopyBillingAddress77() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'DR';
            
            
             insert testSubscription;
        
         }
         
          static testMethod void validateTriggerToCopyBillingAddress78() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'EST';
            
            
             insert testSubscription;
        
         }
         
          static testMethod void validateTriggerToCopyBillingAddress79() {

    Subscriptions__c testSubscription = new Subscriptions__c(); 
            testSubscription.Copy_Address_to_Billing__c = true;
            testSubscription.QAS_Mailing_Street_Type__c = 'ESTS';
            testSubscription.Contact_Type__c = 'Broker';
            testSubscription.Subscription_Type__c = 'Licensee';
            
             insert testSubscription;
        
         }*/
       
        
 }