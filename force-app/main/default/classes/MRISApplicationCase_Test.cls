@istest(seealldata=true)
private class MRISApplicationCase_Test {
    
    private Static Account account;
    
    private static testMethod void doTestOne(){
    
        generateData();             
        createAccount('Residential','XYZ123'); 
        
        RecordType rt = [select Id, DeveloperName from RecordType where DeveloperName = 'MRIS_Reinstatement_Application'];            
     
        MRIS_Application__c app = new MRIS_Application__c();
        app.Company_Code__c = account.Id;
        app.RecordTypeId = rt.Id;
        app.Existing_Subscriber_ID__c = '12345';
        insert(app);
        
        MRISApplicationCase.Create(app);     
    }
    
    private static testMethod void doTestTwo(){
    
        generateData();             
        createAccount('Residential','XYZ123'); 
        
        RecordType rt = [select Id, DeveloperName from RecordType where DeveloperName = 'MRIS_Reinstatement_Application'];            
     
        MRIS_Application__c app = new MRIS_Application__c();
        app.Company_Code__c = account.Id;
        app.Existing_Subscriber_ID__c = '12345';
        insert(app);
        
        MRISApplicationCase.Create(app);     
    }    
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    } 
    
    private static void createAccount(String type,String name){
        account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        insert account; 
    }       

}