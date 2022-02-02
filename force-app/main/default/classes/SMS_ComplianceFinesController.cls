public class SMS_ComplianceFinesController {
    public string complianceId {get; set;}
    public list<Compliance_Fine__c> complianceFines {get; set;}
    public SMS_ComplianceFinesController(){
    	try{
    		//complianceId = Apexpages.currentPage().getParameters().get('Id');
    		complianceFines = new list<Compliance_Fine__c>();
    		complianceFines = [Select Id, Agent_Name__c, Date_of_Fine__c, Fine_Amount__c, Last_Date_to_Appeal__c, 
    							Compliance_Violation__r.Name, Compliance_Violation__r.MLS_Number__c 
    							From Compliance_Fine__c 
    							Where Compliance_Violation__c =: complianceId];
    	}
    	catch(exception ex){
    		system.debug('--exception-->'+ex.getLineNumber()+'---'+ex.getMessage());
    	}
    }
}