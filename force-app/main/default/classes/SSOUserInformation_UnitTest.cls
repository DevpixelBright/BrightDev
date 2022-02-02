@isTest
public class SSOUserInformation_UnitTest {
	public static testmethod void GetActivePortalUser()
	{
		TestDataFactory test = new TestDataFactory();
		test.DisableValidationRules();
		
		Account a = test.MakeBrokerOfficeAccount();
		insert a;
		Contact c = test.MakeContact(a);
		insert c;
		Subscriptions__c s = test.MakePrimarySubscription(c);
		insert s;
		update c;  // to populate the primary sub field
		User u = test.MakePortalUser(c);
		insert u;
		String subscriberId = s.Name;
		
		System.Test.startTest();
		
		RestContext.response = new RestResponse();
		RestContext.request = new RestRequest();
		RestContext.request.requestURI = '/GetSSOUserInformation/' + s.Name;
		RestContext.request.httpMethod = 'GET';
		
		SSOUserInformation.UserSSODetails details = SSOUserInformation.doGet();

		System.Test.stopTest();
		
		// we can't actually do any asserts because the members of the UserSSODetails structure are not public		
	}
	
	public static testmethod void GetInactivePortalUser()
	{
		TestDataFactory test = new TestDataFactory();
		test.DisableValidationRules();
		
		Account a = test.MakeBrokerOfficeAccount();
		insert a;
		Contact c = test.MakeContact(a);
		insert c;
		Subscriptions__c s = test.MakePrimarySubscription(c);
		insert s;
		update c;  // to populate the primary sub field
		User u = test.MakePortalUser(c);
		u.IsActive = false;
		insert u;
		String subscriberId = s.Name;
		
		System.Test.startTest();
		
		RestContext.response = new RestResponse();
		RestContext.request = new RestRequest();
		RestContext.request.requestURI = '/GetSSOUserInformation/' + s.Name;
		RestContext.request.httpMethod = 'GET';
		
		SSOUserInformation.UserSSODetails details = SSOUserInformation.doGet();

		System.Test.stopTest();
		
		// we can't actually do any asserts because the members of the UserSSODetails structure are not public		
	}
	
	public static testmethod void GetUserNoSubscription()
	{
		TestDataFactory test = new TestDataFactory();
		test.DisableValidationRules();

		System.Test.startTest();
		
		RestContext.response = new RestResponse();
		RestContext.request = new RestRequest();
		RestContext.request.requestURI = '/GetSSOUserInformation/123456';
		RestContext.request.httpMethod = 'GET';
		
		SSOUserInformation.UserSSODetails details = SSOUserInformation.doGet();

		System.Test.stopTest();
		
		// we can't actually do any asserts because the members of the UserSSODetails structure are not public
	}
}