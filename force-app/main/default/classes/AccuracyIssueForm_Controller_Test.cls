@istest(seealldata = false)
public class AccuracyIssueForm_Controller_Test {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private Static List<String> topicList {get; set;}
    
    private static testMethod void doTestOne() {
       // try{
            topicList = new  List<String>  {'Incorrect tax identification or legal information',
                'Listing not entered into system within 3 business days excluding weekends and holidays',
                'Duplicate Listing'
                };  
                    generateCornerstone();             
            createAccount('Residential','XYU12');                   
            createContact(account.Id);                          
            createSubscription(account.Id, contact.Id);
            
            
            subscription.Status__c = 'Active';
            update subscription;
            PageReference pageRef = Page.AccuracyIssueForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mls', 'Testvendor1');  
            ApexPages.currentPage().getParameters().put('address', 'Testvendor2');  
            ApexPages.currentPage().getParameters().put('from', '('+subscription.Name+')');  
            ApexPages.currentPage().getParameters().put('topic', 'test'); 
            ApexPages.currentPage().getParameters().put('description', 'test'); 
            
            
            AccuracyIssuePdf_Controller obj1 = new AccuracyIssuePdf_Controller();
           
            AccuracyIssueForm_Controller obj = new AccuracyIssueForm_Controller();
            obj.validateSubscription();
            obj.msg = 'tes';
            //obj = new AccuracyIssueForm_Controller(controller);
            for (String t : topicList){ 
                obj.topic =t;
                obj.description ='Test';
                AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            }
            
            String caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            ApexPages.currentPage().getParameters().put('caseId', caseId);
            AccuracyIssuePdf_Controller obj2 = new AccuracyIssuePdf_Controller();
            String attachId = AccuracyIssueForm_Controller.attachFile(caseId, '', 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            attachId = AccuracyIssueForm_Controller.attachFile(caseId, attachId, 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            
                 
            
       // }catch(Exception e){}
    }
    
    
    private static testMethod void doTestTwo() {
       // try{
            
            topicList = new  List<String>  {'Incorrect Contingency','Incorrect data information (i.e. picklist item)',
                'Incorrect settlement information','Other'
                }; 
                    generateCornerstone();             
            createAccount('Residential','XYZ12');                   
            createContact(account.Id);                          
            createSubscription(account.Id, contact.Id);
            
            subscription.Status__c = 'Active';
            update subscription;
            PageReference pageRef = Page.AccuracyIssueForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mls', 'Testvendor1');  
            ApexPages.currentPage().getParameters().put('address', 'Testvendor2');  
            ApexPages.currentPage().getParameters().put('from', '('+subscription.Name+')');  
            
            AccuracyIssueForm_Controller obj = new AccuracyIssueForm_Controller();
            //obj = new AccuracyIssueForm_Controller(controller);
            for (String t : topicList){ 
                obj.topic =t;
                obj.description ='Test';
                AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            }
            
            String caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            String attachId = AccuracyIssueForm_Controller.attachFile(caseId, '', 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            attachId = AccuracyIssueForm_Controller.attachFile(caseId, attachId, 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');           
        //}catch(Exception e){}
    }
    
    
    private static testMethod void doTestThree() {
      //  try{
            topicList = new  List<String>  {'Photo Violation','Property advertised prior to entry into Bright ','Price',
                'Remarks Violation','Unauthorized use of Bright system (Pease submit name and circumstance)'
                };  
                    generateCornerstone();             
            createAccount('Residential','XYZ12');                   
            createContact(account.Id);                          
            createSubscription(account.Id, contact.Id);
            
            subscription.Status__c = 'Active';
            update subscription;
            PageReference pageRef = Page.AccuracyIssueForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mls', 'Testvendor1');  
            ApexPages.currentPage().getParameters().put('address', 'Testvendor2');  
            ApexPages.currentPage().getParameters().put('from', '('+subscription.Name+')');  
            
            AccuracyIssueForm_Controller obj = new AccuracyIssueForm_Controller();
            //obj = new AccuracyIssueForm_Controller(controller);
            for (String t : topicList){ 
                obj.topic =t;
                obj.description ='Test';
                AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            }
            
            String caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            
            AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
        Test.startTest();
            String attachId = AccuracyIssueForm_Controller.attachFile(caseId, '', 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            attachId = AccuracyIssueForm_Controller.attachFile(caseId, attachId, 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
          Test.stopTest();  
            
       // }catch(Exception e){}
    }
  private static testMethod void doTestFour() {
       // try{
            topicList = new  List<String>  {'Property advertised prior to entry into Bright'
                };  
                    generateCornerstone();             
            createAccount('Residential','XYZ12');                   
            createContact(account.Id);                          
            createSubscription(account.Id, contact.Id);
            
            subscription.Status__c = 'Active';
            update subscription;
            PageReference pageRef = Page.AccuracyIssueForm;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mls', 'Testvendor1');  
            ApexPages.currentPage().getParameters().put('address', 'Testvendor2');  
            ApexPages.currentPage().getParameters().put('from', '('+subscription.Name+')');  
            
            AccuracyIssueForm_Controller obj = new AccuracyIssueForm_Controller();

                obj.topic = '';
                obj.description ='Test';
                AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            
            String caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            caseId = AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');

            AccuracyIssueForm_Controller.remoteCreateCase('23689', 'Huntingtown', 'test('+subscription.Name+')', obj.topic, 'descr');
            String attachId = AccuracyIssueForm_Controller.attachFile(caseId, '', 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            attachId = AccuracyIssueForm_Controller.attachFile(caseId, attachId, 'JPEG', 'werfsdfdsfd', 'Off MLS Listings');
            
            
       // }catch(Exception e){}
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
    
    private static void createContact(String accountId){
        contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;  
    }
    
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Personal Assistant';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        //subscription.Primary__c = true;
        subscription.Public_Email__c = 'test@test.com';
        insert subscription; 
    }
    
    private static void generateCornerstone(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }        
    
}