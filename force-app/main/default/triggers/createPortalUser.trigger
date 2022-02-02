trigger createPortalUser on Subscriptions__c (after update) 
{
//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

    System.debug('Started createPortalUser trigger.');
    Map<Id,Id> userPermissionMap = new Map<Id,Id>();
    PermissionSet community_access = [select Id, Name from PermissionSet where Name = 'Community_Access' limit 1];

    for(Subscriptions__c s : Trigger.new)   {
        Boolean createUser = false;
        String agentKey;        
        if(s.AgentKey__c != null && s.Primary__c){
            createUser = true;
            agentKey = s.AgentKey__c;
        }
        else if(s.BRIGHT_Agent_Key__c != null && s.Primary__c){
            createUser = true;
            agentKey = s.BRIGHT_Agent_Key__c;       
        }
        if(createUser){
            String primnum = '' + s.PrimarySubNum__c;
            //if there already exists a user with this contact, just update. no new user.
            Contact c = [SELECT LastName, FirstName, accountid FROM Contact WHERE id =: s.Contact__c LIMIT 1];
            system.debug('Contact: ' + c);
            try {
                User  u = [select id,username,federationidentifier from User where contactID = :s.Contact__c LIMIT 1];
                u.FederationIdentifier = primnum;
                update u;
            } catch (Queryexception ex) {
                User u = new User();
                u.username = agentKey + s.Public_Email__c;
                u.email = s.Public_Email__c;
                u.TimeZoneSidKey = 'America/New_York';
                u.LocaleSidKey='en_us';
                u.EmailEncodingKey='UTF-8';       
                u.LanguageLocaleKey='en_us'; 
                u.LastName = c.LastName;
                u.FirstName = c.FirstName;
                u.FederationIdentifier = primnum;
                //Alias is up to 8 char only
                u.Alias = (s.Name.length() > 7) ? s.Name.substring(0, 7) : s.Name; 
                u.ContactId = s.Contact__c;
                u.isActive = true;
                u.CommunityNickname = s.Name;
                Profile p = [SELECT id FROM Profile WHERE name =: 'MRIS Customer Community Login'];
                
                //s.adderror('profile id: ' + p.id);            
                u.Profile = p;
                u.ProfileId = p.id;
                insert(u);
                u = [select Id, Username from User where Username =: u.Username limit 1];
                
                //grant community access
                userPermissionMap.put(u.Id, community_access.Id);
              }
        }
    }
    if(userPermissionMap.size() > 0) {
        CommunityUser.AssignCommunityPermission(userPermissionMap);
    }
}