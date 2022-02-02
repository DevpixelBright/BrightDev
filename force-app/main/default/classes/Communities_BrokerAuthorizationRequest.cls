/**
Class		: Communities_BrokerAuthorizationRequest
Test Class	: Communities_BrokerAuthorizationReq_Test
VF page		: Communities_BrokerAuthorizationRequest
Createdby	: BLT India
*/
public class Communities_BrokerAuthorizationRequest {
    
    public MRIS_Application__c brightApplication{get;set;}
    public Subscriptions__c subscription { get; set; }
    public string VendorId{get;set;}
    public String subscriptionId { get; set; }
    public string Website {get;set;}
    public string selectedProdType {get; set;}
    public Boolean isSuccessMsg {get; set;}
    
    
    public list<selectoption> getProductType(){
        List<StaticResource> lStaticResource = [SELECT Id, Name, SystemModstamp FROM StaticResource where Name = 'BlueHelpIcon'];
        list<selectOption> prodList = new list<selectOption>();
        string resourceURL = '';
        if(!lStaticResource.isEmpty()){
         resourceURL = '/customers/resource/' + lStaticResource[0].SystemModstamp.getTime() + '/' + lStaticResource[0].Name;
        }
        String helptooltip = '<span class="Helptooltip tippoint">'
            + '<img src="' + resourceURL + '"/><div class="top" style="font-style:italic">'
            + '<span>Internet Data Exchange (IDX) affords MLS Brokers the ability to authorize limited electronic display and delivery of their listings by other Brokers via the following authorized mediums under the Broker’s control: websites, mobile apps, and audio devices.<a href="'+Label.IDX_List+'" target="_blank"> View a list of IDX/VOW vendors</a>.</span>'
            + '</div></span>';
        String helptooltip1 = '<span class="Helptooltip tippoint">'
            + '<img src="' + resourceURL + '"/><div class="top" style="font-style:italic">'
            + '<span>A Virtual Office Website (“VOW”) is a Broker’s Internet website, or a feature of a Broker’s website, through which the Broker is capable of providing real estate brokerage services to consumers with whom the Broker has first established a broker-consumer relationship (as defined by state law) and where the consumer has the opportunity to search MLS Listing Information.<a href="'+Label.IDX_List+'" target="_blank"> View a list of IDX/VOW vendors</a>.</span>'
            + '</div></span>';
        SelectOption so1 = new selectOption('IDX','IDX Website' + helptooltip);
        prodList.add(so1);
        so1.setEscapeItem(false);
        SelectOption so11 = new selectOption('VOW','VOW Website' + helptooltip1);
        prodList.add(so11);
        so11.setEscapeItem(false);
        //prodList.add(new selectOption('VOW','VOW Website' + helptooltip));
        selectedProdType = 'IDX';
        return prodList;
    }
    
    
    public Communities_BrokerAuthorizationRequest(){
        isSuccessMsg = false;
        brightApplication = new MRIS_Application__c();
        subscriptionId = Apexpages.currentPage().getParameters().get('id');
        system.debug('---subId--->' + subscriptionId);
        
        list<Subscriptions__c> subscriptionList = [SELECT Id, Name, Related_Location_Broker_Office__c, Private_Email__c, Contact__r.FirstName, 
                                                   Contact__r.LastName, Service_Jurisdiction__c, Website__c, Contact_Type__c
                                                   FROM Subscriptions__c 
                                                   WHERE Name = :subscriptionId And Status__c = 'Active' And Related_Location_Broker_Office__c != null];
        if(subscriptionList != null && !subscriptionList.isEmpty())
            subscription = subscriptionList[0];
        
    }
    
    public void saveRequestApplication(){
        
        try{
            MRIS_Application__c application = new MRIS_Application__c();
            
            system.debug('--vendor id----'+VendorId);
            application.Agent_Subscription_ID__c = subscription.Id;
            application.Vendor_Office_ID__c = VendorId;
            application.Website__c = Website;
            application.Authorized_Use__c = selectedProdType;
            Integer maxDays = (Integer)New_Agent_Approval_Days__c.getValues('Broker Authorization Request').No_Of_Days__c;
            application.Application_Expire_Date__c = System.now().AddDays(maxDays);
            application.Type__c = subscription.Contact_Type__c;
            application.Application_Type__c = 'IDX and VOW Agent Request';
            application.First_Name__c = subscription.contact__r.FirstName;
            application.Last_Name__c = subscription.contact__r.LastName;
            application.Private_Email__c = subscription.Private_Email__c;
            application.Service_Jurisdiction__c = subscription.Service_Jurisdiction__c;
            application.Company_Code__c = subscription.Related_Location_Broker_Office__c;
            application.Status__c = 'New'; 
            
            insert application;
            
            system.debug('---application--->' + application);
            
            
            isSuccessMsg = true;
        }
        catch(exception e){
            system.debug('exception while saving--->'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, e.getMessage()));
        }
        
    }
    
    @RemoteAction
    public static List<Account> getAccountDetails(String VendorNameSearch,string RadioBtnSelect) {
        System.debug('Vendor Name is: '+VendorNameSearch );
        string Vendorname = String.escapeSingleQuotes(VendorNameSearch) + '%';
        string RadioBtn = String.escapeSingleQuotes(RadioBtnSelect);
        List<Account> Accnt = [Select Id, Name, Account_Name__c 
                               From Account 
                               Where (Name like :Vendorname Or Account_Name__c like :Vendorname) AND RETS_Billing_Type__c  = 'Enterprise' And Status__c in ('Active') AND Authorized_Use__c INCLUDES (:RadioBtn) AND Type like 'Rets'];
        return Accnt;
    }
}