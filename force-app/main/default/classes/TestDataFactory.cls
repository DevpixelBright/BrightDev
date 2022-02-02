@isTest
public class TestDataFactory {

	// some of the existing code checks the custom setting incorrectly (e.g. explicitly by profile)
	// so it's better to set the org-wide default so it picks up everywhere
	public void DisableValidationRules()
	{
		Bypass_Validation_rules__c i = Bypass_Validation_rules__c.getInstance();
		if(!i.Disable_Validation_Rules__c) {
			try {
				Bypass_Validation_rules__c s = Bypass_Validation_rules__c.getOrgDefaults();
				s.Disable_Validation_Rules__c = true;
				upsert s;				
			}
			catch(DmlException ex) {
				throw ex;
			}
		}
	}
	
	public void TriggersOff()
	{
		DisableValidationRules();
	}
	
	public void TriggersOn()
	{
		Bypass_Validation_rules__c i = Bypass_Validation_rules__c.getInstance();
		if(i.Disable_Validation_Rules__c) {
			try {
				Bypass_Validation_rules__c s = Bypass_Validation_rules__c.getOrgDefaults();
				s.Disable_Validation_Rules__c = false;
				upsert s;				
			}
			catch(DmlException ex) {
				throw ex;
			}
		}
	}
	
	// this should fill in all the required fields
	public Account MakeBrokerOfficeAccount()
	{
		Account a = new Account();
		a.Name = 'XXX1';
		a.Account_Name__c = 'Test Account';
		a.Type = 'Residential';
		a.Company_Type__c = 'Broker Office';
		a.Phone = '(555) 123-4567';
		a.Status__c = 'Active';
		a.City__c = 'Washington';
		a.State__c = 'DC';
		a.Zip__c = '20009';
		return a;
	}
	
	public Contact MakeContact(Account office)
	{
		Contact c = new Contact();
		c.AccountId = office.Id;
        c.Salutation = 'Mr.';
        c.FirstName = 'Test';
        c.LastName = 'Nobody';
        c.Status__c = 'Active';
        c.Phone = office.Phone;
        c.MobilePhone = '(555) 123-4567';
        c.Public_Email__c = 'nobody@mris.net';
        c.Email = 'nobody@mris.net';
        c.City__c = office.City__c;
        c.State__c = office.State__c;
        c.Zip__c = office.Zip__c;
 		return c;
	}
	
	public Subscriptions__c MakeSubscription(Contact c)
	{
		Subscriptions__c s = new Subscriptions__c();
		// THIS IS PRETTY BAD, GOOD THING IT'S TEST CODE
		Set<String> ids = GetUnusedFederationIds(1);
		for(String id : ids)
		{
			s.Name = id;
			s.PrismSubscriptionID__c = id; // this will short-circuit the workflow rule that assigns an autonumber
		}
		s.Contact__c = c.Id;
		s.Subscription_Type__c = 'Agent';
		s.Contact_Type__c = 'Realtor/Shareholder';
		s.Related_Location_Broker_Office__c = c.AccountId;
		s.Status__c = 'Active';
		s.Public_Email__c = c.Public_Email__c;
		s.Private_Email__c = c.Email;
		s.Mobile_Phone__c = c.MobilePhone;
		s.City__c = c.City__c;
		s.State__c = c.State__c;
		s.Zip__c = c.Zip__c;
		s.Primary__c = true;
		return s;
	}
	
	public Subscriptions__c MakePrimarySubscription(Contact c)
	{
		Subscriptions__c s = MakeSubscription(c);
		c.Primary_Subscription_ID__c = s.Name;
		return s;
	}
	
	public Case MakeCase()
	{
		Case c = new Case();
		c.Origin = 'Email';
		return c;
	}
	
	public Case MakeCase(String recordType) {
		Case c = MakeCase();
		c.RecordTypeId = recordType;
		return c;
	}
	
	public User MakePortalUser(Contact c)
	{
		User u = new User();
        u.username = c.Primary_Subscription_ID__c + c.Email;
        u.email = c.Email;
        u.TimeZoneSidKey = 'America/New_York';
        u.LocaleSidKey='en_us';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_us'; 
        u.LastName = c.LastName;
        u.FirstName = c.FirstName;
        u.Alias = BuildAlias(c);
        u.FederationIdentifier = c.Primary_Subscription_ID__c;
        u.ContactId = c.Id;
        u.isActive = true;
        u.CommunityNickname = c.Name;
        Profile p = [SELECT id FROM Profile WHERE name =: 'Custom High Volume Portal User'];
        u.ProfileId = p.id;
        return u;
	}
	
	public String BuildAlias(Contact c)
	{
		return c.FirstName.left(1) + c.LastName.left(6);
	}
	
	public List<Account> CreateAccounts(Integer howMany)
	{
		List<Account> accounts = new List<Account>();
		while(accounts.size() < howMany)
		{
			accounts.add(MakeBrokerOfficeAccount());
		}
		return accounts;
	}
	
	public List<Contact> CreateContacts(Integer howMany, List<Account> accounts)
	{
		List<Contact> contacts = new List<Contact>();
		List<String> emails = new List<String>(GetRandomStrings(10, howMany*accounts.size()));
		
		for(Account a : accounts)
		{
			List<Contact> c = new List<Contact>();
			while(c.size() < howMany)
			{
				c.add(MakeContact(a));
			}
			contacts.addAll(c);
		}
		for(Integer i=0; i<contacts.size(); i++)
		{
			contacts[i].Email = emails[i] + '@mris.net';
			contacts[i].Public_Email__c = emails[i] + '@mris.net';
		}
		return contacts;
	}
	
	public List<Subscriptions__c> CreatePrimarySubscriptions(List<Contact> contacts)
	{
		List<Subscriptions__c> subs = new List<Subscriptions__c>();
		
		for(Contact c : contacts)
		{
			subs.add(MakeSubscription(c));
		}
		return subs;
	}
	
	public List<Case> CreateCases(Integer howMany)
	{
		List<Case> cases = new List<Case>();
		
		while(cases.size() < howMany)
		{
			cases.add(MakeCase());
		}
		return cases;
	}
	
	public List<Case> CreateCases(String recordType, Integer howMany) {
		List<Case> cases = new List<Case>();
		
		while(cases.size() < howMany)
		{
			cases.add(MakeCase(recordType));
		}
		return cases;
	}
	
	public List<Case> CreateCases(List<Contact> contacts, Integer howMany)
	{
		List<Case> cases = new List<Case>();
		
		for(Contact contact : contacts) 
		{
			for(Integer i=0; i<howMany; i++)
			{
				Case c = MakeCase();
				c.ContactId = contact.Id;
				cases.add(c);
			}
		}
		return cases;		
	}
	
	public String GetRandomString(Integer length)
	{
		String seed = '0123456789abcdefghijklmnopqrstuvwxyz';
		String s = '';
		
		while(s.length() < length)
		{
			s += seed.mid(Math.mod(Integer.valueOf(Math.roundToLong(Math.random()*10)),seed.length()),1);
		}
		
		return s;
	}
	
	public Set<String> GetRandomStrings(Integer length, Integer howMany)
	{
		Set<String> strings = new Set<String>();
		
		while(strings.size() < howMany)
		{
			strings.add(GetRandomString(length));
		}
		return strings;
	}
	
	public Set<String> GetUnusedFederationIds(Integer howMany)
	{
		// since user records are always visible to test code,
		// if we want to create test users we need to be able
		// to generate unique FederationIdentifier values.
		Set<String> ids = new Set<String>();
		
		while(ids.size() < howMany)
		{
			ids.add(String.valueOf(Math.roundToLong(Math.random()*100000)));
		}
		
		List<User> users = [select Id, FederationIdentifier from User where FederationIdentifier in :ids];

		while(!users.isEmpty())
		{
			for(User u : users)
			{
				ids.remove(u.FederationIdentifier);
			}
			while(ids.size() < howMany)
			{
				ids.add(String.valueOf(Math.roundToLong(Math.random()*100000)));
			}
			users = [select Id, FederationIdentifier from User where FederationIdentifier in :ids];
		}
		return ids;
	}
	
	public static testmethod void generateTestData()
	{
		TestDataFactory tdf = new TestDataFactory();
		
		tdf.DisableValidationRules();

		List<Account> a = tdf.CreateAccounts(5);
		System.assertEquals(5, a.size());
		insert a;
		
		List<Contact> c = tdf.CreateContacts(2, a);
		System.assertEquals(10, c.size());
		insert c;
		
		List<Subscriptions__c> s = tdf.CreatePrimarySubscriptions(c);
		System.assertEquals(10, s.size());
		insert s;
		
		List<Case> cases = tdf.CreateCases(5);
		System.assertEquals(5, cases.size());
		insert cases;
	}
	
	public static testmethod void generateRandomStrings()
	{
		TestDataFactory tdf = new TestDataFactory();
		
		Integer cnt = 10;
		Integer len = 10;
		Set<String> strings = new Set<String>();
		
		while(strings.size() < cnt)
		{
			strings.add(tdf.GetRandomString(len));
		}
		
		for(String s : strings)
		{
			System.debug(s);
		}
	}
	
	public static testmethod void generateUniqueFederationIds()
	{
		TestDataFactory tdf = new TestDataFactory();
		Integer cnt = 10;
		
		Set<String> ids = tdf.GetUnusedFederationIds(cnt);
		System.assertEquals(cnt, ids.size());
		
		List<User> users = [select Id, FederationIdentifier from User where FederationIdentifier in :ids];
		System.assertEquals(0, users.size());
	}
}