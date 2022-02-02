public class SMS_CreatePersonAccount {

    public Static void createPersonAccount(List<string> contactIds) {
        try {
            List<Contact> contacts = [SELECT Id, Name, FirstName, LastName, Phone, QAS_Mailing_Street_Type__c, Zip__c, 
                                             Zip_4__c, City__c, State__c, QAS_Mailing_Country__c, QAS_Mailing_County__c 
                                      FROM   Contact
                                      WHERE  id = :contactIds];
                                      
            System.Debug('***** contacts - ' + contacts);
                              
            List<Account> personAccounts = new List<Account>();
            List<RecordType> personRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Zuora Integration Account'];
            
            for(Contact c : contacts) {
    
                Account personAccount = new Account();
                
                personAccount.RecordTypeId = personRecordType[0].id;
                personAccount.Contact__c = c.id;
                personAccount.Account_Name__c = c.LastName + ' ' + c.FirstName;
                personAccount.LastName = c.LastName;
                personAccount.FirstName = c.FirstName;
                personAccount.Type = 'Billing Account';
                personAccount.Status__c = 'Active';
                personAccount.Phone = c.Phone;
                personAccount.QAS_Mailing_Street_Type__c = c.QAS_Mailing_Street_Type__c;
                personAccount.Zip__c = c.Zip__c;
                personAccount.Zip_4__c = c.Zip_4__c ;
                personAccount.City__c = c.City__c;
                personAccount.State__c = c.State__c;
                personAccount.QAS_Mailing_Country__c = c.QAS_Mailing_Country__c ;
                personAccount.QAS_Mailing_County__c = c.QAS_Mailing_County__c ;
                
                personAccounts.add(personAccount); 
          
            }
            System.Debug('***** Person accounts - ' + personAccounts);
            insert personAccounts;
            SMS_ZuoraHistory.createSuccess('SMS_CreatePersonAccount',null); 
        }
        catch(Exception e) {
            SMS_ZuoraHistory.createError(e,'SMS_CreatePersonAccount',null);
        }                                       
    }
}