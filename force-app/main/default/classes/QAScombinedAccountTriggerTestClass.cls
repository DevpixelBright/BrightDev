@isTest 
private class QAScombinedAccountTriggerTestClass {

public static Account demoAccount(){
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            Account testAccount = new Account();
            testAccount.OfficeKey__c = 'ABCD1234';
            testAccount.Name = 'ABCD1234';
            testAccount.Type = 'Appraiser';
            testAccount.Account_Name__c = 'ABCD1234';
            testAccount.Status__c = 'In Progress';
            testAccount.Phone = '2345678908';
            testAccount.Addl_Display_Name__c = 'xyz';
            testAccount.Box__c = NULL;
            testAccount.City__c = 'Herndon';
            testAccount.QAS_Mailing_Country__c = 'USA';
            testAccount.QAS_Mailing_County__c = 'Fairfax';
            testAccount.State__c = 'VA';
            testAccount.QAS_Mailing_Street_Direction__c = 'N';
            testAccount.Street_Name__c = 'First';
            testAccount.Street_Number__c ='1275';
            testAccount.Street_Number_Suffix__c = NULL;
            testAccount.QAS_Mailing_Street_Type__c = 'PTS';
            testAccount.QAS_Billing_Street_Type__c = 'PTS';
            testAccount.Unit__c = '1';
            testAccount.Zip__c ='20002';
            testAccount.Zip_4__c = NULL;
            testAccount.QAS_Mailing_POBox__c = '1234';
            testAccount.Copy_Address_to_Billing__c = true;
            testAccount.QAS_Mailing_Record_Type__c = 'P';
              
            return testAccount;
            
         }
    static testMethod void validateTriggerToCopyBillingAddress() {
    CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
    cau.addAddrs();
    Account testAccount = new Account();
            testAccount.OfficeKey__c = 'ABCD1234';
            testAccount.Name = 'ABCD1234';
            testAccount.Type = 'Appraiser';
            testAccount.Account_Name__c = 'ABCD1234';
            testAccount.Status__c = 'In Progress';
            testAccount.Phone = '2345678908';
            testAccount.Addl_Display_Name__c = 'xyz';
            testAccount.Box__c = NULL;
            testAccount.City__c = 'Herndon';
            testAccount.QAS_Mailing_Country__c = 'USA';
            testAccount.QAS_Mailing_County__c = 'Fairfax';
            testAccount.State__c = 'VA';
            testAccount.QAS_Mailing_Street_Direction__c = 'N';
            testAccount.Street_Name__c = 'First';
            testAccount.Street_Number__c ='1275';
            testAccount.Street_Number_Suffix__c = NULL;
            testAccount.QAS_Mailing_Street_Type__c = 'ST';
            testAccount.Unit__c = '1';
            testAccount.Zip__c ='20002';
            testAccount.Zip_4__c = NULL;
            testAccount.QAS_Mailing_POBox__c = '1234';
            testAccount.QAS_Mailing_Record_Type__c = NULL;
            testAccount.Copy_Address_to_Billing__c = true;
            testAccount.QAS_Mailing_Record_Type__c = 'P';
              
    
            insert testAccount;
            
            
    }
    
    static testMethod void validateTriggerToCopyBillingAddress2() {
             Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'UNS';
            testAccount.QAS_Billing_Street_Type__c = 'UNS';
            insert testAccount;                
    }
   
      static testMethod void validateTriggerToCopyBillingAddress3() {
         Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'TRFY';
            testAccount.QAS_Billing_Street_Type__c = 'TRFY';
            insert testAccount;            
         }
          static testMethod void validateTriggerToCopyBillingAddress4() {
              Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BLFS';
            testAccount.QAS_Billing_Street_Type__c = 'BLFS';
            insert testAccount;
            
         }
         static testMethod void validateTriggerToCopyBillingAddress5() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BLTY';
            testAccount.QAS_Billing_Street_Type__c = 'BLTY';
            insert testAccount;
            
         }
         static testMethod void validateTriggerToCopyBillingAddress6() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BRKS';
            testAccount.QAS_Billing_Street_Type__c = 'BRKS';
            insert testAccount;
            
         }
         static testMethod void validateTriggerToCopyBillingAddress7() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BGS';
            testAccount.QAS_Billing_Street_Type__c = 'BGS';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress8() {
             Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CTRS';
            testAccount.QAS_Billing_Street_Type__c = 'CTRS';
            insert testAccount;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress9() {
                Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CIRS';
            testAccount.QAS_Billing_Street_Type__c = 'CIRS';
            insert testAccount;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress10() {
             Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CLF';
            testAccount.QAS_Billing_Street_Type__c = 'CLF';
            insert testAccount;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress11() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CMNS';
            testAccount.QAS_Billing_Street_Type__c = 'CMNS';
            insert testAccount;
         }
         
          static testMethod void validateTriggerToCopyBillingAddress12() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CVS';
            testAccount.QAS_Billing_Street_Type__c = 'CVS';
            insert testAccount;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress13() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'DRS';
            testAccount.QAS_Billing_Street_Type__c = 'DRS';
            insert testAccount;
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress14() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'EXTS';
            testAccount.QAS_Billing_Street_Type__c = 'EXTS';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress15() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FLT';
            testAccount.QAS_Billing_Street_Type__c = 'FLT';
            insert testAccount;
         }
          static testMethod void validateTriggerToCopyBillingAddress16() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRDS';
            testAccount.QAS_Billing_Street_Type__c = 'FRDS';
            insert testAccount;
         }
         
         static testMethod void validateTriggerToCopyBillingAddress17() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRGS';
            testAccount.QAS_Billing_Street_Type__c = 'FRGS';
            insert testAccount;
         }
          static testMethod void validateTriggerToCopyBillingAddress18() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GDN';
            testAccount.QAS_Billing_Street_Type__c = 'GDN';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress19() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GLNS';
            testAccount.QAS_Billing_Street_Type__c = 'GLNS';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress20() {
                                   Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GRNS';
            testAccount.QAS_Billing_Street_Type__c = 'GRNS';
            insert testAccount;
         }
    static testMethod void validateTriggerToCopyBillingAddress21() {
                          Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GRVS';
            testAccount.QAS_Billing_Street_Type__c = 'GRVS';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress22() {
                          Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'HBRS';
            testAccount.QAS_Billing_Street_Type__c = 'HBRS';
            insert testAccount;
              
            
         }
         static testMethod void validateTriggerToCopyBillingAddress23() {
                          Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'JCTS';
            testAccount.QAS_Billing_Street_Type__c = 'JCTS';
            insert testAccount;
              
            
         }
         
         static testMethod void validateTriggerToCopyBillingAddress24() {
                          Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'LGTS';
            testAccount.QAS_Billing_Street_Type__c = 'LGTS';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress25() {
                 Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'LF';
            testAccount.QAS_Billing_Street_Type__c = 'LF';
            insert testAccount;
            
         }
          static testMethod void validateTriggerToCopyBillingAddress26() {

                 Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'MNRS';
            testAccount.QAS_Billing_Street_Type__c = 'MNRS';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress27() {
                 Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'MTWY';
            testAccount.QAS_Billing_Street_Type__c = 'MTWY';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress28() {
                 Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'OPAS';
            testAccount.QAS_Billing_Street_Type__c = 'OPAS';
            insert testAccount;
         }
         static testMethod void validateTriggerToCopyBillingAddress29() {
                 Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'PNE';
            testAccount.QAS_Billing_Street_Type__c = 'PNE';
            insert testAccount;
         }
         
         
         
         static testMethod void validateTriggerToCopyBillingAddress30() {
             Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'PTS';
            testAccount.QAS_Billing_Street_Type__c = 'PTS';
            insert testAccount;
         }
       
         
         
         static testMethod void validateTriggerToCopyBillingAddress31() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'PRTS';
            testAccount.QAS_Billing_Street_Type__c = 'PRTS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress32() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'RAMP';
            testAccount.QAS_Billing_Street_Type__c = 'RAMP';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress33() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'RPD';
            testAccount.QAS_Billing_Street_Type__c = 'RPD';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress34() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'RDGS';
            testAccount.QAS_Billing_Street_Type__c = 'RDGS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress35() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'RDS';
            testAccount.QAS_Billing_Street_Type__c = 'RDS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress36() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'RUE';
            testAccount.QAS_Billing_Street_Type__c = 'RUE';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress37() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'SKWY';
            testAccount.QAS_Billing_Street_Type__c = 'SKWY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress38() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'SQS';
            testAccount.QAS_Billing_Street_Type__c = 'SQS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress39() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'TRWY';
            testAccount.QAS_Billing_Street_Type__c = 'TRWY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress40() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'TRAK';
            testAccount.QAS_Billing_Street_Type__c = 'TRAK';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress41() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'TRFY';
            testAccount.QAS_Billing_Street_Type__c = 'TRFY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress42() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'UPAS';
            testAccount.QAS_Billing_Street_Type__c = 'UPAS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress43() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'UNS';
            testAccount.QAS_Billing_Street_Type__c = 'UNS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress44() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'VLYS';
            testAccount.QAS_Billing_Street_Type__c = 'VLYS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress45() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'VLGS';
            testAccount.QAS_Billing_Street_Type__c = 'VLGS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress46() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'WALK';
            testAccount.QAS_Billing_Street_Type__c = 'WALK';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress47() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'WAYS';
            testAccount.QAS_Billing_Street_Type__c = 'WAYS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress48() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'ALY';
            testAccount.QAS_Billing_Street_Type__c = 'ALY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress49() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'ANX';
            testAccount.QAS_Billing_Street_Type__c = 'ANX';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress50() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'ARC';
            testAccount.QAS_Billing_Street_Type__c = 'ARC';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress51() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BYU';
            testAccount.QAS_Billing_Street_Type__c = 'BYU';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress52() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BCH';
            testAccount.QAS_Billing_Street_Type__c = 'BCH';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress53() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BLF';
            testAccount.QAS_Billing_Street_Type__c = 'BLF';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress54() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BTM';
            testAccount.QAS_Billing_Street_Type__c = 'BTM';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress55() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BLVD';
            testAccount.QAS_Billing_Street_Type__c = 'BLVD';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress56() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BR';
            testAccount.QAS_Billing_Street_Type__c = 'BR';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress57() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BRG';
            testAccount.QAS_Billing_Street_Type__c = 'BRG';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress58() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BRK';
            testAccount.QAS_Billing_Street_Type__c = 'BRK';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress59() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CP';
            testAccount.QAS_Billing_Street_Type__c = 'CP';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress60() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'BYP';
            testAccount.QAS_Billing_Street_Type__c = 'BYP';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress61() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CYN';
            testAccount.QAS_Billing_Street_Type__c = 'CYN';
            insert testAccount;
                    
         }
         
         static testMethod void validateTriggerToCopyBillingAddress62() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CPE';
            testAccount.QAS_Billing_Street_Type__c = 'CPE';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress63() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CSWY';
            testAccount.QAS_Billing_Street_Type__c = 'CSWY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress64() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CTR';
            testAccount.QAS_Billing_Street_Type__c = 'CTR';
            insert testAccount;
                    
         
         }
         static testMethod void validateTriggerToCopyBillingAddress65() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CIR';
            testAccount.QAS_Billing_Street_Type__c = 'CIR';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress66() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CLFS';
            testAccount.QAS_Billing_Street_Type__c = 'CLFS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress67() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CLB';
            testAccount.QAS_Billing_Street_Type__c = 'CLB';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress68() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'COR';
            testAccount.QAS_Billing_Street_Type__c = 'COR';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress69() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CORS';
            testAccount.QAS_Billing_Street_Type__c = 'CORS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress70() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CRSE';
            testAccount.QAS_Billing_Street_Type__c = 'CRSE';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress71() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CT';
            testAccount.QAS_Billing_Street_Type__c = 'CT';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress72() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CTS';
            testAccount.QAS_Billing_Street_Type__c = 'CTS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress73() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CV';
            testAccount.QAS_Billing_Street_Type__c = 'CV';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress74() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CRK';
            testAccount.QAS_Billing_Street_Type__c = 'CRK';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress75() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CRES';
            testAccount.QAS_Billing_Street_Type__c = 'CRES';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress76() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'XING';
            testAccount.QAS_Billing_Street_Type__c = 'XING';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress77() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'XRD';
            testAccount.QAS_Billing_Street_Type__c = 'XRD';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress78() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'XRDS';
            testAccount.QAS_Billing_Street_Type__c = 'XRDS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress79() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'CURV';
            testAccount.QAS_Billing_Street_Type__c = 'CURV';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress80() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'DL';
            testAccount.QAS_Billing_Street_Type__c = 'DL';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress81() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'DM';
            testAccount.QAS_Billing_Street_Type__c = 'DM';
            insert testAccount;
                    
         }
         
         static testMethod void validateTriggerToCopyBillingAddress82() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'DV';
            testAccount.QAS_Billing_Street_Type__c = 'DV';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress83() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'DR';
            testAccount.QAS_Billing_Street_Type__c = 'DR';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress84() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'EST';
            testAccount.QAS_Billing_Street_Type__c = 'EST';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress85() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'ESTS';
            testAccount.QAS_Billing_Street_Type__c = 'ESTS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress86() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'EXPY';
            testAccount.QAS_Billing_Street_Type__c = 'EXPY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress87() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'EXT';
            testAccount.QAS_Billing_Street_Type__c = 'EXT';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress88() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FALL';
            testAccount.QAS_Billing_Street_Type__c = 'FALL';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress89() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRY';
            testAccount.QAS_Billing_Street_Type__c = 'FRY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress90() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FLD';
            testAccount.QAS_Billing_Street_Type__c = 'FLD';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress91() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FLDS';
            testAccount.QAS_Billing_Street_Type__c = 'FLDS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress92() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FLTS';
            testAccount.QAS_Billing_Street_Type__c = 'FLTS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress93() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRD';
            testAccount.QAS_Billing_Street_Type__c = 'FRD';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress94() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRST';
            testAccount.QAS_Billing_Street_Type__c = 'FRST';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress95() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRG';
            testAccount.QAS_Billing_Street_Type__c = 'FRG';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress96() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRK';
            testAccount.QAS_Billing_Street_Type__c = 'FRK';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress97() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FT';
            testAccount.QAS_Billing_Street_Type__c = 'FT';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress98() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FWY';
            testAccount.QAS_Billing_Street_Type__c = 'FWY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress99() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GDNS';
            testAccount.QAS_Billing_Street_Type__c = 'GDNS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress100() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GTWY';
            testAccount.QAS_Billing_Street_Type__c = 'GTWY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress101() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GLN';
            testAccount.QAS_Billing_Street_Type__c = 'GLN';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress102() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GRN';
            testAccount.QAS_Billing_Street_Type__c = 'GRN';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress103() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'GRV';
            testAccount.QAS_Billing_Street_Type__c = 'GRV';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress104() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'HBR';
            testAccount.QAS_Billing_Street_Type__c = 'HBR';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress105() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'HVN';
            testAccount.QAS_Billing_Street_Type__c = 'HVN';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress106() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'HTS';
            testAccount.QAS_Billing_Street_Type__c = 'HTS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress107() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'HWY';
            testAccount.QAS_Billing_Street_Type__c = 'HWY';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress108() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'HOLW';
            testAccount.QAS_Billing_Street_Type__c = 'HOLW';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress109() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'INLT';
            testAccount.QAS_Billing_Street_Type__c = 'INLT';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress110() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'IS';
            testAccount.QAS_Billing_Street_Type__c = 'IS';
            insert testAccount;
                    
         }
         
         static testMethod void validateTriggerToCopyBillingAddress111() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'ISS';
            testAccount.QAS_Billing_Street_Type__c = 'ISS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress112() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'ISLE';
            testAccount.QAS_Billing_Street_Type__c = 'ISLE';
            insert testAccount;
                    
         }static testMethod void validateTriggerToCopyBillingAddress113() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'FRKS';
            testAccount.QAS_Billing_Street_Type__c = 'FRKS';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress114() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'JCT';
            testAccount.QAS_Billing_Street_Type__c = 'JCT';
            insert testAccount;
                    
         }
         static testMethod void validateTriggerToCopyBillingAddress115() {
            Account testAccount = demoAccount();
            testAccount.QAS_Mailing_Street_Type__c = 'KY';
            testAccount.QAS_Billing_Street_Type__c = 'KY';
            insert testAccount;
                    
         }
         
         
         
        
 }