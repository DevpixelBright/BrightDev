public class MRISApplicationExtension2 {
    /*
    Developer: Justin Padilla
    Class Description: This class extension is used by the Onboarding Signup2 Visualforce Page and provides
    onboarding forms for Office Secretary, Personal Assistant, Licensee/Non Realtor, and Realtor Shareholder/Non Shareholder
    Subscription Types and saves the user's input form data in an MRIS_Application__c object record.    
    */
    private String NonRealtorSelection;
    private string RealtorSelection;
    private String OfficeSecretaryNCSelection;
    private String LicenseTypeSelection;
    private MRIS_Application__c application;
    public String BrokerCode{get;set;}
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
    public String AgentCode{get;set;}
    
    public MRISApplicationExtension2(Apexpages.StandardController controller)
    {
        if (application == null)
            application = new MRIS_Application__c();
        SetUp();
    }
    public void SetUp()
    {
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
        for (Account a:this.Associations)
        {
                if (a.Account_Name__c.toLowerCase().contains('none chosen'))
                {
                        NonShareHolder = a;
                        break;
                }
        }
        if (RealtorSelection == null) //initialize radio selects and Subscription Types
        {
                RealtorSelection = 'Yes';
                OfficeSecretaryNCSelection = 'No';
                LicenseTypeSelection = 'Associate Broker';
                this.application.Subscription_Type__c = 'Personal Assistant to Appraiser';
                this.SubscriptionId = '4';
                if (NonShareHolder != null)
                        this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                else
                        this.application.Association_Board_Affiliation__c = null;
        }
                if (Apexpages.currentPage().getParameters().get('id') != null && Apexpages.currentPage().getParameters().get('id') != '')
        {
                renderedAs = 'pdf';
                //Get all fields
                String fieldNames ='';
                for (String s: GetFieldNames('MRIS_Application__c'))
                {
                        fieldNames += s+',';
                }
                fieldNames = fieldNames.substring(0,fieldNames.length() - 1);                   
                //Get the Application Information for saved Id
                String query = 'SELECT '+fieldNames+' FROM MRIS_Application__c WHERE MRIS_Application__c.Id =\''+Apexpages.currentPage().getParameters().get('id')+'\'';
                this.application = Database.query(query);
                Account temp = [SELECT
                Account.Id,
                Account.Name
                FROM Account
                WHERE Account.Id =: this.application.Company_Code__c];
                this.BrokerCode = temp.Name;
                //Populate Company Information for printing
                LookupBrokerCode();
                //Populate Subscription Information for printing
                if (this.application.Agent_Subscription_ID__c != null)
                {
                        Subscriptions__c tempsub = [SELECT
                        Subscriptions__c.Id,
                        Subscriptions__c.Name,
                        Subscriptions__c.AgentKey__c
                        FROM Subscriptions__c
                        WHERE Subscriptions__c.Id =: this.application.Agent_Subscription_ID__c];
                        //JGP 11/30/2012 PDF Agent Information Incorrect Fix
                        //this.AppraiserCode = tempsub.AgentKey__c;
                        this.AppraiserCode = tempsub.Name;
                        LookupAppraiserCode();
                }
                Print = false;
               //SM Code Fix June 6 - License Display in PDF
                this.LicenseTypeSelection = this.application.License_Type__c;              
               // SM changes end                
                //Determine the Correct Radio Button Answers ect for printing
                if (this.application.Subscription_Type__c != null)
                {
                    //JGP 10/14/2012 Added in || this.application.Subscription_Type__c.toLowerCase().contains('licensee/non realtor') for correct print out
                        if (!this.application.Subscription_Type__c.toLowerCase().contains('realtor') || this.application.Subscription_Type__c.toLowerCase().contains('licensee/non realtor'))
                        {
                                RealtorSelection = 'No';
                                this.NonRealtorSelection = this.application.Subscription_Type__c;
                                
                        }
                }
                if (this.application.Association_Board_Affiliation__c != null)
                {
                        for (Account a:this.Associations)
                        {
                                if (a.Id == this.application.Association_Board_Affiliation__c)
                                {
                                        this.selectedAssociation = a.Account_Name__c;
                                        System.debug('selected association --> ' + this.selectedAssociation);
                                }
                        }
                }
        }
        else
        {
                setSubscription();
                renderedAs = 'html';
                Print = false;
        }
    }
    public String getRealtorSelection(){return this.RealtorSelection;}
    public void setRealtorSelection(String s){this.RealtorSelection = s;}
    public String getNonRealtorSelection(){return this.NonRealtorSelection;}
    public void setNonRealtorSelection(String s){this.NonRealtorSelection = s;}
    public String getOfficeSecretaryNCSelection(){return this.OfficeSecretaryNCSelection;}
    public void setOfficeSecretaryNCSelection(String s){this.OfficeSecretaryNCSelection = s;}
    public String getLicenseTypeSelection(){return this.LicenseTypeSelection;}
    public void setLicenseTypeSelection(String s){this.LicenseTypeSelection = s;} 
 
        public List<SelectOption> getNonRealtor()
        {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('','Please Select'));
                options.add(new SelectOption('Licensed Real Estate Agent','Licensed Real Estate Agent'));
                options.add(new SelectOption('Personal Assistant','Personal Assistant'));
                options.add(new SelectOption('Office Secretary','Office Secretary'));
                return options;
        }
    
    public List<SelectOption> getLicenseType()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Associate Broker','Associate Broker'));
        options.add(new SelectOption('Salesperson','Salesperson'));
        return options;
    }
    
    public List<SelectOption> getRealtor()
    {
        return new List<SelectOption>{new SelectOption('Yes','Yes'),new SelectOption('No','No')};
    }
    public List<SelectOption> getAssociations()
    {
        List<SelectOption> retval = new List<SelectOption>();
        for (Account a:Associations)
        {
                retval.add(new SelectOption(a.Account_Name__c,a.Account_Name__c));
        }
        retval = SortOptionList(retval);
        return retval;
    }
    public MRIS_Application__c getApplication(){return this.application;}
    public void setApplication(MRIS_Application__c app){this.application = app;}

    public Boolean getshowRealtor()
    {
        return this.RealtorSelection.toLowerCase() == 'yes';
    }
    public String getshortExpDate()
    {
        if (this.application.License_Expiration_Date__c != null)
        {
                return this.application.License_Expiration_Date__c.format();
        }
        else return null;
    }
    public Boolean getshowPDF(){return this.renderedAs == 'pdf';}
    public void setshowPDF(Boolean b){}
    
   
    
    public boolean getshowSecretaryQuestion()
    {
        return (this.NonRealtorSelection == 'Office Secretary');
    }
    public Boolean getshowPersonalAssistant()
    {
        return (this.NonRealtorSelection == 'Personal Assistant');
    }
    //JGP 10/18/2012 Corrected issue with the NonRealtorSelection - 
    // when retrieving this value from the database it's looking for the 'licensed real estate agent'
    // wording on the Subscription type, however it's saved as 'Licensee/Non Realtor' subscription type in
    // the database. Added the additional subscription type to the license show/printing criteria
    public Boolean getshowRealEstate()
    {
        return (this.NonRealtorSelection == 'Licensed Real Estate Agent' || this.RealtorSelection.toLowerCase() == 'yes' || this.NonRealtorSelection == 'Licensee/Non Realtor');
    }
    public Boolean getshowFooter()
    {
        return (this.NonRealtorSelection == 'Licensed Real Estate Agent' || this.RealtorSelection.toLowerCase() == 'yes');
    }
    public void setSubscription()
    {
        System.debug('Realtor Selection --> ' + RealtorSelection);  
        if (RealtorSelection == 'Yes')
        {
                Boolean shareHolder;
                integer rum = 0;
                for (Account a:this.Associations)
                {
                        System.debug('Account Name/Selected Assoc --> ' + a.Account_Name__c+'/'+this.selectedAssociation);
                        if (a.Account_Name__c == this.selectedAssociation)
                        {
                            shareholder = false; 
                            rum = 1;                     
                                System.debug('Shareholder Board? --> ' + a.Shareholder_Board__c);
                                if (a.Shareholder_Board__c == 'Yes')
                                {
                                        shareHolder = true;
                                        rum = 2;
                                        break;
                                }
                                else
                                {
                                        break;
                                        rum = 3;
                                }
                        }

                }
                if (shareHolder == true)
                {
                        this.application.Subscription_Type__c = 'Realtor/Shareholder';
                        this.application.Type__c  = 'Agent';
                        this.SubscriptionId = '10';
                }
                else
                {
                        this.application.Subscription_Type__c = 'Realtor/Non Shareholder';
                        this.SubscriptionId = '9';
                        this.application.Type__c  = 'Agent';
                        if (NonShareHolder != null)
                                this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                        else
                                this.application.Association_Board_Affiliation__c = null;
                }
        }
        else
        {
                if (NonRealtorSelection != '')
                {
                        if (NonRealtorSelection == 'Licensed Real Estate Agent')
                        {
                                this.application.Subscription_Type__c = 'Licensee/Non Realtor';
                                this.application.Type__c  = 'Agent';
                                this.SubscriptionId = '8';
                                if (NonShareHolder != null)
                                                this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                                        else
                                                this.application.Association_Board_Affiliation__c = null;
                        }
                        else if (NonRealtorSelection == 'Personal Assistant')
                        {
                                this.application.Subscription_Type__c = 'Personal Assistant';
                                this.SubscriptionId = '7';
                                this.application.Type__c  = 'Assistant';
                        }
                        else if (NonRealtorSelection == 'Office Secretary')
                        {
                                this.application.Type__c  = 'Staff';
                                if (OfficeSecretaryNCSelection == 'Yes')
                                {
                                        this.application.Subscription_Type__c = 'Office Secretary - NC';
                                        this.SubscriptionId = '6';
                                }
                                else
                                {
                                        this.application.Subscription_Type__c = 'Office Secretary';
                                        this.SubscriptionId = '5';
                                }
                        }
                }
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Subscription Id: '+this.SubscriptionId));
    }
    public Pagereference LookupBrokerCode()
    {
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Entered: '+this.CompanyCode));
        //RAIN0001
        if (this.BrokerCode != '' && this.BrokerCode != null)
        {
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
                WHERE Account.Name =: this.BrokerCode];
                if (companyLookup.size() > 0)
                {
                        this.application.Company_Code__c = companyLookup[0].Id;
                        
                        this.BrokerInfo = companyLookup[0];
                        //concatenation is not needed using formula field                                             
                            
                }
                else
                {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Not Found!'));
                        this.BrokerInfo = null;
                        this.application.Company_Code__c = null;
                }
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Id Found: '+this.application.Company_Code__c));
        }
        else
                this.BrokerInfo = null;
        return null;
    }
    public Pagereference LookupAppraiserCode()
    {
        if (this.AppraiserCode != '' && this.AppraiserCode != null)
        {
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
                            and Subscriptions__c.Contact_Type__c = 'Agent'];
                        if (sub.size() > 0)
                        {
                                Subscription = sub[0];
                                this.application.Agent_Subscription_ID__c = sub[0].Id;
                        }
                        else
                        {
                                Subscription = null;
                                this.application.Agent_Subscription_ID__c = null;
                        }
        }
        else
        {
                Subscription = null;
                this.application.Agent_Subscription_ID__c = null;
        }
        return null;
    }
    public String getAppraiserName()
    {
        if (this.Subscription != null)
        {
                return (this.Subscription.Contact__r.FirstName +' '+this.Subscription.Contact__r.LastName);
        }
        else return null;
    }
    public void setAppraiserName(String s){}
    public Pagereference Save()
    {
            try
        {
                if (NonRealtorSelection == 'Licensed Real Estate Agent' || this.RealtorSelection.toLowerCase() == 'yes')
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
                        this.application.License_Type__c = LicenseTypeSelection;
                        
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
            Pagereference page = new Pagereference('/apex/Signup2');
            page.getParameters().put('id',this.application.Id);
            page.setRedirect(true);
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
    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort)
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
    static testMethod void MRISApplicationExtension2Test()
    {
        
        CornerstoneAddrUtility c = new CornerstoneAddrUtility();
        c.addAddrs();
        
        Test.startTest();
        
        //Create Test Accounts
        Account a1 = new Account();
        a1.Name = 'TEST0001';
        a1.Account_Name__c = 'TEST';
        a1.Shareholder_Board__c = 'Yes';
        a1.Type = 'Association';
        a1.Status__c = 'In Progress';
        a1.City__c = 'Herndon';
        a1.Zip__c = '21224';
        a1.QAS_Mailing_County__c = 'Fairfax';
        a1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a1.County__c = 'Fairfax';
        insert(a1);
        Account a2 = new Account();
        a2.Name = 'TEST0002';
        a2.Account_Name__c = 'TEST2';
        a2.Shareholder_Board__c = 'No';
        a2.Type = 'Association';
        a2.Status__c = 'In Progress';
        a2.City__c = 'Herndon';
        a2.Zip__c = '21224';
        a2.QAS_Mailing_County__c = 'Fairfax';
        a2.County__c = 'Fairfax';
        a2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert(a2);
        Account a3 = new Account();
        a3.Name = 'TEST0003';
        a3.Account_Name__c = 'None Chosen';
        a3.Shareholder_Board__c = 'No';
        a3.Type = 'Association';
        a3.Status__c = 'In Progress';
        a3.City__c = 'Herndon';
        a3.Zip__c = '21224';
        a3.QAS_Mailing_County__c = 'Fairfax';
        a3.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        a3.County__c = 'Fairfax';
        insert(a3);
        //Create a Contact
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Justin';
        c1.LastName = 'Padilla';
        //c1.Status__c = 'Active';
        c1.Public_Email__c = 'jpadilla@rainmaker-llc.com';
        c1.Phone = '443-739-0628';
        c1.City__c = 'Herndon';
        c1.State__c = 'VA';
        c1.County__c = 'Fairfax';
        c1.Zip__c = '20171';            
        insert(c1);
        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.AgentKey__c = '123456789';
        s1.Name = 'TEST';
        s1.City__c = 'Herndon';
        s1.County__c = 'Fairfax';
        s1.Zip__c = '20171';
        s1.Contact__c = c1.Id;
        s1.Contact_Type__c = 'Broker';
        s1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        s1.Related_Location_Broker_Office__c = a1.Id;
        s1.Subscription_Type__c = 'Licensee';
        insert(s1);
        
        MRIS_Application__c application = new MRIS_Application__c();
        Apexpages.StandardController controller = new Apexpages.StandardController(application);
        MRISApplicationExtension2 page = new MRISApplicationExtension2(controller);

        page.getRealtor();
        page.getAssociations();
        page.getNonRealtor();
        page.getLicenseType();
                
        page.setRealtorSelection(page.getRealtorSelection());           
        page.setNonRealtorSelection(page.getNonRealtorSelection());
        page.setLicenseTypeSelection(page.getLicenseTypeSelection());
        page.setOfficeSecretaryNCSelection(page.getOfficeSecretaryNCSelection());
                
        page.setshowPDF(page.getshowPDF());
        page.getshowRealtor();
        page.getshortExpDate();
        page.getshowSecretaryQuestion();
        page.getshowPersonalAssistant();
        page.getshowRealEstate();
        page.getshowFooter();
                
        page.setApplication(page.getApplication());
        page.setSubscription();
        page.setRealtorSelection('Yes');
        page.setSubscription();
        //Set Shareholders
        page.selectedAssociation = 'TEST';
        page.setSubscription();
        page.selectedAssociation = 'TEST2';
        page.setSubscription();
        
        page.setRealtorSelection('No');
        page.setNonRealtorSelection('Realtor/Shareholder');
        page.setSubscription();
        page.setNonRealtorSelection('Licensed Real Estate Agent');
        page.setSubscription();
        page.setNonRealtorSelection('Licensee/Non Realtor');
        page.setSubscription();
        page.setNonRealtorSelection('Personal Assistant');
        page.setSubscription();
        page.setNonRealtorSelection('Office Secretary');
        page.setSubscription();
                
                
        page.BrokerCode = 'TEST0001'; //Valid Account Name
        page.LookupBrokerCode();
        page.setSubscription();
        page.BrokerCode = ''; //Empty
        page.LookupBrokerCode();
        page.BrokerCode = 'Invalid'; //Invalid Account Name
        page.LookupBrokerCode();
        page.BrokerCode = 'TEST0002'; //A Different Valid Account, Non Share Holder
        page.setSubscription();
                
        page.LookupAppraiserCode(); //null
        page.AppraiserCode = 'Invalid';
        page.getAppraiserName();
        page.LookupAppraiserCode(); //Invalid
        page.AppraiserCode = '123456789';
        page.LookupAppraiserCode(); //Valid
        page.setAppraiserName(page.getAppraiserName());
                
        application.First_Name__c = 'Justin';
        application.Last_Name__c = 'Padilla';
        application.Primary_Phone__c = '443-739-0628';
        application.Mobile_Phone__c = '443-739-0628';
        application.Public_Email__c = 'jpadilla@rainmaker-llc.com';

        page.BrokerCode = 'TEST0001';
        page.LookupBrokerCode();

        page.Save();
        //Now set all months
        page.setRealtorSelection('Yes');
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
        //Set Year and Association
        app.Date_Expires_Year__c = '2013';
        page.getshortExpDate();
        page.setApplication(app);
        page.selectedAssociation = 'TEST2';     
        page.Save();            
        page.Print();
        app = page.getApplication();
        //Test PDF Version
        Apexpages.StandardController controller2 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
        MRISApplicationExtension2 page2 = new MRISApplicationExtension2(controller2);
        
        app.Subscription_Type__c = 'Office Secretary';
        update(app);
        Apexpages.StandardController controller3 = new Apexpages.StandardController(app);
        Apexpages.currentPage().getParameters().put('id',app.Id);
        MRISApplicationExtension2 page3 = new MRISApplicationExtension2(controller3);
        MRISApplicationExtension2.SortOptionList(new list<selectOption>{new selectoption('Abc','Account'),new selectoption('Abc1','Account1')});
        Test.stopTest();
    }
}