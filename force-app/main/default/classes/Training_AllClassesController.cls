/**
* Filename: Training_AllClassesController .cls
* Author  : BLT India Team 
* 
* History
* -----------------------------------------------------------------------------
* 
*/
public class Training_AllClassesController {
    
    public String subscriptionId { set; get; }
    public Boolean isAuthenticatedUser { get; set; }
    public string classDetailsWrapJson { get; set; }      
    public string deliveryMethodJson { get; set; }
    public string appropriateForJson { get; set; }
    public Training_BaseController baseController;
    public string selectedFullClassFilter{get; set;}
    
    public List<string> getDeliveryMethodsList() {       
        Schema.DescribeFieldResult desField = BT_Class__c.DeliveryMethod__c.getDescribe();
        List<Schema.PicklistEntry> schemaPicklist = desField.getPicklistValues();
        list<string> lstTemp = new list<string>();
        for(Schema.PicklistEntry pickvalue : schemaPicklist){
            lstTemp.add(pickvalue.getValue());
        }
        deliveryMethodJson = JSON.serialize(lstTemp);
        
        return lstTemp;
    }   
    
    public list<string> getappropriateForList() {
        Schema.DescribeFieldResult desField = BT_Course__c.AppropriateFor__c.getDescribe();
        system.debug('---F--->'+desField.getPicklistValues());
        List<Schema.PicklistEntry> schemaPicklist = desField.getPicklistValues();
        list<string> lstTemp = new list<string>();
        for(Schema.PicklistEntry pickvalue : schemaPicklist){
            lstTemp.add(pickvalue.getValue());
        }
        appropriateForJson = JSON.serialize(lstTemp);
        return lstTemp;  
    }
    
    public list<selectOption> getIncludeFullClasses(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Include Full Classes'));
        options.add(new SelectOption('Hide Full Classes','Hide Full Classes'));
        options.add(new SelectOption('Show Full Classes', 'Show Full Classes'));
        
        return options;
    }
    
    public Training_AllClassesController(){       
        isAuthenticatedUser = false;
        baseController = new Training_BaseController();
        isAuthenticatedUser = baseController.isAuthenticatedUser;               
    }
    
    /* Visual force remote method to fetch all classes information on page load */
    @RemoteAction
    public Static List<Training_BaseController.ClassDetail> getAllClasses() {
        DateTime dt = System.now();
        List<BT_Class__c> allClasses = new List<BT_Class__c>();
        allClasses = [SELECT   Id, Name, Capacity__c, Course__c, DeliveryMethod__c, Duration__c, HasNoShowFee__c ,ExternalRegistationSite__c, SeatsRemaining__c, StartTime__c, Title__c, Notes__c, AdditionalDescription__c, RegistrationDeadline__c, 
                               IsRegistrationRequired__c, IsActive__c, PostDeliveryRecording__c, Course__r.Title__c, Course__r.Duration__c, Course__r.Image__c, Course__r.AppropriateFor__c, 
                               Venue__c, Venue__r.Name, Venue__r.Street_Number__c, Venue__r.Street_Type__c, Venue__r.Street__c, Venue__r.City__c, Venue__r.State__c, Venue__r.Country__c, Venue__r.ZipCode__c, Venue__r.Zip_4__c
                      FROM     BT_Class__c 
                      WHERE    StartTime__c >= :dt AND IsActive__c = true
                      ORDER BY StartTime__c ASC];
        
        List<Training_BaseController.ClassDetail> classDetails = new List<Training_BaseController.ClassDetail>();
        
        for(BT_Class__c btCls : allClasses){            
            Training_BaseController.ClassDetail classDetail = new Training_BaseController.ClassDetail(btcls, null);
            classDetails.add(classDetail);
        }
        system.debug('---classDetails---'+classDetails);
        return classDetails;        
    }
}