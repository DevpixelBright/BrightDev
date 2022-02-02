/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 * 
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AllUtility_UnitTest {

      //mock records
      public static Account mockAccountRecord(){       
           CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
           cau.addAddrs();    
           Account a = new Account();
           a.name = 'ADA1244';
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
       
       public static Account mockAccountRecord_new(){       
           CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
           cau.addAddrs();    
           Account a = new Account();
           a.name = 'ADP1294';
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
       public static Account mockAccountRecord_new1(){       
           CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
           cau.addAddrs();    
           Account a = new Account();
           a.name = 'QDP1294';
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
       
       static Subscriptions__c mockSubscriptions() {
            Account acc = mockAccountRecord();
            Contact con = mockContactRecords(acc.Id);
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
            testSubscription.Related_Location_Broker_Office__c = acc.Id;
            insert testSubscription;
            return testSubscription;
        }
       
       static testMethod void myUnitTest() {
            Subscriptions__c sub = mockSubscriptions();
            Account acc = mockAccountRecord_new();
            Contact con = mockContactRecords(acc.Id);
            System.assertNotEquals(sub.Related_Location_Broker_Office__c,null);

            //method 1&2 
            CreateCaseOnFailed.createCase(mockAccountRecord_new1());
            CreateCaseOnFailed.createCaseForSub(sub);

            //method 3
            Relationship__c rr2 = new Relationship__c();
            rr2.Relationship_Type__c = 'Broker Of Record';
            rr2.Subscription__c =   sub.id;
            rr2.Related_Account__c = acc.id;
            rr2.MDS_Status__c = 'Success';
            rr2.Broker_Office__c = acc.id;
            rr2.Contact__c = sub.Contact__c;
            insert rr2;

            //method 4          
            CreateCaseOnFailed.createCaseForRel(rr2);   
            Account a = new Account();
            a.name = 'ADA0234';
            a.type = 'Association';
            a.Account_Name__c = 'Test Account';
            a.City__c = 'Herndon';
            a.Zip__c = '20171';
            a.QAS_Mailing_County__c = 'Fairfax';
            a.County__c = 'Fairfax';
            a.Street_Type__c = '';
            a.Billing_Street_Type__c = 'BLFS';
            a.QAS_Mailing_Street_Type__c ='test';
            insert a;

            Related_Association__c r1 = new Related_Association__c();
            r1.Broker_Code__c = acc.id;
            r1.Primary__c = true;
            r1.Association__c = a.id;   
            r1.Status__c = 'Active';                        
            insert r1;              

            test.startTest();

            CreateCaseOnFailed.createCaseForSubAssc(r1);
            //Case second for exception  
            CreateCaseOnFailed.createCaseForSubAssc(new Related_Association__c());
            //Case second for sub null        
            //Related_Association__c r2 = new Related_Association__c();
            //r2.Broker_Code__c = acc.id;
            //r2.Primary__c = true;
            //r2.Association__c = a.id;   
            //r2.Status__c = 'Active';    
            //r2.Subscription__c = sub.id;                    
            //insert r2;
            //CreateCaseOnFailed.createCaseForSubAssc(r2);

            //List<Case> lc = [select id, IsEscalated from Case];
            
            //for(Case c1:lc) {
            //   c1.IsEscalated = true;
            //}
            //update lc;

            CreateCaseOnFailed.createCase(a);
//            CreateCaseOnFailed.createCaseForSub(sub);
            CreateCaseOnFailed.createCaseForRel(rr2);

            test.stopTest();
       }
}