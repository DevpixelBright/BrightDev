@istest
 public class BT_ClassHistory_test{
    
     @isTest
     static void classHistoryAuthenticatedUserRegistered() {
       generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         BT_ClassHistory clsHistory = new BT_ClassHistory();     
       }  
     }
     
     @isTest
     static void classHistoryAuthenticatedUserAttended() {
       generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       reg.status__c = 'Attended';
       update reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         BT_ClassHistory clsHistory = new BT_ClassHistory();     
       }    
     }
     
     @isTest
     static void classHistoryAuthenticatedUserCanceled() {
       generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       reg.Status__c = 'Canceled';
       update reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         BT_ClassHistory clsHistory = new BT_ClassHistory();     
       }    
     }
     
     @isTest
     static void classHistoryAuthenticatedUserNoSeats() {
       generateData();
       Account acc = BT_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  BT_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  BT_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  BT_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  BT_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = BT_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = BT_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       List<BT_Registration__c> registrations = new List<BT_Registration__c>();
       for(Integer i = 0; i < 20; i++) {
           BT_Registration__c reg = BT_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
           registrations.add(reg);
        }
       insert registrations;  
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         BT_ClassHistory clsHistory = new BT_ClassHistory();     
       }  
     }
     private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
 }