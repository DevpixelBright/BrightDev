public with sharing class AccountAssociations 
{
    public List<AccountAssociationsList> associationsList {get;set;}
    public string associationId {get;set;}
    public Related_Association__c association {get;set;}
    public Account mainAccount {get;set;}
    public Id recordId;
    public Boolean showTable {get;set;}
   
    public AccountAssociations(ApexPages.StandardController controller) 
    {
       recordId = Apexpages.currentpage().getparameters().get('id');
       Id aid = Apexpages.currentpage().getparameters().get('bid');
       associationsList = new List<AccountAssociationsList>();
       association = new Related_Association__c();
       mainAccount = new Account();
       associationList(); 
       try
       {
           association = [select id,name,Association__c,Association_Name__c,Start_Date__c,End_Date__c, 
                    Broker_Code__c, Notes__c, Primary__c,SysPrRoleKey__c,Status__c,MDS_Status__c,Owner.Name
                    from Related_Association__c where id = :recordId];
       }
       catch(Exception e)
       {
           association.Broker_Code__c = aid;
       }
        
    }
    
    public void associationList()
    {
       associationsList.clear();  
       showTable = false;
       for(Related_Association__c ra :[select id,name,Association__c,Association_Name__c,Primary__c,Start_Date__c,End_Date__c from Related_Association__c where Broker_Code__c = :recordId and Subscription__c = null])
       {
           AccountAssociationsList a = new AccountAssociationsList();
           a.relatedAssociation = ra;
           system.debug('*** List Association ID : ' + ra.id);
           a.editValue = 'Edit';
           a.deleteValue = 'Del';  
           associationsList.add(a);
       }  
       if(associationsList.size()>0)
           showTable = true; 
    }
    
    public Pagereference editAssociation()
    {
        system.debug('*** Edit Association ID : ' + associationId);
        Pagereference p = new Pagereference('/apex/EditAssociation?id=' + associationId); 
        p.setRedirect(true);
        return p;          
    }
    
    public void deleteAssociation()
    {
        system.debug('*** Delete Association ID : ' + associationId);
        association = [select id,name from Related_Association__c where id = :associationId];
        delete association ;
        associationList();        
    }
    
    public Pagereference saveEdit()
    {
        system.debug('*** Save Association ID : ' + associationId);
        upsert association ;
        Pagereference p = new Pagereference('/'+association.Broker_Code__c);
        return p;
    }
    
    public Pagereference cancelEdit()
    {
        Pagereference p = new Pagereference('/'+association.Broker_Code__c);
        return p;
    }
    
    public Pagereference addAssociation()
    {
        Pagereference p = new Pagereference('/apex/AddAssociation?bid=' + recordId); 
        return p;    
    }
    
    public class AccountAssociationsList
    {
        public Related_Association__c relatedAssociation {get;set;}
        public String editValue {get;set;}
        public String deleteValue {get;set;}
    }

}