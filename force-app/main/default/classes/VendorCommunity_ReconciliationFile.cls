public class VendorCommunity_ReconciliationFile {

    public string accountId {get; set;}
    public string officeId {get; set;}
    public string displayName {get; set;}
    public attachment fileUpdate {get; set;}
    
    public attachment vendAttachment1 {get; set;}
    public attachment vendAttachment2 {get; set;}
    public attachment vendAttachment3 {get; set;}
    public attachment vendAttachment4 {get; set;}
    
    public blob fileQuat1 {get; set;}
    
    public boolean q1Button {get; set;}
    public boolean q2Button {get; set;}
    public boolean q3Button {get; set;}
    public boolean q4Button {get; set;}
    
    public integer editableDays;
    public Account objAccount;
    public string contactName {get; set;}
    
    public VendorCommunity_ReconciliationFile(){
        loadFiles();  
    }
    public void loadFiles(){
        try {
            editableDays = integer.valueOf(Label.VendorCommunity_Reconciliation_editable_days);
           
            vendAttachment1 = new attachment();
            vendAttachment2 = new attachment();
            vendAttachment3 = new attachment();
            vendAttachment4 = new attachment();
            q4Button = false;
            q4Button = false;
            q4Button = false;
            q4Button = false;
            
            List<User> currentUser = [SELECT   FederationIdentifier, ContactId, Contact.Name 
                                      FROM     User 
                                      WHERE    Id = :Userinfo.getUserId()
                                     ];
            
            if (currentUser.size() == 0) return;          
            
            List<Contact> contact = [SELECT  Id, Name, AccountId, Account.Name
                                     FROM    Contact
                                     WHERE   Id =: currentUser[0].ContactId
                                    ];
            
            if (contact.size() == 0) return;
            
            //name = contact[0].Account.Name;
            contactName = contact[0].Name;
            
            accountId = ApexPages.currentPage().getParameters().get('id');
            
            if (String.isBlank(accountId)) 
                throw new CustomException('Invalid Account ID'); 
            
            list<Account> vendorAccounts = [Select Id, Name, QAS_Validation_Timestamp__c, 
                                            (select Id, Name, parentId, createdDate, LastModifiedDate from Attachments 
                                             			Where createdDate = this_year 
                                             			And Name like '%-Q%' order by createdDate asc)
                                            From Account 
                                            Where Name =: accountId
                                            And Type = 'RETS'
                                            And Status__c = 'Active' ];
            
			if(vendorAccounts == null || vendorAccounts.size() == 0 ) 
                throw new CustomException('Invalid Vendor ID');
			
			officeId = vendorAccounts[0].id;
			displayName = vendorAccounts[0].Name;
            objAccount = vendorAccounts[0];
            list<attachment> Attachments = vendorAccounts[0].Attachments;
            system.debug('---officeId-->'+officeId);
            
            /*
            list<attachment> Attachments = [select Id, Name, parentId, createdDate from Attachment 
                                             			Where parentId = officeId
                                            			And createdDate = this_year 
                                             			And Name like '%-Q%' order by createdDate asc];
            */
            
            Integer month = date.today().month();
            Integer quarter = math.round((month+1)/3.0);
            system.debug(month + ' = ' + math.round((month+1)/3.0));
            
            if(quarter == 1){
                system.debug('==FirstQuarter==');
            }
            else if(quarter == 2){
                q1Button = true;
                system.debug('==SecondQuarter==');
            }
            else if (quarter == 3){
                system.debug('==ThirdQuarter==');
                q1Button = true;
                q2Button = true;
            }
            else {
                system.debug('==fourthQuarter==');
                q1Button = true;
                q2Button = true;
                q3Button = true;  
            }
            
            if(Attachments != null && Attachments.size() > 0 ){
                
                map<string, map<attachment, boolean>> mp = new map<string, map<attachment, boolean>>();
                //mp.put('Q1', new map<attachment, string>{attachment1, q1Button} )
                for(Attachment att : Attachments){
                    system.debug('---att.Name---'+att.Name);
                    if(att.Name.contains('Q1') ){
                        vendAttachment1 = att;
                        q1Button = checkFile(att, vendAttachment1);
                    }
                    if(att.Name.contains('Q2') ){
                        vendAttachment2 = att;
                        q2Button = checkFile(att, vendAttachment2);
                    }
                    if(att.Name.contains('Q3') ){
                        vendAttachment3 = att;
                        q3Button = checkFile(att, vendAttachment3);
                    }
                    if(att.Name.contains('Q4') ){
                        vendAttachment4 = att;
                        q4Button = checkFile(att, vendAttachment4);
                    }
                    
                }
                system.debug('---q1Button be--'+q1Button);
                system.debug('---q2Button be--'+q2Button);
                system.debug('---q3Button be--'+q3Button);
                system.debug('---q4Button be--'+q4Button);
                
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public boolean checkFile(attachment att, attachment att1){
        
        att.Name = att.Name.split('-Q')[0];
        date dt = date.valueOf(att.createdDate);
        //date dt = date.valueOf(objAccount.QAS_Validation_Timestamp__c);
        date todayDate = system.today();
        att1 = att;

        boolean temp = false;
        integer daysBetween = dt.daysBetween(todayDate);
        
        system.debug('---daysBetween-->>'+daysBetween);
        system.debug('---editableDays-->>'+editableDays);
                
        if(daysBetween >= editableDays){
        	temp = true;
            system.debug('---temp inside if--'+temp);  
        }
        system.debug('---temp aft--'+temp);
        return temp;
    }
    
        
    public void firstQuaterFileUpload(){
        try{
            system.debug('---file 1--->');
            if(vendAttachment1 != null){
                system.debug('---vendAttachment1.Name--'+vendAttachment1.Name+'---'+vendAttachment1.body); 
                //vendAttachment1.Name = vendAttachment1.Name+'-'+'Q1-'+system.today().year();
                saveFile(vendAttachment1, 'Q1');
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public void secondQuaterFileUpload(){
        try{
            system.debug('---file 2--->');
            if(vendAttachment2 != null){
                saveFile(vendAttachment2, 'Q2');
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    public void thirdQuaterFileUpload(){
        try{
            system.debug('---file 3--->');
            if(vendAttachment3 != null){
                saveFile(vendAttachment3, 'Q3');
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    public void fourQuaterFileUpload(){
        try{
            system.debug('---file 4--->');
            if(vendAttachment4 != null){
                saveFile(vendAttachment4, 'Q4');
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public void saveFile(attachment att, string temp){
        system.debug('---att.Name--'+att.Name+'---'+att.body);
        //Attachment a = new Attachment(parentid = officeId, Name = att.name , Body = att.body);
        att.Name = att.Name.split('.xls')[0]+'.xls'+'-'+contactName+'-'+temp+'-'+system.today().year();
        if(att.Id == null)
        	att.ParentId = officeId;
        upsert att;
        att.Name = att.Name.split('-Q')[0];
        system.debug('---file --->'+att);
        loadFiles();
    }
   
    public class CustomException extends Exception {}
}