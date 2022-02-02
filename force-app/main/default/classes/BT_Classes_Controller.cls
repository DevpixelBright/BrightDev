public class BT_Classes_Controller {
    
    public Boolean isAuthenticatedUser;
    public String subscriptionId { get; set; }
    public List<ClassDetail> classDetails { get; set; }
    public String classDetailsWrapJson { get; set; }
    
    public String selectedDeliveryMethod { get; set; }
    public List<SelectOption> getDeliveryMethods() {
        
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult desField = BT_Course__c.AvailableDeliveryMethods__c.getDescribe();
        system.debug('---F--->'+desField.getPicklistValues());
        List<Schema.PicklistEntry> schemaPicklist = desField.getPicklistValues();
        options.add(new SelectOption('','Delivery Method'));
        
        for(Schema.PicklistEntry pickvalue : schemaPicklist){
            options.add(new SelectOption(pickvalue.getValue(), pickvalue.getValue()));
        }
        return options;
    }
    
    public String selectedAppropriate{ get; set; }
    public List<selectOption> getAppropriateFor(){
        
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult desField = BT_Course__c.AppropriateFor__c.getDescribe();
        system.debug('---F--->'+desField.getPicklistValues());
        List<Schema.PicklistEntry> schemaPicklist = desField.getPicklistValues();
        options.add(new SelectOption('','Appropriate for'));
        
        for(Schema.PicklistEntry pickvalue : schemaPicklist){
            options.add(new SelectOption(pickvalue.getValue(), pickvalue.getValue()));
        }
        return options;
    }
    
    public String selectedFullClassFilter{ get; set; }
    public List<selectOption> getIncludeFullClasses(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Full Classes'));
        options.add(new SelectOption('Hide Full Classes','Hide Full Classes'));
        options.add(new SelectOption('Show Full Classes', 'Show Full Classes'));
        
        return options;
    }
    
    public BT_Classes_Controller(){
        
        isAuthenticatedUser = true;
        checkUserLogin();
        
        List<BT_Class__c> allClasses = new List<BT_Class__c>();
        allClasses = [SELECT   Id, Name, Capacity__c, DeliveryMethod__c, Duration__c, SeatsRemaining__c, StartTime__c, Title__c, Notes__c, AdditionalDescription__c,                             
                               Course__c, Course__r.Title__c, Course__r.Duration__c, Course__r.Image__c, Course__r.Video__c, Course__r.AppropriateFor__c, 
                               Instructor__c, Instructor__r.Contact__r.Name,
                               Venue__c, Venue__r.Country__c, Venue__r.State__c, Venue__r.ZipCode__c, Venue__r.Street__c, Venue__r.Venue_Site__c, Venue__r.City__c
                      FROM     BT_Class__c
                      ORDER BY CreatedDate asc];
        
        
        if(!allClasses.isEmpty()){
            classDetails = new List<ClassDetail>();
            
            for(BT_Class__c cl : allClasses){
                ClassDetail wrapobj = new ClassDetail();
                wrapobj.btClass = cl;
                
                if(cl.StartTime__c != null){
                    
                    String startDateTimeString = cl.StartTime__c.format('yyyy-MM-dd hh:mm a');
                    String endDateTimeString = cl.StartTime__c.addMinutes(integer.valueOf(cl.Duration__c)).format('yyyy-MM-dd hh:mm a');
                    wrapobj.classDate = startDateTimeString.split(' ')[0];
                    wrapobj.classStartTime = startDateTimeString.split(' ')[1] + ' ' + startDateTimeString.split(' ')[2];
                    wrapobj.classEndTime =  endDateTimeString.split(' ')[1] + ' ' + endDateTimeString.split(' ')[2];
                    
                }
                
                if(cl.SeatsRemaining__c == 0)
                    wrapobj.isAvailable = false;               
                
                classDetails.add(wrapobj);
            }
            
            classDetailsWrapJson = JSON.serialize(classDetails);
            
            system.debug('----classDetails--->'+classDetails.size()+'-->'+classDetails);
        }
    }    
    
    public void checkUserLogin(){
        List<User> correctUser = [SELECT FederationIdentifier FROM User 
                                  Where Id = :UserInfo.getUserId()];
        
        if(correctUser.size() == 0) 
            return;
        
        String primaryId = correctUser[0].FederationIdentifier;
        
        if(String.IsBlank(primaryId)) 
            return;
        
        subscriptionId = primaryId;
        
        List<Contact> contact = [SELECT Id, Name FROM Contact 
                                 Where Id IN ( Select Contact__c FROM Subscriptions__c Where Name = :primaryId)];
        
        if (contact.size() == 0){
            isAuthenticatedUser = true;
            return;
        }
        else
            isAuthenticatedUser = false;
    }
    
    public pagereference registerClass(string classId, String subId, String contactId){
        try{
            if(isAuthenticatedUser){
                pagereference ref = new pageReference('');    // give redirect URL 
                return ref;
            }
            else if(classId != null && subId != null && contactId != null){
                BT_Registration__c newRegistration = new BT_Registration__c();
                newRegistration.Contact__c = contactId;
                newRegistration.Subscription__c = subId;
                newRegistration.Schedule__c = classId;
                insert newRegistration;
                return null;
            }
            else{
                return null;
            }
        }
        catch(exception ex){
            system.debug('---exception--'+ex.getLinenumber()+'---'+ex.getMessage());
            return null;
        }
    }
    
    // withdraw registration
    public void cancelClass(string RegistrationId){
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
    
    public class CourseDetail{
        public BT_Course__c course { get; set; }
        public List<ClassDetail> classDetails { get; set; }
    }
    
    class ClassDetail{
        public BT_Class__c btClass {get; set;}        
        public String classDate { get; set; }
        public String classStartTime { get; set; }
        public String classEndTime { get; set; }
        public Boolean isAvailable { get; set; }       
    }
}