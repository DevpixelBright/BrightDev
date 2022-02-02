/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* This service will delete Relationship
**/
@RestResource(urlMapping='/DeleteRelationship/*')
global with sharing class DeleteRelationship {
	
	/**
	*  This method will create the relationships in salesforce
	*
	**/ 
	@HttpDelete
	global static void doDelete() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		
		String id = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		//validate relationship type
		RelationshipUtility.updateRelationship(id);
		return;
	
	}

}