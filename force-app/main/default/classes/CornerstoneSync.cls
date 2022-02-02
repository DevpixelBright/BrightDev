public class CornerstoneSync {

   private final String subId;
   public String subName {get;set;}
   public List<CornerstoneSync.SRselect> RMatch {get;set;}
   public List<CornerstoneSync.SRselect> RLink {get;set;}
   public List<CornerstoneSync.SRselect> SFadd {get;set;}
   public List<CornerstoneSync.SRselect> CSadd {get;set;}

   public CornerstoneSync(ApexPages.StandardSetController controller) {
      subId = System.currentPageReference().getParameters().get('id');
   }

   public void loadPage() {
      loadSync();
   }

   public PageReference cancel() {
      PageReference pageRef = new PageReference('/' + subId);
      pageRef.setRedirect(true);
      return pageRef;
   }

   public PageReference submit() {
      PageReference pageRef = new PageReference('/' + subId);
      pageRef.setRedirect(true);
      processSync();
      return pageRef;
   }

   /*
    * extend Subscription_Role__c in affect -- for display
    */
   public class SRselect {
      public Subscription_Role__c sr {get;set;}
      public Boolean srSelected {get;set;}
      public String csStatus {get;set;}
      public String cssHeader {get;set;}
   }

   public void sAdd(List<CornerstoneSync.SRselect> sLst, Subscription_Role__c sr1, String css) {
      SRselect srs1 = new SRselect();
      srs1.sr = sr1;
      srs1.srSelected = true;
      srs1.csStatus = css;
     
      if(sLst.isEmpty()) {
         sLst.add(srs1);
      } else {
         sLst.add(0,srs1);
      }
   }
   public void sAdd(List<CornerstoneSync.SRselect> sLst, Subscription_Role__c sr1) {
      sAdd(sLst,sr1,'');
   }

   /* 
    * load roles using sync logic
    */
   //@Future(callout=true)
   public void loadSync() {
      Subscriptions__c sub = 
         [ select name, AgentKey__c, Subscription_type__c, Contact_Type__c, Related_Location_Broker_Office__c
           from Subscriptions__c where id = :subId];
      List<Subscription_Role__c> SFr =
         [ select Subscription__c, Role__c, Role_Start_Date__c, Role_End_Date__c, Status__c, MDS_Status__c, SysPrRoleKey__c
           from Subscription_Role__c where Subscription__c = :subId];
      Account ac = 
         [SELECT Id, OfficeKey__c, Type from Account where Id = :sub.Related_Location_Broker_Office__c];
      List<Subscription_Role__c> CSr = null;

      subName = sub.name;
      RMatch = new List<CornerstoneSync.SRselect>();
      RLink = new List<CornerstoneSync.SRselect>();
      SFadd = new List<CornerstoneSync.SRselect>();
      CSadd = new List<CornerstoneSync.SRselect>();
      
      if(MRISServiceAccountProcessingUtility.serviceType(sub.Subscription_type__c) || 
         MRISServiceAccountProcessingUtility.serviceType(ac.Type)) {
         System.debug('!!!!!!!!!RETS/MDS loadSync: '+subId);
         CSr = MdsRoles.rolesByOfficeKey(ac.OfficeKey__c);
         setSubs(CSr,sub);
      } else {
         CSr = MdsRoles.rolesByAgentKey(sub.AgentKey__c);
      }
      loadCornerstone(SFr,CSr);
      loadSalesforce(SFr,CSr);
   }

   /*
    * process the sync data
    */
   public void processSync() {
      // add selected roles to cornerstone
      for(CornerstoneSync.SRselect csr: CSadd) {
         if(csr.srSelected) {
            Map<Id,String> subscriptionRoleMap = new Map<Id,String>();
            subscriptionRoleMap.put(csr.sr.id, System.JSON.serialize(csr.sr));
           // SubscriptionRoleProcessingUtility.createSubscriptionRole(subscriptionRoleMap);
         }
      }

      executionFlowUtility.triggersOff();

      // add selected roles to salesforce
      for(CornerstoneSync.SRselect csr: SFadd) {
         if(csr.srSelected) {
            csr.sr.MDS_Status__c = 'Success';
            upsert(csr.sr);
         }
      }
      // link roles -- update SF role with CS key
      for(CornerstoneSync.SRselect csr: RLink) {
         if(csr.srSelected) {
            csr.sr.MDS_Status__c = 'Success';
            upsert(csr.sr);
         }
      }
      executionFlowUtility.triggersOn();
   }

   /*
    * determine roles missing from cornerstone
    */
   public void loadCornerstone(List<Subscription_Role__c> SFr,List<Subscription_Role__c> CSr) {
      for(Subscription_Role__c sr1: SFr) {
         Subscription_Role__c cs1 = findRole(sr1,CSr);
         if(sr1.Status__c == 'Active' && cs1 == null ) {
            sAdd(CSadd,sr1);
         } else if (sr1.Status__c == 'Active' && cs1 != null && cs1.Status__c == 'Inactive') {
            // ?update status?
         }
      }
   }

   /*
    * load Roles missing from Salesforce
    */
   public void loadSalesforce(List<Subscription_Role__c> SFr,List<Subscription_Role__c> CSr) {
      for(Subscription_Role__c cs1: CSr) {
         Subscription_Role__c sf1 = findRole(cs1,SFr);
         
         if(sf1 == null) {
            Subscription_Role__c lnk = linkRole(cs1);
            if(lnk == null && isRole(cs1.role__c)) {
//            System.debug('!!!!!!!!!adding CS Role to SF: '+cs1.role__c + ' - ' + 
//                         cs1.SysPrRoleKey__c + ' - ' + cs1.status__c + ' - ' + 
//                         cs1.Role_Start_Date__c + ' - ' + cs1.Role_End_Date__c);
               cs1.MDS_Status__c = 'Success';
               
               // in testing Cornerstone was missing some subids -- try to fix
               if(String.isEmpty(cs1.Subscription__c)) cs1.Subscription__c = subId;
               sAdd(SFadd,cs1);
            }
         } else if(isRole(cs1.role__c)) {
            sAdd(RMatch,sf1,cs1.status__c);
         }
      }
   }

   /*
    * link cs key to a matching role in cornerstone add list.
    * remove that role from the list and return it.
    */
   public Subscription_Role__c linkRole(Subscription_Role__c r1) {
      Subscription_Role__c lnk = null;
      List<CornerstoneSync.SRselect> CStmp = new List<CornerstoneSync.SRselect>();
      for(CornerstoneSync.SRselect s1: CSadd) {
         if(lnk == null && r1.Status__c == s1.sr.Status__c && 
            r1.role__c == s1.sr.role__c && r1.Role_Start_Date__c == s1.sr.Role_Start_Date__c) {
            s1.sr.SysPrRoleKey__c = r1.SysPrRoleKey__c;
            lnk = r1;

            RLink.add(s1);
         } else {
            CStmp.add(s1);
         }
      }
      CSadd = CStmp;
      return lnk;
   }
   
   /*
    * find and return the one role object from the given role rList
    * where the Cornerstone key (SysPrRoleKey__c) matches the given role r1
    */
   public static Subscription_Role__c findRole(Subscription_Role__c r1, List<Subscription_Role__c> rList) {
      if(rList != null) {
         for(Subscription_Role__c r2: rList) {
            if(r1.SysPrRoleKey__c == r2.SysPrRoleKey__c) {
               return r2;
            }
         }
      }
      return null;
   }
   
   /*
    * populate subids in subscriptionRole list
    */
   public static void setSubs(List<Subscription_Role__c> CSr, Subscriptions__c sub) {
      for(Subscription_Role__c cs1: CSr) {
         cs1.Subscription__c = sub.id;
      }
   }
   
   public static boolean isRole(String s) {
      Schema.DescribeFieldResult fieldResult = Subscription_Role__c.Role__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      
      for( Schema.PicklistEntry f : ple) {
         if(s == f.getValue()) return true;
      }
      if(s.equals('System-MRIS')) return true;
      return false;
   }
}