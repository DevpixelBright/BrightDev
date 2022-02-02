@isTest
public class Training_MyClassesController_Test {
    
    @isTest
     static void classHistoryAuthenticatedUserRegistered() {
       generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       BT_Registration__c reg = Training_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         Training_MyClassesController clsHistory = new Training_MyClassesController();     
       }  
     }
     
     @isTest
     static void classHistoryAuthenticatedUserAttended() {
       generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       BT_Registration__c reg = Training_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       reg.status__c = 'Attended';
       update reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         Training_MyClassesController clsHistory = new Training_MyClassesController();     
       }    
     }
     
     @isTest
     static void classHistoryAuthenticatedUserCanceled() {
       generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       BT_Registration__c reg = Training_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       reg.Status__c = 'Canceled';
       update reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         Training_MyClassesController clsHistory = new Training_MyClassesController();     
       }    
     }
     
     @isTest
     static void classHistoryAuthenticatedUserNoSeats() {
       generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, null);
       insert cls;
       List<BT_Registration__c> registrations = new List<BT_Registration__c>();
       for(Integer i = 0; i < 20; i++) {
           BT_Registration__c reg = Training_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
           registrations.add(reg);
        }
       insert registrations;  
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
         Training_MyClassesController clsHistory = new Training_MyClassesController();     
       }  
     }
     private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
}