@IsTest(seealldata=true)
public class testMyAcctController {
public static Account getPAccount(){
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        CornerstoneMappings__c mc8 = new CornerstoneMappings__c();
        mc8.CornerstoneID__c = '98765432123456789098765432123462';
        mc8.Type__c = 'Agent/streetTypes';
        mc8.TypeName__c = 'BLUFFS ';
        insert(mc8);
        mc8 = new CornerstoneMappings__c();
        mc8.CornerstoneID__c = '98765432123456789098765432123433';
        mc8.Type__c = 'Agent/streetTypes';
        mc8.TypeName__c = 'BROOKS';
        insert(mc8);
        
        Account a12 = new Account();
        a12.name = 'ABC1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.company_type__c = 'Corporate Office';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';
        insert a12;  
        return a12;
}
public static Account getAccount(Account op){
     
        Account a = new Account();
        a.Name = 'CASE321';
        a.Account_Name__c = 'Testing Account';
        a.type = 'Residential';
        a.Company_Type__c = 'Broker Office';
        a.Shareholder_Board__c = 'None';
        a.Street_Number__c = '6824';
        a.Street_Name__c = 'Dean';
        a.Street_Type__c = 'DRIVE, DR';
        a.Zip__c = '22101';
        a.City__c = 'Herndon';
        a.State__c = 'VA';
        a.County__c = 'Fairfax';
        a.Country__c = 'UNITED STATES';
        a.Phone = '5559991234';
        a.Company_Type__c = 
        a.Status__c = 'In Progress';
        a.parentid = op.id;
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        
        insert a; 
        System.debug('Tester After a Insert ID: ---> ' + a.id);           
        
        return a;
}
public static Contact getContact(){
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Jimmy';
        c1.LastName = 'Parks';
        c1.Status__c = 'Active';
        //c1.Public_Email__c = 'jparks@rainmaker-llc.com';
        //c1.Email = 'jparks@rainmaker-llc.com';
        c1.Phone = '443-739-0628';
        c1.City__c = 'Balimore';
        c1.State__c = 'MD';
        c1.County__c = 'Baltimore City';
        c1.Zip__c = '21224';    
        c1.Professional_Designations__c='CPM';
        c1.Middle_Name__c ='Chip';
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        c1.Primary_Contact__c = true;
        
        insert c1;
        return c1;
}
public static List<Subscriptions__c> getSubscriptionList(Account a,Contact c1, Integer startme){
     
List<String> QAS_Mailing_Street_Direction =new List<String>{'N','E','S','W','NE','SE','NW','SW'} ;
List<String> QAS_Mailing_Street_Type =new List<String>{'BLFS','BRKS','BGS','CTRS','ACRES','ACRES','CMNS ','CVS','DRS','EXTS','FLT','FRDS','FRGS','GDN ','GLNS','GRNS','GRVS','HBRS','JCTS','LGTS','LF ','MNRS','MTWY','OPAS','PARK','PKWY','PNE','PTS ','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SPUR','SQS','TRWY','TRAK','TRFY','UPAS','UNS ','VLYS','VLGS','WALK','WAYS','WL','if(','ST','ALY','ANX','ARC','AVE','BYU','BCH','BLF','BTM','BLVD','BR','BRG','BRK','BG','BYP','CP','CYN','CPE','CSWY','CTR','CIR','ACRESS','CLB','CMN','COR','CORS','CRSE','CT','CTS','CV','CRK','CRES','XING','XRD','XRDS','CURV','DL','DM','DV','DR','EST','ESTS','EXPY','EXT','FALL','FLS','FRY','FLD','FLDS','FLTS','FRD','FRST','FRG','FRK','FRKS','FT','FWY','GDNS','GTWY','GLN','GRN','GRV','HBR','HVN','HTS','HWY','HOLW','INLT','IS','ISS','ISLE','JCT','KY','KYS','KNL','KNLS','LK','LKS','LAND','LNDG','LN','LGT','LCK','LCKS','LDG','LOOP','MALL','MNR','MDW','MDWS','MEWS','ML','MLS','MSN','MT','MTN','MTNS','NCK','ORCH','OVAL','PARK','PKWY','PASS','PSGE','PATH','PIKE','PNES','PL','PLN','PLNS','PLZ','PT','PRT','PR','RADL','RNCH','RPDS','RST','RDG','RIV','RD','RTE','ROW','RUN','SHL','SHLS','SHR','SPG','SPGS','SPUR','SQ','STA','STRA','STRM','STS','SMT','TER','TRCE','TRL','TRLR','TUNL','TPKE','UN','VLY','VIA','VW','VLG','VL','VIS','WALK','WALL','WAY','WLS','BLFS','BRKS','BGS','CTRS','ACRES','ACRES','CMNS','CVS','DRS','EXTS','FLT','FRDS','FRGS','GDN','GLNS','GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PNE','PTS','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WAYS','WL'};
List<String> QAS_Mailing_Unit_Type =new List<String>{'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE','SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'};
List<String> QAS_Billing_Street_Type  =new List<String>{'BLFS', 'BRKS','BGS', 'CTRS', 'ACRES','ACRES', 'CMNS','CVS', 'DRS', 'EXTS', 'FLT', 'FRDS', 'FRGS', 'GDN','GLNS', 'GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PARK','PKWY','PNE','PTS','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SPUR','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WALK','WAYS',NULL,'ST','ALY','ANX','ARC','AVE','BYU','BCH ','BLF ','BTM','BLVD','BR','BRG','BRK','BG','BYP','CP','CYN','CPE','CSWY','CTR','CIR','ACRESS','CLB','CMN','COR','CORS','CRSE','CT','CTS','CV','CRK','CRES','XING','XRD','XRDS','CURV','DL','DM','DV','DR','EST','ESTS','EXPY','EXT','FALL','FLS','FRY','FLD','FLDS','FLTS','FRD','FRST','FRG','FRK','FRKS','FT','FWY','GDNS','GTWY','GLN','GRN','GRV','HBR','HVN','HTS','HWY','HOLW','INLT','IS','ISS','ISLE','JCT','KY','KYS','KNL','KNLS','LK','LKS','LAND','LNDG','LN','LGT','LCK','LCKS','LDG','LOOP','MALL','MNR','MDW','MDWS','MEWS','ML','MLS','MSN','MT','MTN','MTNS','NCK','ORCH','OVAL','PARK','PKWY','PASS','PSGE','PATH','PIKE','PNES','PL','PLN','PLNS','PLZ','PT','PRT','PR','RADL','RNCH','RPDS','RST','RDG','RIV','RD','RTE','ROW','RUN','SHL','SHLS','SHR','SPG','SPGS','SPUR','SQ','STA','STRA','STRM','STS','SMT','TER','TRCE','TRL','TRLR','TUNL','TPKE','UN','VLY','VIA','VW','VLG','VL','VIS','WALK','WALL','WAY','WLS','BLFS','BRKS','BGS','CTRS','ACRES','ACRES','CMNS','CVS','DRS','EXTS','FLT','FRDS','FRGS','GDN','GLNS','GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PNE','PTS','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WAYS','WL'};
List<String> QAS_Billing_Street_Direction  =new List<String>{'N','E','S','W','NE','SE','NW','SW'};
List<String> QAS_Billing_Unit_Type = new List<String>{'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE','SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'};
        List<Subscriptions__c> allsubscription = new List<Subscriptions__c>();
        List<Subscription_Role__c> allsubscriptionrole = new List<Subscription_Role__c>();
        Subscriptions__c s1 = new Subscriptions__c();
            s1.AgentKey__c = '123456789';
            s1.Copy_Address_to_Billing__c = true;
            s1.Name = '1239090'+startme;
            s1.City__c = 'Baltimore';
            s1.County__c = 'Baltimore City';
            s1.Zip__c = '21224';
            s1.Contact__c = c1.Id;
            s1.Related_Location_Broker_Office__c = a.id;
            s1.status__c = 'In Progress';
            s1.Contact_type__c = 'Broker';
            s1.Subscription_Type__c = 'Realtor/Shareholder';
            s1.Addl_Display_Name__c = 'Test Display';
            s1.Box__c = 'PO Box';
            s1.Mobile_Phone__c  = '2404569098';
            s1.Public_Email__c = 'jpuckett@aol.com';
            s1.Fax__c = '2402439878';
            s1.Home_Fax__c = '3012409090';
            s1.Agent_Office_Phone__c = '3013529000';
            s1.Pager__c = '3012409898';
            //s1.Date_Reinstated__c = today;
            s1.State__c = 'MD';
            s1.Street_Type__c = 'ROAD, RD';
            s1.Street_Direction__c ='S, SOUTH';
            s1.Unit__c ='STE, SUITE';
            s1.VM_Ext__c = '123';
            s1.Voicemail__c = '3013524343';
            s1.Website__c= 'www.tester.com';
            s1.Zip_4__c = '3549';
            s1.Billing_Addl_Display_Name__c = 'PO';
            if(startme<QAS_Mailing_Street_Direction.size()-1)
            s1.QAS_Mailing_Street_Direction__c = QAS_Mailing_Street_Direction[startme];
            if(startme<QAS_Mailing_Street_Type.size()-1)
            s1.QAS_Mailing_Street_Type__c=QAS_Mailing_Street_Type[startme];
            if(startme<QAS_Mailing_Unit_Type.size()-1)
            s1.QAS_Mailing_Unit_Type__c=QAS_Mailing_Unit_Type[startme];
            if(startme<QAS_Billing_Street_Type.size()-1)
            s1.QAS_Billing_Street_Type__c = QAS_Billing_Street_Type[startme];
            
            if(startme<QAS_Billing_Street_Direction.size()-1)
            s1.QAS_Billing_Street_Direction__c=QAS_Billing_Street_Direction[startme];
            if(startme<QAS_Billing_Unit_Type.size()-1)
            s1.QAS_Billing_Unit_Type__c=QAS_Billing_Unit_Type[startme];
            allsubscription.add(s1);
            insert s1;

            s1.status__c = 'Active';
            update(s1);
            
            Subscription_Role__c sr3 = new Subscription_Role__c ();
        sr3.Role__c = 'Status Duplicate';
        sr3.Status__c = 'Active';
        sr3.sysPrRoleKey__c = '89752575777';
        sr3.Subscription__c = s1.id;
            insert sr3;
         
         Subscriptions__c s2 = new Subscriptions__c();
            s2.AgentKey__c = '123456789';
            s2.Copy_Address_to_Billing__c = true;
            s2.Name = '1239090'+startme+1;
            s2.City__c = 'Baltimore';
            s2.County__c = 'Baltimore City';
            s2.Zip__c = '21224';
            s2.Contact__c = c1.Id;
            s2.Related_Location_Broker_Office__c = a.id;
            s2.status__c = 'In Progress';
            s2.Contact_type__c = 'Broker';
            s2.Billing_Addl_Display_Name__c = 'PO';
            s2.Subscription_Type__c = 'Realtor/Shareholder';
            s2.Addl_Display_Name__c = 'Test Display';
            s2.Box__c = 'PO Box';
            s2.Mobile_Phone__c  = '2404569098';
            s2.Public_Email__c = 'jpuckett@aol.com';
            s2.Fax__c = '2402439878';
            s2.Home_Fax__c = '3012409090';
            s2.Agent_Office_Phone__c = '3013529000';
            s2.Pager__c = '3012409898';
            //s2.Date_Reinstated__c = today;
            s2.State__c = 'MD';
            s2.Street_Type__c = 'ROAD, RD';
            s2.Street_Direction__c ='S, SOUTH';
            s2.Unit__c ='STE, SUITE';
            s2.VM_Ext__c = '123';
            s2.Voicemail__c = '3013524343';
            s2.Website__c= 'www.tester.com';
            s2.Billing_Addl_Display_Name__c= 'PO';
            
            s2.Zip_4__c = '3549';
            if(startme+1<QAS_Mailing_Street_Direction.size()-1)
            s2.QAS_Mailing_Street_Direction__c = QAS_Mailing_Street_Direction[startme+1];
            if(startme+1<QAS_Mailing_Street_Type.size()-1)
            s2.QAS_Mailing_Street_Type__c=QAS_Mailing_Street_Type[startme+1];
            if(startme+1<QAS_Mailing_Unit_Type.size()-1)
            s2.QAS_Mailing_Unit_Type__c=QAS_Mailing_Unit_Type[startme+1];
            if(startme+1<QAS_Billing_Street_Type.size()-1)
            s2.QAS_Billing_Street_Type__c = QAS_Billing_Street_Type[startme+1];
            
            if(startme+1<QAS_Billing_Street_Direction.size()-1)
            s2.QAS_Billing_Street_Direction__c=QAS_Billing_Street_Direction[startme+1];
            if(startme+1<QAS_Billing_Unit_Type.size()-1)
            s2.QAS_Billing_Unit_Type__c=QAS_Billing_Unit_Type[startme+1];
            allsubscription.add(s2);
            insert s2;

            s2.status__c = 'Active';
            update(s2);

            Subscription_Role__c sr4 = new Subscription_Role__c ();
        sr4.Role__c = 'Status Duplicate';
        sr4.Status__c = 'Active';
        sr4.sysPrRoleKey__c = '89752575777';
        sr4.Subscription__c = s2.id;
         insert sr4;
             return allsubscription;
         
}
public static void executeme(Account a, Contact c1,Integer startme){
    
        PageReference testPage_acct = Page.myaccount;
        Test.setCurrentPage(testPage_acct);
        getSubscriptionList(a,c1,startme);
        String name1 = [Select name FROm Subscriptions__c limit 1].name;
        System.debug('>>>>>>>>>>'+name1);
        ApexPages.currentPage().getParameters().put('subscription', name1);       
        ApexPages.currentPage().getParameters().put('contact', c1.Id);           
        myAccController myAcct = new myAccController();   
        myAcct.getData();
        myAcct.save();
        myAcct.getSubs();
        myAcct.setSubs(getSubscriptionList(a,c1,startme));
        myAcct.getContact();
        myAcct.getContactID();
        myAcct.sub= myAcct.getSubs()[0];
        myAcct.reset();
        myAcct.getPrimarySub();
        myAcct.getAllSubs();
        

}/*
public static testmethod void testAcctsController() {       
        test.starttest();
        Account a12 =getPAccount();
        Account a = getAccount(a12);
        Contact c1 = getContact();
         executeme(a,c1,0);
        test.stopTest();
    }*/
 
public static testmethod void testAcctsController2() {       
        test.starttest();
        
        executionFlowUtility.accountUpdate=false;
        Account a12 =getPAccount();
        Account a = getAccount(a12);
        Contact c1 = getContact();
        PageReference testPage_acct = Page.myaccount;
        Test.setCurrentPage(testPage_acct);
        getSubscriptionList(a,c1,4);
        String name1 = [Select name FROm Subscriptions__c limit 1].name;
        System.debug('>>>>>>>>>>'+name1);
        ApexPages.currentPage().getParameters().put('subscription', name1);       
        ApexPages.currentPage().getParameters().put('contact', c1.Id);        

        myAccController myAcct = new myAccController();   
        myAcct.getData();
        for(Subscriptions__c tempkk: getSubscriptionListNoSave(a,c1,0)){
            myAcct.sub= tempkk;
            myAcct.save();
        }
        myAcct.save();
        myAcct.getSubs();
        //myAcct.setSubs(getSubscriptionList(a,c1,startme));
        myAcct.getContact();
        //myAcct.getContactID();
        //myAcct.sub= myAcct.getSubs()[0];
        myAcct.reset();
        
        myAcct.getPrimarySub();
        myAcct.getAllSubs();
        executionFlowUtility.accountUpdate=true;

        test.stopTest();
    }   

public static testmethod void testAcctsController3() {       
        test.starttest();
        Account a12 =getPAccount();
        Account a = getAccount(a12);
        Contact c1 = getContact();
        // executeme(a,c1,0);
        test.stopTest();
    } 
public static List<Subscriptions__c> getSubscriptionListNoSave(Account a,Contact c1, Integer startme){
     
List<String> QAS_Mailing_Street_Direction =new List<String>{'N','E','S','W','NE','SE','NW','SW'} ;
List<String> QAS_Mailing_Street_Type =new List<String>{'BLFS','BRKS','BGS','CTRS','ACRES','ACRES','CMNS ','CVS','DRS','EXTS','FLT','FRDS','FRGS','GDN ','GLNS','GRNS','GRVS','HBRS','JCTS','LGTS','LF ','MNRS','MTWY','OPAS','PARK','PKWY','PNE','PTS ','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SPUR','SQS','TRWY','TRAK','TRFY','UPAS','UNS ','VLYS','VLGS','WALK','WAYS','WL','if(','ST','ALY','ANX','ARC','AVE','BYU','BCH','BLF','BTM','BLVD','BR','BRG','BRK','BG','BYP','CP','CYN','CPE','CSWY','CTR','CIR','ACRESS','CLB','CMN','COR','CORS','CRSE','CT','CTS','CV','CRK','CRES','XING','XRD','XRDS','CURV','DL','DM','DV','DR','EST','ESTS','EXPY','EXT','FALL','FLS','FRY','FLD','FLDS','FLTS','FRD','FRST','FRG','FRK','FRKS','FT','FWY','GDNS','GTWY','GLN','GRN','GRV','HBR','HVN','HTS','HWY','HOLW','INLT','IS','ISS','ISLE','JCT','KY','KYS','KNL','KNLS','LK','LKS','LAND','LNDG','LN','LGT','LCK','LCKS','LDG','LOOP','MALL','MNR','MDW','MDWS','MEWS','ML','MLS','MSN','MT','MTN','MTNS','NCK','ORCH','OVAL','PARK','PKWY','PASS','PSGE','PATH','PIKE','PNES','PL','PLN','PLNS','PLZ','PT','PRT','PR','RADL','RNCH','RPDS','RST','RDG','RIV','RD','RTE','ROW','RUN','SHL','SHLS','SHR','SPG','SPGS','SPUR','SQ','STA','STRA','STRM','STS','SMT','TER','TRCE','TRL','TRLR','TUNL','TPKE','UN','VLY','VIA','VW','VLG','VL','VIS','WALK','WALL','WAY','WLS','BLFS','BRKS','BGS','CTRS','ACRES','ACRES','CMNS','CVS','DRS','EXTS','FLT','FRDS','FRGS','GDN','GLNS','GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PNE','PTS','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WAYS','WL'};
List<String> QAS_Mailing_Unit_Type =new List<String>{'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE','SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'};
List<String> QAS_Billing_Street_Type  =new List<String>{'BLFS', 'BRKS','BGS', 'CTRS', 'ACRES','ACRES', 'CMNS','CVS', 'DRS', 'EXTS', 'FLT', 'FRDS', 'FRGS', 'GDN','GLNS', 'GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PARK','PKWY','PNE','PTS','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SPUR','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WALK','WAYS',NULL,'ST','ALY','ANX','ARC','AVE','BYU','BCH ','BLF ','BTM','BLVD','BR','BRG','BRK','BG','BYP','CP','CYN','CPE','CSWY','CTR','CIR','ACRESS','CLB','CMN','COR','CORS','CRSE','CT','CTS','CV','CRK','CRES','XING','XRD','XRDS','CURV','DL','DM','DV','DR','EST','ESTS','EXPY','EXT','FALL','FLS','FRY','FLD','FLDS','FLTS','FRD','FRST','FRG','FRK','FRKS','FT','FWY','GDNS','GTWY','GLN','GRN','GRV','HBR','HVN','HTS','HWY','HOLW','INLT','IS','ISS','ISLE','JCT','KY','KYS','KNL','KNLS','LK','LKS','LAND','LNDG','LN','LGT','LCK','LCKS','LDG','LOOP','MALL','MNR','MDW','MDWS','MEWS','ML','MLS','MSN','MT','MTN','MTNS','NCK','ORCH','OVAL','PARK','PKWY','PASS','PSGE','PATH','PIKE','PNES','PL','PLN','PLNS','PLZ','PT','PRT','PR','RADL','RNCH','RPDS','RST','RDG','RIV','RD','RTE','ROW','RUN','SHL','SHLS','SHR','SPG','SPGS','SPUR','SQ','STA','STRA','STRM','STS','SMT','TER','TRCE','TRL','TRLR','TUNL','TPKE','UN','VLY','VIA','VW','VLG','VL','VIS','WALK','WALL','WAY','WLS','BLFS','BRKS','BGS','CTRS','ACRES','ACRES','CMNS','CVS','DRS','EXTS','FLT','FRDS','FRGS','GDN','GLNS','GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PNE','PTS','PRTS','RAMP','RPD','RDGS','RDS','RUE','SKWY','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WAYS','WL'};
List<String> QAS_Billing_Street_Direction  =new List<String>{'N','E','S','W','NE','SE','NW','SW'};
List<String> QAS_Billing_Unit_Type = new List<String>{'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE','SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'};
        List<Subscriptions__c> allsubscription = new List<Subscriptions__c>();
        List<Subscription_Role__c> allsubscriptionrole = new List<Subscription_Role__c>();
        startme = 0;
        for(String temqq:QAS_Mailing_Street_Type){
        Subscriptions__c s1 = new Subscriptions__c();
            s1.AgentKey__c = '123456789';
            s1.Copy_Address_to_Billing__c = true;
            s1.Name = '1239090'+startme;
            s1.City__c = 'Baltimore';
            s1.County__c = 'Baltimore City';
            s1.Zip__c = '21224';
            s1.Contact__c = c1.Id;
            s1.Related_Location_Broker_Office__c = a.id;
            s1.status__c = 'Active';
            s1.Contact_type__c = 'Broker';
            s1.Subscription_Type__c = 'Realtor/Shareholder';
            s1.Addl_Display_Name__c = 'Test Display';
            s1.Box__c = 'PO Box';
            s1.Mobile_Phone__c  = '2404569098';
            s1.Public_Email__c = 'jpuckett@aol.com';
            s1.Fax__c = '2402439878';
            s1.Home_Fax__c = '3012409090';
            s1.Agent_Office_Phone__c = '3013529000';
            s1.Pager__c = '3012409898';
            //s1.Date_Reinstated__c = today;
            s1.State__c = 'MD';
            s1.Street_Type__c = 'ROAD, RD';
            s1.Street_Direction__c ='S, SOUTH';
            s1.Unit__c ='STE, SUITE';
            s1.VM_Ext__c = '123';
            s1.Voicemail__c = '3013524343';
            s1.Website__c= 'www.tester.com';
            s1.Zip_4__c = '3549';
            s1.Billing_Addl_Display_Name__c = 'PO';
            s1.Addl_Display_Name__c = 'PO';
            
            if(startme<QAS_Mailing_Street_Direction.size()-1)
            s1.QAS_Mailing_Street_Direction__c = QAS_Mailing_Street_Direction[startme];
            if(startme<QAS_Mailing_Street_Type.size()-1)
            s1.QAS_Mailing_Street_Type__c=QAS_Mailing_Street_Type[startme];
            if(startme<QAS_Mailing_Unit_Type.size()-1)
            s1.QAS_Mailing_Unit_Type__c=QAS_Mailing_Unit_Type[startme];
            if(startme<QAS_Billing_Street_Type.size()-1)
            s1.QAS_Billing_Street_Type__c = QAS_Billing_Street_Type[startme];
            
            if(startme<QAS_Billing_Street_Direction.size()-1)
            s1.QAS_Billing_Street_Direction__c=QAS_Billing_Street_Direction[startme];
            if(startme<QAS_Billing_Unit_Type.size()-1)
            s1.QAS_Billing_Unit_Type__c=QAS_Billing_Unit_Type[startme];
            allsubscription.add(s1);
             startme++;
        }
             return allsubscription;
         
}      
}