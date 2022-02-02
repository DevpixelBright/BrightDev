public class BT_BaseController{
    
    public String subscriptionId { get; set; }
    public String contactId { get; set; }
    public Boolean isAuthenticatedUser { get; set; }
    public Subscriptions__c subscription { get; set; }
    
    public BT_BaseController(){
        List<User> correctUser = [SELECT FederationIdentifier 
                                  FROM   User 
                                  WHERE  Id = :UserInfo.getUserId()
                                 ];
        isAuthenticatedUser = false;
        if(correctUser.size() == 0) 
            return ;
        
        subscriptionId = correctUser[0].FederationIdentifier;
        System.debug('subscriptionId '+subscriptionId);
        if(String.IsBlank(subscriptionId)) 
            return;
        
        List<Contact> contacts = [SELECT Id, Name FROM Contact 
                                  WHERE  Id IN ( SELECT Contact__c FROM Subscriptions__c WHERE Name = :subscriptionId AND Status__c = 'Active')
                                 ];
        System.debug('contacts.size() '+contacts.size());
        if (contacts.size() == 0)            
            return;
        else{
            contactId = contacts[0].Id;
            isAuthenticatedUser = true;
            subscription = [SELECT Id, Name, Private_Email__c 
                            FROM   Subscriptions__c 
                            WHERE  Name = :subscriptionId
                           ];
        }
        System.debug('isAuthenticatedUser '+isAuthenticatedUser);
    }    
    
    public String registerClass(String classId){
        System.debug('== classId '+classId + ' === '+ isAuthenticatedUser);
        try{
            if(!isAuthenticatedUser){
                String loginUrl = ''; 
                return loginUrl;
            }
            else if(classId != null){
                List<BT_Registration__c> registrations = [SELECT Id, Schedule__c, Status__c, Subscription__c 
                                                          FROM   BT_Registration__c 
                                                          WHERE  Schedule__c = :classId
                                                          AND    Subscription__r.Name = :subscriptionId
                                                         ];
                                                  
                BT_Registration__c newRegistration = new BT_Registration__c();
                if(registrations.size() > 0)
                    newRegistration.id = registrations[0].Id;
                else{        
                    newRegistration.Contact__c = contactId;                    
                    newRegistration.Schedule__c = classId;
                }
                newRegistration.Subscription__c = subscription.Id;
                newRegistration.RegisteredDate__c = System.now();
                newRegistration.Email__c = subscription.Private_Email__c;
                newRegistration.Status__c = 'Registered';
                System.debug('new reg === '+newRegistration);
                upsert newRegistration;
                return 'Success';
            }
            else{
                return 'Class Id should not be null';
            }
        }
        catch(exception ex){
            system.debug('---exception--'+ex.getLinenumber()+'---'+ex.getMessage());
            return ex.getMessage();
        }
    }
    
    public String cancelClass(String classId){
        try{
            system.debug('---cancel Base--'+classId);
            if(classId != null){
                List<BT_Registration__c> registrations = [SELECT Id, Schedule__c, Status__c 
                                                          FROM   BT_Registration__c 
                                                          WHERE  Schedule__c = :classId
                                                          AND    Subscription__r.Name = :subscriptionId
                                                         ];
                
                system.debug('---registration--'+registrations);
                BT_Registration__c registration = new BT_Registration__c();
                registration.Id = registrations[0].Id; 
                registration.Status__c = 'Canceled';
                registration.CanceledDate__c = system.now();
                update registration;
                return 'Success';
            }
            else{
                return 'Class Id should not be null';
            }
        }
        catch(Exception e){
            System.debug('---exception--'+e.getLinenumber()+'---'+e.getMessage());
            return e.getMessage();
        }
    }
    
    public class ClassDetail{
        public BT_Class__c btClass {get; set;}        
        public String classDate { get; set; }
        public String classStartTime { get; set; }
        public String classEndTime { get; set; }
        public Boolean isAvailable { get; set; }
        public Boolean isRegistration { get; set; }
        public Boolean isCancelation { get; set; }
        public Boolean isAddtoClasses { get; set; }
        public Boolean isMapNeeded { get; set; }
        public Boolean isWatchitAgain {get; set;}
        public String durationinhours { get; set; }
        
        
        public ClassDetail(BT_Class__c btCls, String registrationStatus){
            btClass = new BT_Class__c(); 
            btClass = btcls;           
            
            string OrganizationTimeZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
            String startDateTimeString = btCls.StartTime__c.format('MM-dd-yyyy hh:mm a', OrganizationTimeZone);
            String endDateTimeString = btCls.StartTime__c.addMinutes(integer.valueOf(btCls.Duration__c)).format('MM-dd-yyyy hh:mm a', OrganizationTimeZone);
            classDate = startDateTimeString.split(' ')[0];
            classStartTime = startDateTimeString.split(' ')[1] + ' ' + startDateTimeString.split(' ')[2];
            classEndTime =  endDateTimeString.split(' ')[1] + ' ' + endDateTimeString.split(' ')[2];
            
            Integer hours = Integer.valueOf(math.floor(btCls.Duration__c/60));
            Integer minutes = Integer.valueOf(math.mod(integer.valueOf(btCls.Duration__c),60));
            if(hours > 0) {
                String h = '';                    
                if(hours == 1) 
                    h = ' hour ';
                else if(hours > 1)
                    h = ' hours ';
                
                if(minutes > 0)
                    durationinhours = hours + h + minutes + ' minutes';
                else
                    durationinhours = hours + h;
            }
            else 
                durationinhours = minutes + ' minutes';
            
            system.debug('---registrationStatus-->'+registrationStatus);
            if(btCls.SeatsRemaining__c > 0 && btCls.RegistrationDeadline__c > system.now()){
                if(btcls.IsRegistrationRequired__c){
                    if(String.isBlank(registrationStatus) || registrationStatus == 'Canceled' || registrationStatus == 'Canceled By Staff'){
                        isRegistration = true;    
                    }                        
                }
                else if(registrationStatus != 'Registered') {
                    isAddtoClasses = true;   
                }               
            }
            
            if(registrationStatus == 'Registered')
                isCancelation = true;
            
            system.debug('--btClass.StartTime__c--->'+btClass.StartTime__c);
            if(btClass.SeatsRemaining__c > 0 && btClass.IsActive__c && btCls.RegistrationDeadline__c > system.now())
                isAvailable = true;
            
            if(btClass.PostDeliveryRecording__c != null)
                isWatchitAgain = true;
                       
            system.debug('---btCls-->'+btCls);
        }       
    }
}