public class MdsRoles {

   /*
    * return Cornerstone roles (in Salesforce object) for given agentkey
    */
   public static List<Subscription_Role__c> rolesByAgentKey(String agentKey) {
       String rsp = MdsDigestQuery.mdsDigestQuery('/services/rest/Agent/' + agentKey + '?View=AGENT_PARTY_ROLES');
       return MdsRoles.parseMDSroles(rsp);
   }

   /*
    * return Cornerstone roles (in Salesforce object) for given officekey
    */
   public static List<Subscription_Role__c> rolesByOfficeKey(String ofcKey) {
       String rsp = MdsDigestQuery.mdsDigestQuery('/services/rest/Office/' + ofcKey + '?View=OFFICE_PARTY_ROLES');
       return MdsRoles.parseMDSroles(rsp);
   }

   /*
    * return Cornerstone roles (in Salesforce object) for given subid
    */
   public static List<Subscription_Role__c> rolesBySubId(String subId) {
      Subscriptions__c sub = 
         [ select name, AgentKey__c from Subscriptions__c where id = :subId ];
      return rolesByAgentKey(sub.AgentKey__c);
   }

   /*
    * parse the MDS roles XML into list of Salesforce Roles objects (Subscription_Role__c)
    */
   public static List<Subscription_Role__c> parseMDSroles(String mdsXML) {
      List<Subscription_Role__c> sr = new List<Subscription_Role__c>();
      XmlStreamReader reader = new XmlStreamReader(mdsXML);

      while(reader.hasNext()) {
         if(reader.getEventType() == XmlTag.START_ELEMENT &&
            reader.getLocalName() == 'PartyRole') {
            Subscription_Role__c sr1 = parse1Role(reader);
            sr.add(sr1);
         }
         reader.next();
      }
      return sr;
   }

   /*
    * parse a single MDS PartyRole XML element 
    * into one Salesforce Role object (Subscription_Role__c)
    */
   public static Subscription_Role__c parse1Role(XmlStreamReader reader) {
      Subscription_Role__c sr1 = new Subscription_Role__c();
      sr1.Notes__c = 'Cornerstone Sync: ' + 
         datetime.now().format('MM/dd/yyyy HH:mm:ss', 'America/New_York');

      while(reader.hasNext()) {
         if(reader.getEventType() == XmlTag.START_ELEMENT) {
            if (reader.getLocalName() == 'SysPrKey') {
               sr1.SysPrRoleKey__c = getTxt(reader);
            } else if(reader.getLocalName() == 'SysPrRoleID') {
               sr1.Subscription__c = sub2sfid(getTxt(reader));
            } else if(reader.getLocalName() == 'SysPrRoleName') {
               sr1.Role__c =  getTxt(reader);
            } else if(reader.getLocalName() == 'SysPrStartDate') {
               sr1.Role_Start_Date__c = mds2sfDt(getTxt(reader));
            } else if(reader.getLocalName() == 'SysPrEndDate') {
               sr1.Role_End_Date__c = mds2sfDt(getTxt(reader));
            } else if(reader.getLocalName() == 'SysPrCurrent') {
              sr1.Status__c = (getTxt(reader) == '1') ? 'Active' : 'Inactive';
            }
         } else if(reader.getEventType() == XmlTag.END_ELEMENT &&
                   reader.getLocalName() == 'PartyRole') {
            return sr1;
         }
         reader.next();
      }
      sr1.MDS_Status__c = 'Success';
      return sr1;
   }

   public static String getTxt(XmlStreamReader reader) {
      String txt = '';
      reader.next();
      if (reader.getEventType() == XmlTag.CHARACTERS) {
         txt = reader.getText();
      }
      return txt;
   }

   /*
    * convert mds date string to salesforce datetime object
    */
   public static Date mds2sfDt(String dt) {
      if(dt.length() < 10) {
         return null;
      } else {
         return Date.newInstance(
            integer.valueof(dt.substring(0,4)),
            integer.valueof(dt.substring(5,7)),
            integer.valueof(dt.substring(8,10)));
      }
   }
   
   /*
    * convert subid to salesforce id
    */
   public static String sub2sfid(String subId) {      
      if(String.isEmpty(subId) || Pattern.matches('.*,.*',subId)) return null;  // subs null for office role
      Subscriptions__c sub = [ select name from Subscriptions__c where name = :subId ];
      return sub.id;
   }
}