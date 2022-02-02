public class Communities_AgentListingInstructionsCls {
	
	public string subId {get; set;}
	public Subscriptions__c agentDetials {get; set;}
	public Communities_AgentListingInstructionsCls(){
		try{
			agentDetials = new Subscriptions__c();
			subId = Apexpages.currentPage().getParameters().get('Id');
			list<Subscriptions__c> lstsubs = [Select id, name, Contact__c, Contact__r.Name, Contact__r.phone, Contact__r.Email, Related_Location_Broker_Office__c, 
												Related_Location_Broker_Office__r.Name,
												Related_Location_Broker_Office__r.BillingStreet, 
												Related_Location_Broker_Office__r.BillingCity, Related_Location_Broker_Office__r.BillingState, 
												Related_Location_Broker_Office__r.BillingPostalCode, Related_Location_Broker_Office__r.BillingCountry 
												From Subscriptions__c 
												Where Name =: subId];
			if(lstsubs != null && !lstsubs.isEmpty())
				agentDetials = lstsubs[0];
		}
		catch(exception ex){
			throw new CustomException('Id in URL is not provided');
		}
	}
	
	
	public pagereference getStarted(){
		pagereference ref = new pagereference('/apex/AgentListings2?id='+subId);
		ref.setRedirect(true);
		return ref;
		
	}
    public class CustomException extends Exception {}
}