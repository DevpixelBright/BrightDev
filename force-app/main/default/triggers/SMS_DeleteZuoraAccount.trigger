trigger SMS_DeleteZuoraAccount on Contact (before delete) {
    List<String> contactIds = new List<String>();
    
    for (Contact c : trigger.old)
        contactIds.add(c.id) ;       
    
    List<String> crmIds = new List<String>();
    List<Account> accounts = [select Id, Name from account where contact__r.id in :contactIds];
    
    for (Account a :accounts) 
         crmIds.add(a.id);
    
    if(crmIds.size() > 0)
        SMS_DeleteZuoraAccount.deleteZuoraAccount(crmIds);
}