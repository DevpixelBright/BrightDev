@isTest
public class Communities_AddressValidation_Test {
    private Static Smarty_Streets__c setting;
    
    public static testMethod void testone(){   
  
       createSetting('Auth ID', 'Sample-AuthId');
       createSetting('Auth Token', 'Sample-key');
       createSetting('URL', 'https://us-street.api.smartystreets.com/street-address');
       Communities_AddressValidation_Controller.smartyValidation('test');
        
    }
    
    private Static void createSetting(String name, String value){
        setting = new Smarty_Streets__c();
        setting.Name = name; 
        setting.Value__c = value; 
        insert setting;       
    }   
}