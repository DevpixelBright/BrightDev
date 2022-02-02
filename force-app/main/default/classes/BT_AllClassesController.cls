public class BT_AllClassesController {
    
    public String subscriptionId {set; get;}
    public Boolean isAuthenticatedUser {get; set;}
    BT_BaseController baseController;
    public string classDetailsWrapJson {get; set;}
    
    public string selectedDeliveryMethod {get; set;}
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
    
    public string selectedAppropriate{get; set;}
    public list<selectOption> getAppropriateFor(){
        
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
    
    public string selectedFullClassFilter{get; set;}
    public list<selectOption> getIncludeFullClasses(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Include Full Classes'));
        options.add(new SelectOption('Hide Full Classes','Hide Full Classes'));
        options.add(new SelectOption('Show Full Classes', 'Show Full Classes'));
        
        return options;
    }
    
    public BT_AllClassesController(){
        
        isAuthenticatedUser = false;
        baseController = new BT_BaseController();
        isAuthenticatedUser = baseController.isAuthenticatedUser;        
        DateTime dt = System.now();
        list<BT_Class__c> allClasses = new list<BT_Class__c>();
        allClasses = [SELECT   Id, Name, Capacity__c, Course__c, DeliveryMethod__c, Duration__c, SeatsRemaining__c, StartTime__c, Title__c, Notes__c, AdditionalDescription__c, RegistrationDeadline__c, 
                    IsRegistrationRequired__c, IsActive__c, PostDeliveryRecording__c, Course__r.Title__c, Course__r.Duration__c, Course__r.Image__c, Course__r.Video__c, Course__r.AppropriateFor__c, 
                    Instructor__c, Instructor__r.Contact__r.Name,
                    Venue__c, Venue__r.Country__c, Venue__r.State__c, Venue__r.Street__c, Venue__r.ZipCode__c, Venue__r.Venue_Site__c, Venue__r.City__c
                    From BT_Class__c WHERE StartTime__c >= :dt
                    ORDER BY StartTime__c ASC
                     ];
        
        List<BT_BaseController.ClassDetail> classDetails = new List<BT_BaseController.ClassDetail>();
        
        for(BT_Class__c btCls : allClasses){            
            BT_BaseController.ClassDetail classDetail = new BT_BaseController.ClassDetail(btcls, null);
            classDetails.add(classDetail);
        }
          
        classDetailsWrapJson = JSON.serialize(classDetails);        
    }  
}