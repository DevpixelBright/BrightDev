@isTest 
private class QAScopyAddrToBillingContactTestClass {
    static testMethod void validateTriggerToCopyBillingAddress() {

    Contact testContact = new Contact();
            
            
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'USA';
            testContact.QAS_Mailing_County__c = 'DISTRICT OF COLUMBIA';
            testContact.State__c = 'DC';
            testContact.QAS_Mailing_Street_Direction__c = 'N';
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;
            testContact.QAS_Mailing_Street_Type__c = 'ST';
            testContact.Unit__c = '1';
            testContact.QAS_Mailing_Unit_Type__c = 'SU';
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.QAS_Mailing_Record_Type__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'P';
            testContact.County__c ='Fairfax';
           
    //Populate all fields of Contact example testContact.Name = 'xyx' 
    
       testContact.LastName = 'AbcTest';insert testContact;
    }
    
    static testMethod void validateTriggerToCopyBillingAddress2() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = 'FAIRFAX';
            testContact.State__c = 'DC';
            testContact.QAS_Mailing_Street_Direction__c = 'NE';
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;
            testContact.QAS_Mailing_Street_Type__c = 'AVE';
            testContact.Unit__c = '1';
            testContact.QAS_Mailing_Unit_Type__c = 'APT';
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'F';
            testContact.County__c ='Fairfax';
              
    //Populate all fields of Contact example testContact.Name = 'xyx' 
    
       testContact.LastName = 'AbcTest';insert testContact;
    
    }
    
      static testMethod void validateTriggerToCopyBillingAddress3() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';
            testContact.QAS_Mailing_Street_Direction__c = 'NW';
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;
            testContact.QAS_Mailing_Street_Type__c = 'BLFS';
            testContact.Unit__c = '1';
            testContact.QAS_Mailing_Unit_Type__c = 'BSMT';
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'G';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
    static testMethod void validateTriggerToCopyBillingAddress4() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';
            testContact.QAS_Mailing_Street_Direction__c = 'S';
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;
            testContact.QAS_Mailing_Street_Type__c = 'BLTY';
            testContact.Unit__c = '1';
            testContact.QAS_Mailing_Unit_Type__c = 'BSMT';
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'H';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
         }
         
         static testMethod void validateTriggerToCopyBillingAddress5() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'R';
            testContact.QAS_Mailing_Street_Direction__c = 'SE';
            testContact.QAS_Mailing_Street_Type__c = 'BRKS';
            testContact.QAS_Mailing_Unit_Type__c = 'BLDG';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
         }
         static testMethod void validateTriggerToCopyBillingAddress6() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'SW';
            testContact.QAS_Mailing_Street_Type__c = 'BGS';
            testContact.QAS_Mailing_Unit_Type__c = 'DEPT';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         static testMethod void validateTriggerToCopyBillingAddress7() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'E';
            testContact.QAS_Mailing_Street_Type__c = 'CTRS';
            testContact.QAS_Mailing_Unit_Type__c = 'FL';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress8() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'CIRS';
            testContact.QAS_Mailing_Unit_Type__c = 'FRNT';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress9() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'CLF';
            testContact.QAS_Mailing_Unit_Type__c = 'HNGR';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress10() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'CMNS';
            testContact.QAS_Mailing_Unit_Type__c = 'KEY';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress11() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'CVS';
            testContact.QAS_Mailing_Unit_Type__c = 'LBBY';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
         }
         
         static testMethod void validateTriggerToCopyBillingAddress12() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'DRS';
            testContact.QAS_Mailing_Unit_Type__c = 'LOT';
            testContact.County__c ='Fairfax';
              testContact.LastName = 'AbcTest';insert testContact;  
         }
         
         static testMethod void validateTriggerToCopyBillingAddress13() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'EXTS';
            testContact.QAS_Mailing_Unit_Type__c = 'LOWR';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress14() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'FLT';
            testContact.QAS_Mailing_Unit_Type__c = 'OFC';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress15() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'W';
            testContact.QAS_Mailing_Street_Type__c = 'FRDS';
            testContact.QAS_Mailing_Unit_Type__c = 'PH';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress16() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'FRGS';
            testContact.QAS_Mailing_Unit_Type__c = 'NULL';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress17() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'GDN';
            testContact.QAS_Mailing_Unit_Type__c = 'PIER';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress18() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'GLNS';
            testContact.QAS_Mailing_Unit_Type__c = 'REAR';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress19() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'GRNS';
            testContact.QAS_Mailing_Unit_Type__c = 'RM';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress20() {

    Contact testContact = new Contact();
           
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'GRVS';
            testContact.QAS_Mailing_Unit_Type__c = 'SIDE';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress21() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'HBRS';
            testContact.QAS_Mailing_Unit_Type__c = 'SLIP';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress22() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'JCTS';
            testContact.QAS_Mailing_Unit_Type__c = 'SPC';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress23() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = NULL;
            testContact.QAS_Mailing_Street_Type__c = 'LGTS';
            testContact.QAS_Mailing_Unit_Type__c = 'STOP';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress24() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'LF';
            testContact.QAS_Mailing_Unit_Type__c = 'STE';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress25() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'MNRS';
            testContact.QAS_Mailing_Unit_Type__c = 'TRLR';
             testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress26() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'MTWY';
            testContact.QAS_Mailing_Unit_Type__c = 'UNIT';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress27() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'OPAS';
            testContact.QAS_Mailing_Unit_Type__c = 'UPPR';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress28() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'PARK';
            testContact.QAS_Mailing_Unit_Type__c = NULL;
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress29() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'PKWY';
            testContact.QAS_Mailing_Unit_Type__c = 'NULL';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress30() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'PNE';
            testContact.County__c ='Fairfax';
            testContact.QAS_Mailing_Unit_Type__c = 'NULL';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress31() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'PTS';
            testContact.QAS_Mailing_Unit_Type__c = 'NULL';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress32() {

    Contact testContact = new Contact();
            
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = 'NULL';
            testContact.QAS_Mailing_Street_Type__c = 'PRTS';
            testContact.QAS_Mailing_Unit_Type__c = 'NULL';
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress33() {

    Contact testContact = new Contact();
           
            testContact.Status__c = 'In Progress';
            testContact.Phone = '2345678908';
            testContact.Addl_Display_Name__c = 'xyz';
            testContact.Box__c = NULL;
            testContact.City__c = 'WASHINGTON';
            testContact.QAS_Mailing_Country__c = 'CAN';
            testContact.QAS_Mailing_County__c = NULL;
            testContact.State__c = 'DC';            
            testContact.Street_Name__c = 'First';
            testContact.Street_Number__c ='1275';
            testContact.Street_Number_Suffix__c = NULL;            
            testContact.Unit__c = '1';            
            testContact.Zip__c ='20002';
            testContact.Zip_4__c = NULL;
            testContact.QAS_Mailing_POBox__c = NULL;
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Record_Type__c = 'S';
            testContact.QAS_Mailing_Street_Direction__c = NULL;
            testContact.QAS_Mailing_Street_Type__c = 'RAMP';
            testContact.QAS_Mailing_Unit_Type__c = NULL;
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
            
         }
         
          static testMethod void validateTriggerToCopyBillingAddress34() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'RPD';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress35() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'RDGS';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress36() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'RDS';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress37() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'RUE';
            
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress38() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'RUE';
            
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress39() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'SKWY';
            
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress40() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'SPUR';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress41() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'SGS';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress42() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'TRWY';
            
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress43() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'TRAK';
            
           testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress44() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'TRFY';
            
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress45() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'UPAS';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress46() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'UNS';
            
            testContact.County__c ='Fairfax';
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress47() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'VLYS';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress48() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'VLGS';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress49() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'WALK';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress50() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'WAYS';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress51() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'WL';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress52() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = NULL;
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress53() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'ALY';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress54() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'ANX';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress55() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'ARC';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress56() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'BYU';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
         static testMethod void validateTriggerToCopyBillingAddress57() {

    Contact testContact = new Contact(); 
            testContact.Copy_Address_to_Billing__c = true;
            testContact.QAS_Mailing_Street_Type__c = 'BCH';
            testContact.County__c ='Fairfax';
            
                testContact.LastName = 'AbcTest';insert testContact;
        
         }
         
       
        
 }