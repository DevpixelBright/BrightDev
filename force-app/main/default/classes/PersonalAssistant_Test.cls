@isTest(SeeAllData = False)
public class PersonalAssistant_Test {
    public Static Account account;
    public static testMethod void TestOne(){
        MRIS_Application__c App = new MRIS_Application__c();
        PersonalAssistant.getSubscriptionOptions();
        //PersonalAssistant.getAgentName('Test code','234533');
        PersonalAssistant.getBrokerOffice('Test Broker Office');
     //   PersonalAssistant.getSubId('Child Broker Codes Id', '123456');
        PersonalAssistant.getPicklistValues('First_Name__c', 'MRIS_Application__c');
        List<PersonalAssistant.wrapper> values = new List<PersonalAssistant.wrapper>();
        PersonalAssistant.submitApplication(App);
        PersonalAssistant.getSalutation('Salutation__c', 'MRIS_Application__c');
        PersonalAssistant.getConstants();
        
    }
    
    
    @testSetup
    Static void setup(){
        MRIS_Application__c App = new MRIS_Application__c();
        App.First_Name__c = 'Test First Name';
        App.Last_Name__c = 'Test Last Name';
        App.Primary_Phone__c = '098765455';
        App.Private_Email__c = 'Test@gmail.cm';
        App.City__c = 'Alexandria';
        App.County__c = 'Fairfax';
        App.State__c = 'VA';
        App.Zip__c = '20171';
        App.Private_Phone__c = '8765432109';
        App.Mobile_Phone__c = '7654321098';
        App.Public_Email__c = 'abc@gmail.com';
        Integer maxDays = 12;
        App.Status__c = 'New';
        App.Service_Jurisdiction__c = 'BRIGHT';
        insert App;
    } 
}