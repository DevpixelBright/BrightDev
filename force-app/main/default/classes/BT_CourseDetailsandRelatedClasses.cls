public class BT_CourseDetailsandRelatedClasses {
    public BT_Course__c course {set; get;}
    public String courseClassesjson {set; get;}
    public string subscriptionId {get; set;}
    public BT_CourseDetailsandRelatedClasses() {
        String courseId = ApexPages.currentPage().getParameters().get('courseId');
        System.debug(courseId);
        User u = loggedInUser();
        if(u != null)
            subscriptionId = u.FederationIdentifier;
        
        List<Id> classIds = new List<Id>();
        for(BT_Class__c btclass : [SELECT Id FROM BT_Class__c WHERE Course__c = :courseId]) {
            classIds.add(btclass.Id);
        }
        Map<Id, String> regMap = new Map<Id, String>();
        for(BT_Registration__c reg : [SELECT Schedule__c, Subscription__r.Name FROM BT_Registration__c WHERE Schedule__c IN :classIds]) {
            regMap.put(reg.Schedule__c, reg.Subscription__r.Name);
        }
        
        List<BT_Course__c> courses = [SELECT Id, AppropriateFor__c, AvailableDeliveryMethods__c, Description__c, Image__c,
                                      Duration__c, IsActive__c, Title__c,
                                      (SELECT Id, Name, Capacity__c, Course__c, DeliveryMethod__c, Duration__c, SeatsRemaining__c, StartTime__c, Title__c, IsRegistrationRequired__c, IsActive__c, 
                                       PostDeliveryRecording__c, AdditionalDescription__c, Venue__r.State__c, Venue__r.City__c, Venue__r.Street__c FROM Classes__r) 
                                      FROM BT_Course__c WHERE Id = :courseId];
        
        if(courses.size() == 1) {
            //courseClassesdetails = new CourseClasses();
            List<ClassesRegistration> classregs = new List<ClassesRegistration>();
            course = courses[0];
            System.debug('== '+courses[0].Classes__r);
            for(BT_Class__c bc : courses[0].Classes__r) {
                ClassesRegistration cr = new ClassesRegistration();
                cr.btclass = bc;
                if(bc.StartTime__c != null) {
                    string startDateTimeString = bc.StartTime__c.format('MM-dd-yyyy hh:mm a');
                    cr.classDate = startDateTimeString.split(' ')[0];
                    
                    string endDateTimeString = '0';
                    cr.durationinhours = '0 minutes';
                    if(bc.Duration__c != null){
                        endDateTimeString = bc.StartTime__c.addMinutes(integer.valueOf(bc.Duration__c)).format('MM/dd/yyyy hh:mm a');
                        
                        cr.classStartTime = startDateTimeString.split(' ')[1]+' '+startDateTimeString.split(' ')[2];
                        cr.classEndTime = endDateTimeString.split(' ')[1]+' '+endDateTimeString.split(' ')[2];
                        Decimal duration = (bc.Duration__c)/60;
                        Integer hour = duration.intValue();
                        Decimal minutes = ((duration - duration.intValue()).setscale(1)) * 60;
                        if(hour > 0) {
                            String h = '';                    
                            if(hour == 1) 
                                h = ' hour ';
                            else if(hour > 1)
                                h = ' hours ';
                            
                            if(minutes > 0) {
                                String m = '';
                                if(minutes == 1)
                                   m = ' minute';
                                else if(minutes > 1)
                                    m = ' minutes';
                                
                                   cr.durationinhours = hour + h + Integer.valueOf(minutes) + m;
                        	}
                            else
                                cr.durationinhours = hour + h;
                        }
                        else { 
                             String m = '';
                                if(minutes == 1)
                                   m = ' minute';
                                else if(minutes > 1)
                                    m = ' minutes';
                            cr.durationinhours = bc.Duration__c + m;
                        }
                    }
                }
                
                if(bc.PostDeliveryRecording__c != null)
	            	cr.watchItAgain = true;
	            else
	            	cr.watchItAgain = false;
                
                if(u != null && u.FederationIdentifier != null && regMap.get(bc.Id) == u.FederationIdentifier)
                    cr.isRegistered = true;
                else
                    cr.isRegistered = false;
                
                classregs.add(cr);
            }
            System.debug('=== course '+course);
            
            courseClassesjson = JSON.serialize(classregs);
            System.debug('== '+courseClassesjson);
        }
    } 
    
    public void register() {
        User loggedInUser = loggedInUser();
        if(loggedInUser != null) {
            BT_Registration__c reg = new BT_Registration__c();
            String classId = ApexPages.currentPage().getParameters().get('classId');
            List<Subscriptions__c> subs = [SELECT Id, Contact__c, Private_Email__c FROM Subscriptions__c WHERE Name = :loggedInUser.FederationIdentifier];
            if(subs.size() == 1) 
                reg.Contact__c = subs[0].Contact__c;
            reg.Schedule__c = classId;
            reg.Subscription__c = subs[0].Id;
            reg.RegisteredDate__c = System.now();
            reg.Status__c = 'Registered';
            reg.Email__c = subs[0].Private_Email__c;
            try {	
                insert reg;
            }
            catch(exception ex) {
                System.debug('error '+ ex.getMessage());
            }
        }
    }
    
    @RemoteAction
    public static boolean registration(String subId, String classId) {
        if(subId != null && classId != null){
            try{
                
                BT_Registration__c newRegistration = new BT_Registration__c();
                //newRegistration.Contact__c = contactId;
                newRegistration.Subscription__c = subId;
                newRegistration.Schedule__c = classId;
                insert newRegistration;
                return true;
                
            }
            catch(exception ex){
                system.debug('---exception--'+ex.getLinenumber()+'---'+ex.getMessage());
                return false;
            }
        }
        else
            return false;
    }
    
    // withdraw registration
    @RemoteAction
    public static void cancelRegistration(string RegistrationId){
        try{
            BT_Registration__c regObj = new BT_Registration__c();
            regObj.Id = RegistrationId;
            regObj.Status__c = 'Canceled';
            update regObj;
        }
        catch(Exception e){
            System.debug('---exception--'+e.getLinenumber()+'---'+e.getMessage());
        }
    }
    
    
    private User loggedInUser() {
        List<User> users = [SELECT FederationIdentifier From User WHERE Id = :UserInfo.getUserId()];
        system.debug('---users-->'+users);
        if(users.size() == 1)
            return users[0];
        else 
            return null;
    }
    
    //wrapper class
    public class ClassesRegistration {
        public BT_Class__c btclass {set; get;}
        public Boolean isRegistered {set; get;}
        public String classDate {set; get;}
        public string classStartTime {get; set;}
        public string classEndTime {get; set;}
        public String durationinhours {set; get;}
        //public String classStartTime {set; get;}
        public boolean watchItAgain{get; set;}
    }
    
    /*  public class CourseClasses {
public BT_Course__c course {set; get;}
public List<ClassesRegistration> classregs {set; get;} 

public CourseClasses() {
classregs = new List<ClassesRegistration>();
}
} */
}