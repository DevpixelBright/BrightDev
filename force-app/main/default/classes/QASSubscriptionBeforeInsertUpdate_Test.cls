@isTest 
private class QASSubscriptionBeforeInsertUpdate_Test{

    private static testMethod void doTestOne() {
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
               
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            
            Account a = createAccount();
            Contact c = createContact(a.Id);

            Subscriptions__c s = new  Subscriptions__c();
            s.Name = 'Test Subscription';
            s.Contact__c = c.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '123112';
            s.Related_Location_Broker_Office__c = a.Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
            s.County__c = 'Fairfax';
            s.Public_Email__c = 'test@test.com';
            s.Addl_Display_Name__c = 'Test';
            s.QAS_Mailing_Country__c = 'USA';
            s.QAS_Mailing_County__c = 'Fairfax';
            s.State__c = 'VA';
            s.QAS_Mailing_Street_Direction__c = 'NORTH';
            s.Street_Name__c = 'First';
            s.Street_Number__c ='1275';
            s.Street_Number_Suffix__c = NULL;
            s.Unit__c = '1';
            s.QAS_Mailing_Unit_Type__c = 'SU';
            s.Zip__c ='20002';
            s.Zip_4__c = NULL;
            s.QAS_Mailing_POBox__c = NULL;
            s.QAS_Mailing_Record_Type__c = NULL;
            s.Copy_Address_to_Billing__c = true;
            s.QAS_Mailing_Record_Type__c = 'P';
            s.QAS_Billing_Record_Type__c = 'P';
            s.Primary__c = true;
            insert s;
            
            Test.stopTest();
        }    
    }
    
    private Static testMethod void doTestTwo() {
        try {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account a = createAccount();
        Contact c = createContact(a.Id);        
        
        List<String> streetType = new List<String>{
            'BLFS', 'BRKS','BLTY','BGS','CTRS','CIRS','CLF', 'CMNS','CVS', 'DRS','EXTS','FLT', 'FRDS', 'FRGS', 'GDN','GLNS',
            'GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PARK','PKWY','PNE','PTS','PRTS','RAMP','RPD',
            'RDGS','RDS','RUE','SKWY','SPUR','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WALK','WAYS','WL','ST',
            'ALY','ANX','ARC','AVE','BYU','BCH ','BLF ','BTM','BLVD','BR','BRG','BRK','BG','BYP','CP','CYN','CPE','CSWY',
            'CTR','CIR','CLFS','CLB','CMN','COR','CORS','CRSE','CT','CTS','CV','CRK','CRES','XING','XRD','XRDS','CURV','DL',
            'DM','DV','DR','EST','ESTS','EXPY','EXT','FALL','FLS','FRY','FLD','FLDS','FLTS','FRD','FRST','FRG','FRK','FRKS',
            'FT','FWY','GDNS','GTWY','GLN','GRN','GRV','HBR','HVN','HTS','HWY','HOLW','INLT','IS','ISS','ISLE','JCT','KY',
            'KYS','KNL','KNLS','LK','LKS','LAND','LNDG','LN','LGT','LCK','LCKS','LDG','LOOP','MALL','MNR','MDW','MDWS',
            'MEWS','ML','MLS','MSN','MT','MTN','MTNS','NCK','ORCH','OVAL','PARK','PKWY','PASS','PSGE','PATH','PIKE','PNES',
            'PL','PLN','PLNS','PLZ','PT','PRT','PR','RADL','RNCH','RPDS','RST','RDG','RIV','RD','RTE','ROW','RUN','SHL',
            'SHLS','SHR','SPG','SPGS','SPUR','SQ','STA','STRA','STRM','STS','SMT','TER','TRCE','TRL','TRLR','TUNL','TPKE',
            'UN','VLY','VIA','VW','VLG','VL','VIS','WALK','WALL','WAY','WLS'
        };
        List<String> streetDirection = new List<String>{'N','E','W','S','NE','SE','NW','SW'};
        List<String> unitType = new List<String>{
            'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE',
            'SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'
        };
        
        List<Subscriptions__c> subList = new List<Subscriptions__c>();
        Integer j = 0;
        Integer k = 0;
        for(Integer i=0; i<streetType.Size(); i++) {
            
            if(Math.mod(i,8) == 0)
                j = 0;
                
            if(Math.mod(i,23) == 0)
                k = 0;                
            
            if(Math.mod(i,10) == 0) {
                try {
                    insert subList;
                }
                catch(Exception e) {}
                
                subList = new List<Subscriptions__c>();
            }
            
            Subscriptions__c s = new  Subscriptions__c();
            s.Name = 'Test Subscription';
            s.Contact__c = c.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '123112';
            s.Related_Location_Broker_Office__c = a.Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = streetType[i];
            s.QAS_Billing_Street_Type__c = streetType[i];
            s.QAS_Mailing_Street_Direction__c = streetDirection[j];
            s.QAS_Billing_Street_Direction__c= streetDirection[j];
            s.QAS_Mailing_Unit_Type__c = unitType[k];
            s.QAS_Billing_Unit_Type__c = unitType[k];
            s.County__c = 'Fairfax';
            s.Public_Email__c = 'test@test.com';
           
            subList.add(s);
            
            j++;
            k++;            
        }
        insert subList;
        }
        catch(Exception e) {
        
        }
    }
    
    private static Account createAccount() {
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
        insert testAccount ;    
        
        return testAccount ;
    }
    
    private static Contact createContact(String accountId){
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Middle_Name__c = 'test';
        contact.Nickname__c = 'test';
        contact.Suffix__c = 'JR.';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Ms.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact; 
        
        return contact; 
    }     
    
}