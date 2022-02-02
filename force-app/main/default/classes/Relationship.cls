/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* Global class for relationship
**/
global with sharing class Relationship {
	
	global String id { get; set; }
	global String RelationshipType { get; set; }
	global String RelationshipName { get; set; }
	global String SFAssociationId { get; set; }
	global String SFAccountID { get; set; }
	global String RelatedSFAccountID { get; set; }
	global String Primary { get; set; }
	global String SFSubscriptionID { get; set; }
	global String RelatedSFSubscriptionID { get; set; }
	global String notes { get; set; }
	global String RelationshipStartDateTime { get; set; }
	global String message { get; set; }

}