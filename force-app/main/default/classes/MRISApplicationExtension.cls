public class MRISApplicationExtension {
        /*
        Developer: Justin Padilla
        Class Description: This class extension is used by the Onboarding Signup Visualforce Page and provides
        onboarding forms for Appraiser/Realtor,Non & Shareholder, as well as Personal Assistant to Appraiser
        Subscription Types and saves the user's input form data in an MRIS_Application__c object record.        
        */
    private string AppraiserSelection;
    private string RealtorSelection;
    private MRIS_Application__c application;
    public String CompanyCode{get;set;}
    public Account BrokerInfo{get;set;}
    public String renderedAs{get;set;}
    public String SubscriptionId{get;set;}//Used for the confirmation screen by number
    //Map of Field Names and Description of that field
    Map<String,Schema.SObjectField> fields;
    //Variable used to fire off Javascript confirmation
    public Boolean Print{get;set;}
    public List<Account> Associations;
    public String selectedAssociation{get;set;}
    private Account NonShareHolder;
    public String AppraiserCode{get;set;}
    public Subscriptions__c Subscription{get;set;}
    
    public MRISApplicationExtension(Apexpages.StandardController controller)
    {
        //not refreshing radio buttons with F5- 08/09/2012
        
        //SM Code Fix June 6 - Reset Radio Buttons
        if (application == null){
            //AppraiserSelection = 'No';
            //RealtorSelection = 'No';        
            application = new MRIS_Application__c();
            System.debug('SUPER init:');
        }
        //SM changes end  
        SetUp();
    }
    
    
    public void SetUp() {
        //Populate Association
        Associations = [SELECT
        Account.Id,
        Account.Name,
        Account.Account_Name__c,
        Account.Shareholder_Board__c
        FROM Account
        WHERE Account.Type = 'Association'
        AND Account.Status__c = 'Active'];
        //throw new myException(string.valueof(Associations.size()));
        for (Account a:this.Associations)    {
            if (a.Account_Name__c.toLowerCase().contains('none chosen')) {
                    NonShareHolder = a;
                    break;
            }
        }
        //initialize subscriptions radio select
        System.debug('AppraiserSelection --> ' +AppraiserSelection);
        System.debug('RealtorSelection --> ' +RealtorSelection);
        System.debug('NonShareHolder --> ' +NonShareHolder);
        if (AppraiserSelection == null && RealtorSelection == null)  {
                    System.debug('SUPER null:');
                AppraiserSelection = 'No';
                RealtorSelection = 'No';
                this.application.Subscription_Type__c = 'Personal Assitant to Appraiser';
                this.SubscriptionId = '4';
                if (NonShareHolder != null) {
                    this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                }
                else {
                        this.application.Association_Board_Affiliation__c = null;
                }
        }
        System.debug('Apexpages.currentPage().getParameters().get(id) -->' + Apexpages.currentPage().getParameters().get('id'));
        if (Apexpages.currentPage().getParameters().get('id') != null && 
                Apexpages.currentPage().getParameters().get('id') != '') {
            renderedAs = 'pdf';
            //Get all fields
            String fieldNames ='';
            for (String s: GetFieldNames('MRIS_Application__c'))  {
                    fieldNames += s+',';
            }
            fieldNames = fieldNames.substring(0,fieldNames.length() - 1);                   
            //Get the Application Information for saved Id
            String query = 'SELECT '+fieldNames+' FROM MRIS_Application__c WHERE MRIS_Application__c.Id =\''+Apexpages.currentPage().getParameters().get('id')+'\'';
            this.application = Database.query(query);
            System.debug('query--------'+query+'this.application.......'+this.application);
            Account temp = [SELECT
            Account.Id,
            Account.Name
            FROM Account
            WHERE Account.Id =: this.application.Company_Code__c];
            this.CompanyCode = temp.Name;
            //Populate Company Information for printing
            LookupCompanyCode();
            //Populate Subscription Information for printing
             System.debug('!!Hello5');
             System.debug('this.application.Agent_Subscription_ID__c ' + this.application.Agent_Subscription_ID__c);
             if (this.application.Agent_Subscription_ID__c != null) { 
                    System.debug('this.application.Agent_Subscription_ID__c ' + this.application.Agent_Subscription_ID__c);
                    
                    
                    Subscriptions__c tempsub = [SELECT
                            Id,
                           Name,
                            AgentKey__c
                            FROM Subscriptions__c
                            WHERE Id =:this.application.Agent_Subscription_ID__c limit 1];
                            
                            
                    this.AppraiserCode = tempsub.Name;
                    LookupAppraiserCode();
            }
          
           
            System.debug('!!Hello4');
            //  
            Print = true;
            System.debug('!!Hello2');
                //Determine the Correct Radio Button Answers
            if (this.application.Subscription_Type__c != null) {
                if (this.application.Subscription_Type__c == 'Licensed Appraiser/Non Realtor')  {
                        AppraiserSelection = 'Yes';
                        RealtorSelection = 'No';
                }
                else if (this.application.Subscription_Type__c.contains('Realtor/Appraiser')) {
                        AppraiserSelection = 'Yes';
                                RealtorSelection = 'Yes';
                }
                else if (this.application.Subscription_Type__c == 'Personal Assitant to Appraiser')  {
                        AppraiserSelection = 'No';
                                RealtorSelection = 'No';
                }
            }
            if (this.application.Association_Board_Affiliation__c != null) {
                for (Account a:this.Associations)  {
                    if (a.Id == this.application.Association_Board_Affiliation__c)  {
                            this.selectedAssociation = a.Account_Name__c;
                    }
                }
            }
          System.debug('!!Hello1');
        }
        else
        {
                renderedAs = 'html';
                Print = false;
        }
    }
    public String getAppraiserSelection(){
        return this.AppraiserSelection;
    }
    
    public void setAppraiserSelection(String s){
        this.AppraiserSelection = s;
    }
    public String getRealtorSelection(){
        return this.RealtorSelection;
    }
    
    public void setRealtorSelection(String s){
        this.RealtorSelection = s;
    }
    public List<SelectOption> getAppraiser() {
        return new List<SelectOption>{new SelectOption('Yes','Yes'),new SelectOption('No','No')};
    }
    
    public List<SelectOption> getRealtor()  {
        return new List<SelectOption>{new SelectOption('Yes','Yes'),new SelectOption('No','No')};
    }
    
    public List<SelectOption> getAssociations()  {
        List<SelectOption> retval = new List<SelectOption>();
        for (Account a:Associations)
        {
                retval.add(new SelectOption(a.Account_Name__c,a.Account_Name__c));
        }
        retval = SortOptionList(retval);
        return retval;
    }
    
    public MRIS_Application__c getApplication(){
        return this.application;
    }
    
    public void setApplication(MRIS_Application__c app){
        this.application = app;
    }
    
    public Boolean getshowAppraiser() {
        return this.AppraiserSelection.toLowerCase() == 'yes';
    }
    public Boolean getshowAppraiser2() {
        return this.AppraiserSelection.toLowerCase() == 'yes';
    }
    public Boolean getshowRealtor() {
        return this.RealtorSelection.toLowerCase() == 'yes';
    }
    public String getshortExpDate()  {
        if (this.application.License_Expiration_Date__c != null) {
                return this.application.License_Expiration_Date__c.format();
        }
        else {
                return null;
        }
    }
    
    public Boolean getshowPDF(){
        
        return (this.renderedAs == 'pdf');
    }
    
    public void setshowPDF(Boolean b){
    }
    
    
    public void setSubscription(){
        
        System.debug('TESTER: m$$$ Setting Application Code: ');
            
        if(this.SubscriptionId!=null){
                System.Debug('SUPER 4: Subscription ID: ' + this.SubscriptionId + ' AppraiserSelect: ' + AppraiserSelection + ' Real: ' + RealtorSelection);
        }        
        if (AppraiserSelection == 'Yes' && RealtorSelection == 'No') {
                    this.application.Subscription_Type__c = 'Licensed Appraiser/Non Realtor';
                    this.application.Type__c = 'Appraiser';
                    this.application.License_Type__c = 'Appraiser';
                    this.SubscriptionId = '1';
        }
        else
        {
                if(AppraiserSelection == 'Yes' && RealtorSelection == 'Yes')  {
                        System.debug('this.selectedAssociation----->' + this.selectedAssociation);
                this.application.License_Type__c = 'Appraiser';
                if (this.selectedAssociation == null || this.selectedAssociation == '') {
                //Rod removed the hard-coded dash on Feb 2013//
                        this.application.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
                        this.application.Type__c = 'Appraiser';
                        this.SubscriptionId = '2';
                        if (NonShareHolder != null)
                                this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                        else
                                this.application.Association_Board_Affiliation__c = null;
                }
                else {
                    Boolean shareHolder = false;
                    for (Account a:this.Associations) {
                        System.debug('a.Account_Name__c ---->' + a.Account_Name__c);
                        System.debug('a.Shareholder_Board__c ----> ' + a.Shareholder_Board__c);
                        System.debug('this.selectedAssociation----->' + this.selectedAssociation);
                        if (a.Account_Name__c.equals(this.selectedAssociation))  {
                            if ('Yes'.equals(a.Shareholder_Board__c)) {
                                System.debug('inside true');
                                    shareHolder = true;
                            }
                           break;
                        }
                    }
                    System.debug('shareHolder ---->' + shareHolder);
                    if (shareHolder) {
                        this.application.Subscription_Type__c = 'Realtor/Appraiser Shareholder';
                        this.application.Type__c = 'Appraiser';
                        this.SubscriptionId = '3';
                    }
                    else {
                        this.application.Subscription_Type__c = 'Realtor/Appraiser Non Shareholder';
                        this.SubscriptionId = '2';
                        this.application.Type__c = 'Appraiser';
                        if (NonShareHolder != null)
                                this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                        else
                                this.application.Association_Board_Affiliation__c = null;
                    }
                }
            } else {
                if(AppraiserSelection == 'No' && RealtorSelection == 'No'){
                    this.application.Subscription_Type__c = 'Personal Assistant to Appraiser';
                    this.application.Type__c = 'Assistant';
                    this.SubscriptionId = '4';
                } else {
                        if(AppraiserSelection == 'No' && RealtorSelection == 'Yes') {
                    System.debug('SUPER BAD  setting to NULL');
                        this.application.Subscription_Type__c = null;
                        this.SubscriptionId = null;
                        }
                        }
                }
        }
        System.debug('this.SubscriptionId---->' + this.SubscriptionId);
    }
    
    
    public Pagereference LookupCompanyCode()
    {
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Entered: '+this.CompanyCode));
        //RAIN0001
        System.debug('this.CompanyCode ----> ' + this.CompanyCode);
        System.debug('this.CompanyCode ----> ' + this.CompanyCode);
        if (this.CompanyCode != '' && this.CompanyCode != null) {
            List<Account> companyLookup = new List<Account>();
            companyLookup = [SELECT
            Account.Id,
            Account.Account_Name__c,
            Account.Street_Name__c,
            Account.Street_Number__c, 
            Account.Street_Type__c,  
            Account.Street_Direction__c,  
            Account.City__c,
            Account.State__c,
            Account.County__c,
            Account.Zip__c,
            Account.BrokerAddress__c
            FROM Account
            WHERE Account.Name =: this.CompanyCode];
            if (companyLookup.size() > 0)  {
                this.application.Company_Code__c = companyLookup[0].Id;
                this.BrokerInfo = companyLookup[0];
               //concatenation is not needed as the formula feed is concatenating address and feeding in BrokerAddress; just retrieve BrokerAddress                                       
                        
            } else  {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Not Found!'));
                this.BrokerInfo = null;
                this.application.Company_Code__c = null;
            }
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Id Found: '+this.application.Company_Code__c));
        } else {
                this.BrokerInfo = null;
        }
        return null;
    }
    
    /**
    * Lookup Appraiser Code
    **/
    public Pagereference LookupAppraiserCode()  {
        System.debug('this.AppraiserCode --->' + this.AppraiserCode);
        System.debug('this.SubscriptionId --->' + this.SubscriptionId);
        if (this.AppraiserCode != '' && this.AppraiserCode != null){
            if(this.SubscriptionId!=null){
                    System.Debug('SUPER 1: Subscription ID: ' + this.SubscriptionId + ' AppraiserSelect: ' + AppraiserSelection + ' Real: ' + RealtorSelection);
            }                                       
           
            //See if the Appraiser is found Subscription.AgentKey
            List<Subscriptions__c> sub = new List<Subscriptions__c>();
            sub = [SELECT
                            Subscriptions__c.Id,
                            Subscriptions__c.Name,
                            Subscriptions__c.AgentKey__c,
                            Subscriptions__c.Contact__c,
                            Subscriptions__c.Contact__r.FirstName,
                            Subscriptions__c.Contact__r.LastName
                            FROM Subscriptions__c
                            WHERE Subscriptions__c.Name =: this.AppraiserCode and Subscriptions__c.Status__c='Active'
                            and Subscriptions__c.Contact_Type__c = 'Appraiser'];
            if (sub.size() > 0) {
                    Subscription = sub[0];
                    this.application.Agent_Subscription_ID__c = sub[0].Id;
                        if(this.SubscriptionId!=null){
                                System.Debug('SUPER 2: Subscription ID: ' + this.SubscriptionId + ' AppraiserSelect: ' + AppraiserSelection + ' Real: ' + RealtorSelection);
                        }  
                } else {
                if(this.SubscriptionId!=null){
                        System.Debug('SUPER 3: Subscription ID: ' + this.SubscriptionId + ' AppraiserSelect: ' + AppraiserSelection + ' Real: ' + RealtorSelection);
                } 
                Subscription = null;
                this.application.Agent_Subscription_ID__c = null;
            }
        }
        else {
                Subscription = null;
                this.application.Agent_Subscription_ID__c = null;
        }
        //No redirect for the page parameter
        return null;
    }
    
    
    public String getAppraiserName()
    {
        if (this.Subscription != null){
                return (this.Subscription.Contact__r.FirstName +' '+this.Subscription.Contact__r.LastName);
        }
        else return null;
    }
    
    public void setAppraiserName(String s){}
    
    public Pagereference Save()
    {
            try
        {
                if (this.AppraiserSelection.toLowerCase() == 'yes')
                {
                        //Create License Expiration
                        Integer month = 0;
                        if (application.Date_Expires_Month__c != null && application.Date_Expires_Month__c != '')
                        {
                                if (application.Date_Expires_Month__c.toLowerCase().contains('jan'))
                                {
                                        month = 1;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('feb'))
                                {
                                        month = 2;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('mar'))
                                {
                                        month = 3;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('apr'))
                                {
                                        month = 4;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('may'))
                                {
                                        month = 5;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('june'))
                                {
                                        month = 6;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('july'))
                                {
                                        month = 7;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('aug'))
                                {
                                        month = 8;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('sept'))
                                {
                                        month = 9;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('oct'))
                                {
                                        month = 10;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('nov'))
                                {
                                        month = 11;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('dec'))
                                {
                                        month = 12;
                                }
                        }
                        if (this.application.Date_Expires_Year__c != null && this.application.Date_Expires_Year__c != '')
                                this.application.License_Expiration_Date__c = date.parse(month+'/1/'+this.application.Date_Expires_Year__c);
                }
                if (this.selectedAssociation != '')
                {
                        //Find the Account so we can save it to the record
                        for (Account a:this.Associations)
                        {
                                if (a.Account_Name__c == this.selectedAssociation)
                                {
                                        this.application.Association_Board_Affiliation__c = a.Id;
                                        break;
                                }
                        }
                }
            this.application.Status__c = 'New';
            insert(this.application);
            MRISApplicationCase.Create(this.application);
            Print = true;
            return null;            
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! '+e.getMessage()));
            return null;
        }
     }
     public Pagereference Print()
     {
        try
        {
            Pagereference page = new Pagereference('/apex/Signup');
            renderedAs = 'pdf';
            page.getParameters().put('id',this.application.Id);
            page.setRedirect(true);
            system.debug('Tester: Signup Page ID: ' + this.application.Id + ' RenderAs: ' + renderedAs);
            return page;            
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! '+e.getMessage()));
            return null;
        }
     }
     private List<String> GetFieldNames(String objectname)
     {
        List<String> retval = new List<String>();
        //Use GlobalDescribe to get a list of all available Objects
        Map<String,Schema.Sobjecttype> gd = Schema.getGlobalDescribe();
        Set<String> objectKeys = gd.keySet();
        for (String objectKey:objectKeys) //Iterate through all of the objects until we get to the one we need
        {
                if (objectKey == objectname.toLowerCase()) //Object exists, get field names
            {
                Schema.SObjectType systemObjectType = gd.get(objectKey);
                Schema.DescribeSObjectResult r = systemObjectType.getDescribe();
                Map<String, Schema.SObjectField> M = r.fields.getMap();
                Set <String>fieldNames = M.keySet();
                fields = new Map<String,Schema.SObjectField>();
                //Create a copy of the Map with the Display Name, and Properties for retreival in the Selection
                for (String fieldName:fieldNames)
                {
                        //For each field, Add to List
                    Schema.SObjectField field = M.get(fieldName);
                    Schema.DescribeFieldResult fieldDesc = field.getDescribe();                                     
                    //retval.add(fieldDesc.getLabel()); //Adds the Salesforce UI label to listing
                    retval.add(fieldDesc.getName()); //Adds the Salesforce UI label to listing
                    fields.put(fieldDesc.getLabel(),field);
                }
             }
         }                               
         return retval;
        }
        
        
    private static List<SelectOption> SortOptionList(List<SelectOption> ListToSort)
    {
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        for(SelectOption x : ListToSort)
        {
            if(x.getLabel() <= pivotValue.getLabel())
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);   
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));
        return returnList; 
    }
    
    
        public class myException extends Exception{}
        static testMethod void MRISApplicationExtensionTest()
        {
        Test.startTest();
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        CornerstoneMappings__c cm1 = new CornerstoneMappings__c();
        cm1.TypeName__c = 'Association';
        cm1.CornerStoneID__c = '10234163875';
        insert cm1;
        
        CornerstoneMappings__c cm2 = new CornerstoneMappings__c();
        cm2.TypeName__c = 'Branch Office';
        cm2.CornerStoneID__c = '10041844141';
        insert cm2;
        
        
        CornerstoneMappings__c cm3 = new CornerstoneMappings__c();
        cm3.TypeName__c = 'Office';
        cm3.CornerStoneID__c = '10000065693';
        insert cm3;    
        
        CornerstoneMappings__c cm4 = new CornerstoneMappings__c();
        cm4.TypeName__c = 'Stockholder';
        cm4.CornerStoneID__c = '50000016059';
        insert cm4;        
        
        CornerstoneMappings__c cm5 = new CornerstoneMappings__c();
        cm5.TypeName__c = 'Agent';
        cm5.CornerStoneID__c = '10391959693';
        insert cm5;        
        
        CornerstoneMappings__c cm6 = new CornerstoneMappings__c();
        cm6.TypeName__c = 'Edit';
        cm6.CornerStoneID__c = '10244895319';
        insert cm6;        
            
        CornerstoneMappings__c cm7 = new CornerstoneMappings__c();
        cm7.TypeName__c = 'Lister';
        cm7.CornerStoneID__c = '10244895320';
        insert cm7; 
        
        CornerstoneMappings__c cm8 = new CornerstoneMappings__c();
        cm8.TypeName__c = 'Search';
        cm8.CornerStoneID__c = '10244895323';
        insert cm8;     
        
        CornerstoneMappings__c cm9 = new CornerstoneMappings__c();
        cm9.TypeName__c = 'Realtor/Shareholder';
        cm9.CornerStoneID__c = '50000131634';
        insert cm9;    
        
        
        CornerstoneMappings__c cm10 = new CornerstoneMappings__c();
        cm10.TypeName__c = 'System-MRIS';
        cm10.CornerStoneID__c = '50001337575';
        insert cm10;        
           
            
        CornerstoneMappings__c cm11 = new CornerstoneMappings__c();
        cm11.TypeName__c = 'Status Duplicate';
        cm11.CornerStoneID__c = '50000016003';
        insert cm11;         
 
        Map<ID,CornerstoneMappings__c> mappings = new  Map<ID,CornerstoneMappings__c>([SELECT id, TypeName__c,CornerstoneID__c FROM CornerstoneMappings__c where TypeName__c in ('Office', 'Association', 'Stockholder','Branch Office')]);
        System.debug('Map Totals ---->' + mappings.size());
        
        AggregateResult[] cntOfAccts = [Select  count(id) from CornerstoneMappings__c];
                for(AggregateResult ar : cntOfAccts ) {
                        System.debug('Account Totals:  '  + ar.get('expr0'));
                }
        
        Account a12 = new Account();
       a12.name = 'AGC1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';
        a12.Street_Type__c = '';
        a12.Billing_Street_Type__c = 'BLFS';
        a12.QAS_Mailing_Street_Type__c ='test';
        a12.Company_Type__c = 'Broker Office';
        a12.Type='Appraiser';
        insert a12;        
        
        //Create Test Accounts
        Account a1 = new Account();
        a1.name = 'ABC1234';
        a1.type = 'Residential';
        a1.Account_Name__c = 'Test Account';
        a1.City__c = 'Herndon';
        a1.Zip__c = '20171';
        a1.QAS_Mailing_County__c = 'Fairfax';
        a1.County__c = 'Fairfax';
        a1.Street_Type__c = '';
        a1.Billing_Street_Type__c = 'BLFS';
        a1.QAS_Mailing_Street_Type__c ='test';
        a1.parentid = a12.id;        
        insert(a1);
          
          
        Account a2 = new Account();
        a2.Name = 'TEST0002';
        a2.type = 'Residential';
        a2.Account_Name__c = 'Test Account';
        a2.City__c = 'Herndon';
        a2.Zip__c = '20171';
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.County__c = 'Fairfax';
        a2.Street_Type__c = '';
        a2.Billing_Street_Type__c = 'BLFS';
        a2.QAS_Mailing_Street_Type__c ='test';
        a2.parentid = a12.id;     
        insert(a2);
        
        
        /*Account a3 = new Account();
        a3.Name = 'TEST0003';
        a3.Account_Name__c = 'None Chosen';
        a3.Shareholder_Board__c = 'No';
        a3.Type = 'Association';
        a3.Status__c = 'Active';
        a3.City__c = 'Herndon';
        a3.Zip__c = '20171';
        a3.parentid = a12.id;       
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.County__c = 'Fairfax';
        a2.Street_Type__c = '';
        a2.Billing_Street_Type__c = 'BLFS';
        a2.QAS_Mailing_Street_Type__c ='test';
        insert(a3); */
        
        //Create a Contact
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Justin';
        c1.LastName = 'Padilla';
        c1.Status__c = 'Active';
        c1.Public_Email__c = 'jpadilla@rainmaker-llc.com';
        c1.Phone = '443-739-0628';
        c1.City__c = 'Herndon';
        c1.State__c = 'VA';
        c1.County__c = 'Fairfax';
        c1.Zip__c = '20171';            
        insert(c1);
         
        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.Name = 'test';
        s1.Status__c = 'In Progress';
        s1.Addl_Display_Name__c = 'xyz';
        s1.Box__c = NULL;
        s1.City__c = 'Herndon';
        s1.QAS_Mailing_Country__c = 'USA';
        s1.QAS_Mailing_County__c = 'Fairfax';
        s1.State__c = 'VA';
        s1.QAS_Mailing_Street_Direction__c = 'N';
        s1.Street_Name__c = 'First';
        s1.Street_Number__c ='1275';
        s1.Street_Number_Suffix__c = NULL;
        s1.QAS_Mailing_Street_Type__c = 'ST';
        s1.Unit__c = '1';
        s1.QAS_Mailing_Unit_Type__c = 'SU';
        s1.Zip__c ='20002';
        s1.Zip_4__c = NULL;
        s1.QAS_Mailing_POBox__c = NULL;
        s1.QAS_Mailing_Record_Type__c = NULL;
        s1.Copy_Address_to_Billing__c = true;
        s1.QAS_Mailing_Record_Type__c = 'P';
        s1.Contact_Type__c = 'Broker';
        s1.Subscription_Type__c = 'Licensee';
        s1.County__c = 'Fairfax';
        s1.Contact__c = c1.id;
        s1.primary__c = true;
        
        insert(s1);      
/*        
        //Create Subscription
        Subscriptions__c s2 = new Subscriptions__c();
        s2.AgentKey__c = '123456789';
        s2.Name = 'TEST';
        s2.City__c = 'Herndon';
        s2.County__c = 'Fairfax';
        s2.Zip__c = '20171';
        s2.Contact__c = c1.Id;
        insert(s2);
*/        
        Subscriptions__c sc = new Subscriptions__c();
        sc.Contact__c = c1.Id;
        sc.Name = '1234511';
        sc.Contact_Type__c = 'Agent';
        sc.Subscription_Type__c = 'Licensee';

        sc.Public_Email__c = 'email@something.com';
        sc.Status__c = 'In Progress';
        sc.Primary_Phone__c = '1231111643';
        sc.Public_Email__c = 'email@something.com';
        sc.Mobile_Phone__c = '1231112643';
        sc.City__c = 'Herndon';
        sc.Zip__c = '20171';
        sc.County__c = 'Fairfax';
        sc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc.Country__c = 'UNITED STATES';
        sc.State__c = 'VA';
        sc.Contact_Type__c = 'Agent';
        insert sc;
        
        
        MRIS_Application__c application = new MRIS_Application__c();
        Apexpages.StandardController controller = new Apexpages.StandardController(application);
        MRISApplicationExtension page = new MRISApplicationExtension(controller);
        page.getAppraiser();
        page.getRealtor();
        page.setAppraiserSelection(page.getAppraiserSelection());
        page.setRealtorSelection(page.getRealtorSelection());
        page.getAssociations();
        page.setAppraiserName(page.getAppraiserName());
                
        
        page.getshowAppraiser();
        page.getshowAppraiser2();
        page.setshowPDF(page.getshowPDF());
        page.getshowRealtor();
        page.getshortExpDate();
        
                
        page.setApplication(page.getApplication());
        page.setSubscription(); //No,No Personal Assistant
        page.setAppraiserSelection('Yes');
        page.setSubscription(); //Yes,No
        page.setRealtorSelection('Yes');
        page.setSubscription(); //Yes,Yes
        //Switch between share holder/non share holder
        page.selectedAssociation = 'TEST0001';
        page.setSubscription();
        page.selectedAssociation = 'TEST0002';
        page.setSubscription();
        
        page.setAppraiserSelection('No');
        page.setSubscription(); //No, Yes
             
        page.CompanyCode = 'TEST0001'; //Valid Account Name
        page.LookupCompanyCode();
        page.CompanyCode = ''; //Empty
        page.LookupCompanyCode();
        page.CompanyCode = 'Invalid'; //Invalid Account Name
        page.LookupCompanyCode();
               
        page.LookupAppraiserCode(); //null
        page.AppraiserCode = 'Invalid';
        page.LookupAppraiserCode(); //Invalid
        page.AppraiserCode = '123456789';
        page.LookupAppraiserCode(); //Valid
               
        application.First_Name__c = 'Justin';
        application.Last_Name__c = 'Padilla';
        application.Primary_Phone__c = '443-739-0628';
        application.Mobile_Phone__c = '443-739-0628';
        application.Public_Email__c = 'jpadilla@rainmaker-llc.com';
        // set Company_Code__c
        application.Company_Code__c = a12.Id;
        page.CompanyCode = 'TEST0001';
        page.LookupCompanyCode();
        page.Save();
               
        //Set Appraiser Selection back to yes
        page.setAppraiserSelection('Yes');
        page.Save();
        //Now set all months
        MRIS_Application__c app = page.getApplication();
        app.Date_Expires_Month__c = 'jan';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'feb';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'mar';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'april';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'may';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'june';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'july';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'aug';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'sept';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'oct';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'nov';
        page.setApplication(app);
        page.Save();
        app.Date_Expires_Month__c = 'dec';
        page.setApplication(app);
        page.Save();
        // set Company_Code__c
        app.Company_Code__c = a12.Id;
        page.setApplication(app);
        page.Save();

        //Set Year and Association
        app.Date_Expires_Year__c = '2015';              
        page.setApplication(app);
        page.selectedAssociation = 'TEST2';     
        page.Save();
        page.getshortExpDate();
        page.Print();       
        app = page.getApplication();
        System.debug('app..............'+app);
        //Test PDF Version
        app.Company_Code__c = a2.id;
        Apexpages.StandardController controller2 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);      
        System.debug('controller2.........'+controller2.getRecord().get('Company_Code__c'));
        try{
        MRISApplicationExtension page2 = new MRISApplicationExtension(controller2);
        //Test Different Subscription Types on PDF version
        app.Subscription_Type__c = 'Licensed Appraiser/Non Realtor';
        update(app);
        Apexpages.StandardController controller3 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
 //       MRISApplicationExtension page3 = new MRISApplicationExtension(controller3);
        
        app.Subscription_Type__c = 'Realtor/Appraiser Shareholder';
        update(app);
 //       Apexpages.StandardController controller4 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
 //       MRISApplicationExtension page4 = new MRISApplicationExtension(controller4);
        
        app.Subscription_Type__c = 'Personal Assitant to Appraiser';
        update(app);
 //       Apexpages.StandardController controller5 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
 //       MRISApplicationExtension page5 = new MRISApplicationExtension(controller5);
        
        }catch(exception e){}
        Test.stopTest();
    }
}