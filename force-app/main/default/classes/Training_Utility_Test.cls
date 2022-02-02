@isTest
public class Training_Utility_Test {
    public static Account createAccount(String type, String name) {
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
        account.Status__c = 'Active';
        account.Primary_Service_Jurisdiction__c = 'BRIGHT';
        
        return account;
    }
    
    public static Contact createContact(String accountId) {
        Contact contact = new Contact();
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
        
        return contact;
    }
    
     public static Subscriptions__c createSubscription(String accountId, String contactId) {
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@gmail.com';
        subscription.Private_Email__c = 'test@gmail.com';
        subscription.Service_Jurisdiction__c = 'BRIGHT'; 
               
        return subscription;
    }
    
    public static BT_Course__c createCourse(String deliveryMethod, Boolean isActive, String title) {
        BT_Course__c course = new BT_Course__c();
        course.Duration__c = 60;
        course.Description__c = 'new course';
        course.IsActive__c = true;
        course.AvailableDeliveryMethods__c = deliveryMethod;
        course.IsActive__c = isActive;
        course.Title__c = title;
        return course;
    }
    
    public static BT_Venue__c createVenue(String city, String county, String country, String state, String street, String streetNumber, String zcode,
                                         String z4code) {
        BT_Venue__c venue = new BT_Venue__c();
        venue.Capacity__c = 20;
        venue.City__c = city;
        venue.County__c = county;
        venue.Country__c = country;
        venue.Description__c = 'venue';
        venue.State__c = state;
        venue.Street__c = street;
        venue.Street_Number__c = streetNumber;
        venue.ZipCode__c = zcode;
        venue.Zip_4__c = z4code;
        return venue;
    }
    
    public static BT_Instructor__c createInstructor(String deliveryMethod, Id contactId) {
        BT_Instructor__c instructor = new BT_Instructor__c();
        instructor.ApprovedDeliveryMethods__c = deliveryMethod;
        instructor.Contact__c = contactId;
        return instructor;
    }
    
    public static BT_Class__c createClass(Id venueId, Id courseId, Id instructorId, String deliveryMethod, 
                                          Boolean isActive, Boolean isDeleted, String pdRecording) {
        BT_Class__c cls = new BT_Class__c();
        cls.Title__c = 'Training';
        cls.Venue__c = venueId;
        cls.Course__c = courseId;
        cls.Instructor__c = instructorId;
        cls.Capacity__c = 20;
        cls.DeliveryMethod__c = deliveryMethod;
        cls.Duration__c = 60;
        DateTime dt = System.now().addDays(1);
        cls.StartTime__c = dt.addDays(5);
        cls.RegistrationDeadline__c = dt;
        cls.IsActive__c = isActive;        
        cls.Private__c = false;
        cls.PostDeliveryRecording__c = pdRecording;                                      
        return cls;
    }
    
    public static BT_Registration__c createRegistration(Id contactId, Id classId, Id subId) {
        BT_Registration__c reg = new BT_Registration__c();
        reg.Contact__c = contactId;
        reg.Schedule__c = classId;
        reg.Subscription__c = subId;
        reg.Status__c = 'Registered';
        reg.Email__c = 'example@gmail.com';
        return reg;
    }
    
    public static User createUser(Id subscriptionId) {
        
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileId, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stauser@testorg.com');
        
        return u;
    /*
        Subscriptions__c sSubscription = [SELECT Id, 
                                          Name, 
                                          Public_Email__c, 
                                          SF_Subscription_ID__c, 
                                          AgentKey__c, 
                                          Contact__c, 
                                          Contact__r.FirstName,
                                          Contact__r.LastName 
                                          FROM Subscriptions__c 
                                          WHERE  id = :subscriptionId];         
        
        User communityUser = new User();
        communityUser.username = sSubscription.AgentKey__c + 'test@test.com';
        communityUser.email = sSubscription.Public_Email__c;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = sSubscription.Contact__r.FirstName;
        communityUser.FirstName = sSubscription.Contact__r.LastName;
        communityUser.FederationIdentifier = sSubscription.Name;
        communityUser.Alias = (sSubscription.Name.length() > 7) ? sSubscription.Name.substring(0, 7) : sSubscription.Name; 
        communityUser.ContactId = sSubscription.Contact__c;
        communityUser.isActive = true;
        communityUser.CommunityNickname = sSubscription.Name;
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'MRIS Customer Community Login'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
        
        return communityUser;   */
    }
}