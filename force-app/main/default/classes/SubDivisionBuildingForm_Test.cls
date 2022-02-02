@isTest(seeAllData=false)
public class SubDivisionBuildingForm_Test {
    
    @isTest static void getDetailsTest(){
        generateData();
        Account mainAccount = createAccount('Residential','XYZ189'); 
        insert mainAccount;
        
        Contact contact = createContact(mainAccount.Id);
        insert contact;
        
        Subscriptions__c subscription = createSubscription(mainAccount.Id, contact.Id);
        //insert subscription;    
        
        Case oCase = new Case();
        oCase.Description = 'Test';
        oCase.CreatedDate = System.now();
        insert oCase;
        
        
        Subscriptions__c[] subs = [SELECT id, Name FROM Subscriptions__c where Contact__c = :contact.Id]; 
        SubdivisionBuilding_Form.getStateValues();
        SubdivisionBuilding_Form sub = new SubdivisionBuilding_Form();
        
        SubDivisionFormWrapper wrap = SubdivisionBuilding_Form.initMethod();
        wrap.Subdivisionname = 'sub1';
        wrap.County = 'county';
        SubdivisionBuilding_Form.fetchSubscription(subs[0].Name);
        SubdivisionBuilding_Form.getCaseCreatedDate(oCase.id);
        
        
        Account a1 = TestClassUtility.createAccount('Residential','XYZ124', 'MRIS');
        String fileString = 'QGZvbnQtZmFjZSB7CiAgICBmb250LWZhbWlseTogJ0xhdG8nOwogICAgc3JjOiB1cmwoJ0xhdG8tQm9sZC5lb3QnKTsKICAgIHNyYzogdXJsKCdMYXRvLUJvbGQuZW90PyNpZWZpeCcpIGZvcm1hdCgnZW1iZWRkZWQtb3BlbnR5cGUnKSwKICAgICAgICB1cmwoJ0xhdG8tQm9sZC53b2ZmMicpIGZvcm1hdCgnd29mZjInKSwKICAgICAgICB1cmwoJ0xhdG8tQm9sZC53b2ZmJykgZm9ybWF0KCd3b2ZmJyksCiAgICAgICAgdXJsKCdMYXRvLUJvbGQudHRmJykgZm9ybWF0KCd0cnVldHlwZScpLAogICAgICAgIHVybCgnTGF0by1Cb2xkLnN2ZyNMYXRvLUJvbGQnKSBmb3JtYXQoJ3N2ZycpOwogICAgZm9udC13ZWlnaHQ6IGJvbGQ7CiAgICBmb250LXN0eWxlOiBub3JtYWw7Cn0KCg==';
        SubdivisionBuilding_Form.attachFile(a1.Id, null, 'test.css', 'text/css', fileString);
        SubdivisionBuilding_Form.saveSubdivisionBuildingForm(subs[0].Name, wrap, 'SubDivision', 'SubDivision');
                
    }
    
    private static Account createAccount(String type,String name){
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        //insert account; 
        
        return account;
    }
    
    private static Contact createContact(String accountId){
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contactr';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        //insert contact; 
        
        return contact; 
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId){
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        insert subscription; 
        
        return subscription;
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
    }
    
    
}