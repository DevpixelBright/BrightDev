@isTest
public class Communities_OfficeAccuracyTest 
{
    private static string qcFineNegative = 'CRDATA5';
    @testSetup
    public static void createTestData()
    {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Account account = new Account();
        account.Name = 'TEST567';
        account.Type = 'Residential';
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Status__c = 'Active';
        insert account; 
        
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.Id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;
        
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.Name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Private_Email__c = 'test1@test.com';
        insert subscription; 
        
        Relationship__c r1 = createRelationship(account.Id, contact.Id,subscription.Id, 'Broker Of Record'); 
        //Relationship__c r2 = createRelationship(a1.Id, c1.Id,s1.Id, 'Authorized Signer');
        
        string mlsNo = '0001122';
        createCompliance_Appeal_Config();
        Compliance_Violation__c ComplianceViolation = createComplianceViolation(subscription.Id, mlsNo, subscription.Name);
        system.debug('---ComplianceViolation--->'+ComplianceViolation);
        
        list<Compliance_Fine__c> comFineList = new list<Compliance_Fine__c>();
        
        Compliance_Fine__c objFine1 = createCompliancefine(ComplianceViolation.Id, mlsNo, subscription.Id, subscription.Name+'-0', qcFineNegative);
        insert objFine1;
        
        Compliance_Fine__c objFine2 = createCompliancefine(ComplianceViolation.Id, mlsNo, subscription.Id, subscription.Name+'-1', qcFineNegative);
        comFineList.add(objFine2);
        
        Compliance_Fine__c objFine3 = createCompliancefine(ComplianceViolation.Id, mlsNo, subscription.Id, subscription.Name+'-2'+'check-test', null);
        objFine3.Violation__c = null;
        objFine3.Notification_Type__c = '';
        objFine3.Last_Date_to_Appeal__c = null;
        objFine3.status__c = null;
        comFineList.add(objFine3);
        
        insert comFineList;
    }
    
    @isTest
    public static void testCommunities_OfficeAccuracy()
    {
        list<Subscriptions__c> subList = [SELECT Id,Name,Status__c,Status_Change_Reason__c FROM Subscriptions__c];
        list<string> subIdList = new list<string>();
        for(Subscriptions__c sub : subList){
            subIdList.add(sub.Id);
        }
        
        
        Communities_OfficeAccuracy.getDetails(subList[0].Name);
    }
    
    @isTest
    public static void testCommunities_OfficeAccuracy_Print()
    {
        list<Subscriptions__c> subList = [SELECT Id,Name,Status__c,Status_Change_Reason__c FROM Subscriptions__c];
        list<string> subIdList = new list<string>();
        for(Subscriptions__c sub : subList){
            subIdList.add(sub.Id);
        }
        
        ApexPages.currentPage().getParameters().put('id', subList[0].Name);
        Communities_OfficeAccuracy_Print ctrl = new Communities_OfficeAccuracy_Print();
    }

    private Static Relationship__c createRelationship(String accountId, String contactId, String subscriptionId, String relationType) {
        Relationship__c r = new Relationship__c();
        r.Broker_Office__c = accountId;
        r.Related_Account__c = accountId;
        r.Contact__c = contactId;
        r.Subscription__c = subscriptionId;
        r.Relationship_Type__c = relationType;
        r.Status__c = 'Active';
        insert r; 
        
        return r;
    }
    private Static Compliance_Violation__c createComplianceViolation(String subscriptionId, string mslNumber, string name){
        Compliance_Violation__c ComplianceViolation = new Compliance_Violation__c();
        ComplianceViolation.Name = name;
        ComplianceViolation.Subscription_ID__c = subscriptionId;
        ComplianceViolation.Subscription__c = subscriptionId;
        ComplianceViolation.MLS_Number__c = mslNumber;
        ComplianceViolation.Date_of_Fine__c = system.today();
        insert ComplianceViolation;
        return ComplianceViolation; 
    }
    
    private Static Compliance_Fine__c createCompliancefine(string complianceViolationId, string mlsNumber, string subId, string name, string qcFineCode){
        Compliance_Fine__c Compliancefine = new Compliance_Fine__c();
        Compliancefine.Compliance_Violation__c = complianceViolationId;
        Compliancefine.Name = name;
        Compliancefine.Date_of_Fine__c = date.today();
        Compliancefine.QC_Fine_Code__c = qcFineCode; //'CRDATA75';
        
        Compliancefine.Last_Date_to_Appeal__c = date.today() +20;
        Compliancefine.Notification_Type__c = 'Test Voilation';
        Compliancefine.Status__c = 'Pending';
        Compliancefine.Violation__c = 'Delinquent Violation';
        Compliancefine.Subscription_ID__c = subId;
        Compliancefine.Subscription__c = subId;
        
        //insert Compliancefine;
        return Compliancefine;  
    }
    private static void createCompliance_Appeal_Config(){
        Compliance_Appeal_Config__c objcomAppConf = new Compliance_Appeal_Config__c();
        objcomAppConf.Appeal_Timer__c = 20;
        insert objcomAppConf;
    }
}