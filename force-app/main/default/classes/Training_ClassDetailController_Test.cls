@isTest
public class Training_ClassDetailController_Test {
    
    @isTest
    static void classDetailConstructor() {
         generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, 'www.youtube.com');
       insert cls;
       cls.IsRegistrationRequired__c = true;
       update cls; 
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub; 
       BT_Registration__c reg = Training_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       //User u = BT_Utility_Test.createUser(sub.Id);
       System.runAs(u) {
          ApexPages.currentPage().getHeaders().put('referer', '/learnbrightmls/s/classdetail?classId='+cls.Id);
          Training_ClassDetailController btclass = new Training_ClassDetailController();
          btclass.registerClass();
          btclass.cancelClass(); 
       }
    }
    
    @isTest
    static void classDetailAttended() {
         generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, 'www.youtube.com');
       insert cls;
       cls.IsRegistrationRequired__c = false;
       update cls; 
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub; 
       BT_Registration__c reg = Training_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       reg.Status__c = 'Attended'; 
       update reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
          ApexPages.currentPage().getHeaders().put('referer', '/learnbrightmls/s/classdetail?classId='+cls.Id);
          Training_ClassDetailController btclass = new Training_ClassDetailController();
          btclass.registerClass();
          btclass.cancelClass(); 
       }
    }
    
    @isTest
    static void classDetailCanceled() {
         generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, 'www.youtube.com');
       insert cls;
       cls.IsRegistrationRequired__c = true;
       update cls; 
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub; 
       BT_Registration__c reg = Training_Utility_Test.createRegistration(con.Id, cls.Id, sub.Id);
       insert reg;
       reg.Status__c = 'Canceled'; 
       update reg;
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(u) {
          ApexPages.currentPage().getHeaders().put('referer', '/learnbrightmls/s/classdetail?classId='+cls.Id);
          Training_ClassDetailController btclass = new Training_ClassDetailController();
          btclass.registerClass();
          btclass.cancelClass(); 
       }
    }
    
    @isTest
    static void classDetailUnAuthenticatedUser() {
         generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, 'www.youtube.com');
       insert cls;
       cls.IsRegistrationRequired__c = true;
       update cls; 
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       
       System.runAs(new User(Id=UserInfo.getUserId())) {
          ApexPages.currentPage().getHeaders().put('referer', '/learnbrightmls/s/classdetail?classId='+cls.Id);
          Training_ClassDetailController btclass = new Training_ClassDetailController();
          btclass.registerClass();
          btclass.cancelClass(); 
       }
    }
    
    @isTest
    static void classDetailNoRegistration() {
         generateData();
       Account acc = Training_Utility_Test.createAccount('MLS', 'XYZ124');
       insert acc;
       Contact con =  Training_Utility_Test.createContact(acc.Id);
       insert con;
       BT_Course__c course =  Training_Utility_Test.createCourse('Live', true, 'Training');
       insert course;
       BT_Venue__c venue =  Training_Utility_Test.createVenue('Hickory', null, 'USA', 'NC', 'Brickell Court', '979', '28601', null);
       insert venue;
       BT_Instructor__c instructor = Training_Utility_Test.createInstructor('Live', con.Id);
       insert instructor;
       BT_Class__c cls = Training_Utility_Test.createClass(venue.Id, course.Id, instructor.Id, 'Live', true, false, 'www.youtube.com');
       insert cls;
       cls.IsRegistrationRequired__c = true;
       update cls; 
       Subscriptions__c sub =  Training_Utility_Test.createSubscription(acc.Id, con.Id);
       insert sub;
       sub.Status__c = 'Active';
       sub.Primary__c = true;
       update sub; 
              
       User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
       System.runAs(new User(Id=UserInfo.getUserId())) {
          ApexPages.currentPage().getHeaders().put('referer', '/learnbrightmls/s/classdetail?classId='+cls.Id);
          Training_ClassDetailController btclass = new Training_ClassDetailController();
          btclass.registerClass();
          btclass.cancelClass(); 
       }
    } 
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    } 
}