public class VendorCommunity_MyAccount_Controller {
    
    public String accountId { get; set; }    
    public Account objAccount { get; set; }
    public Boolean isEdit { get; set; }
    public String displayName { get; set; }
    public Contact contactDetails{get; set;}
    public Boolean haveContacts {get; set;}
    
    public  VendorCommunity_MyAccount_Controller() {  
        
        accountId = System.currentPageReference().getParameters().get('id');      
        system.debug('****** accountId********'+accountId);
        haveContacts = false;
        if(String.isBlank(accountId))
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Account id is null'));
        
        else
            contactDetails();
        
        isEdit = false;
    }
    
    public list<Account> lstAccounts;
    public void contactDetails() {
    	
		objAccount = new Account();
		lstAccounts = [ SELECT Name, id,
									( Select id, Name, Phone, Email, FirstName, LastName, Title, Middle_Name__c, Suffix__c, Nickname__c, Contact_Type__c
									From Contacts Where Contact_Type__c != null) 
									FROM    Account
									WHERE   Name =: accountId
                       				And Type = 'RETS'
									];
		
		if(lstAccounts.size() < 1 ){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Account does not exist'));
		}
        else{
        	objAccount = lstAccounts[0];
        	displayName = objAccount.Name;
            system.debug('---objAccount.contacts--->'+objAccount.Contacts);
            if(objAccount.Contacts == null || objAccount.Contacts.size() == 0)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Primary, Administrative, Billing or Technical Contacts exist'));
            
            else{
                contactDetails = objAccount.Contacts[0];
                
                mapContacts = new map<string, contact>();
                for(contact c : lstAccounts[0].contacts){
                    mapContacts.put(c.Contact_Type__c, c);
                    haveContacts = true;
                }
            }
        }
        system.debug('---mapContacts--->'+mapContacts);
        
		
		Schema.DescribeFieldResult fieldResult = Contact.Contact_Type__c.getDescribe();
		List<Schema.PicklistEntry> pickVals = fieldResult.getPicklistValues();
		conactTypes = new list<string>();
		
		for( Schema.PicklistEntry p : pickVals) {
			conactTypes.add(p.getValue());
		}
		/*
		conactTypes.add('Primary Contact');
		conactTypes.add('Administrative Contact');
		conactTypes.add('Billing Contact');
		*/
    }
    public map<string, contact> mapContacts {get; set;}
    public list<string> conactTypes {get; set;}
    public void reset() {
        contactDetails();
        isEdit = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The Page has been Reset'));
    }    
    
    public void cancel(){
        contactDetails();
        isEdit = false;
    }
    
    public void edit(){
        isEdit = true;
    }
    
    public PageReference save() {
        Boolean error = false;
        String commonError = 'The required field is missing:  ';

        if(!error) {
            error = false;
            try {
            	list<contact> lstcontacts = new list<contact>();
            	
            	// check whether contact values are changed, if so then add them to update list
            	/*for(Contact con : lstAccounts[0].contacts ){
            		
            	}*/
            	
                for(contact con :mapContacts.values()){
                	lstcontacts.add(con);
                }
                update lstcontacts;
                
                if(!error){
                    //setting SSV validation to verified to avoid verifying address in salesforce again
                    //subscription.AddressValidationStatus__c = 'Verified';
                    //update objAccount ;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your account is successfully updated'));
                    isEdit = false;
                }
            }
            catch (DmlException ex){
                String messak = ex.getMessage();
                messak = messak.substring(messak.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+34,messak.length()-3);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,messak)); 
                isEdit = true;
            }
            catch (Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Operation failed due to some Internal Error ')); 
                System.debug('ex........'+ex);
                isEdit = true;
            }
        }
        else
            isEdit = true;
        
        return null;
    }
    
}