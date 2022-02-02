/**
*
*
**/
public with sharing class SFQPFailuresProcessingUtility {
	
	public static void processQPMessages(List<SFQPConnector__c> qpMessageList) {
		Set<SFQPConnector__c> failedMessages = new Set<SFQPConnector__c>();
		Set<SFQPConnector__c> failedAccounts = new Set<SFQPConnector__c>();
		Set<SFQPConnector__c> failedSubs = new Set<SFQPConnector__c>();
		Set<SFQPConnector__c> failedSubRoles = new Set<SFQPConnector__c>();
		Set<SFQPConnector__c> failedRels = new Set<SFQPConnector__c>();
		Set<SFQPConnector__c> failedRelAssociations = new Set<SFQPConnector__c>();
		Set <Id> failedAccountIDs = new Set<Id>();
		Set <Id> failedSubscriptionIDs = new Set<Id>();
		Set <Id> failedSubscriptionRolesIDs = new Set<Id>();
		Set <Id> failedRelationshipIDs = new Set<Id>();
		Set <Id> failedRelationshipAssociationIDs = new Set<Id>();
		
		for (SFQPConnector__c sfqp : qpMessageList) {
			
			System.debug('sfqp.ObjectType__c-----> ' + sfqp.ObjectType__c);
			System.debug('sfqp.QPStatus__c-----> ' + sfqp.QPStatus__c);
			//If Failed process the message
			
			if ((sfqp.ObjectType__c != null) && (('Failed-SFQP'.equals(sfqp.QPStatus__c)) || ('Failed-Sent'.equals(sfqp.QPStatus__c)) 
					|| 'Failed'.equals(sfqp.QPStatus__c))) {
				failedMessages.add(sfqp);
                if (sfqp.ObjectType__c != null) {
					if(sfqp.ObjectType__c.Contains('Account')) {
						failedAccounts.add(sfqp);
					}  else if ('Relationship__c'.equals(sfqp.ObjectType__c)) {
						failedRels.add(sfqp);
					}  else if ('Subscription'.equals(sfqp.ObjectType__c)) {
						failedSubs.add(sfqp);
					}  else if ('Subscription_Role__c'.equals(sfqp.ObjectType__c)) {
						failedSubRoles.add(sfqp);
					} else if ('Related_Association__c'.equals(sfqp.ObjectType__c)) {
						failedRelAssociations.add(sfqp);
					}
            	}
			} //End of If condition
		} //End of For-loop
		
		System.debug('failedAccounts----> ' + failedAccounts);
		System.debug('failedSubRoles----> ' + failedSubRoles);
		System.debug('failedRelAssociations----> ' + failedRelAssociations);
		System.debug('failedSubs----> ' + failedSubs);
		System.debug('failedRels----> ' + failedRels);
		//Once the failed message structures are filled, update the statuses of the individual records to MDS status failed
		for (SFQPConnector__c sfqp : failedAccounts) {
			failedAccountIDs.add(sfqp.relatedid__c);
		}
		if (failedAccountIDs.size() > 0) {
			List<Account> aList = [Select id, MDS_Status__c, Status__c from Account where id in :failedAccountIDs];
			for (Account a: aList) {
				a.MDS_Status__c = 'Failed';
				a.Status__c = 'Incomplete';
			}
			upsert aList;
		}
		for (SFQPConnector__c sfqp : failedRels) {
			failedRelationshipIDs.add(sfqp.relatedid__c);
			
		}
		if (failedRelationshipIDs.size() > 0) {
			List<Relationship__c> rList = [Select id, MDS_Status__c, Status__c from Relationship__c where id in :failedRelationshipIDs];
			for (Relationship__c r: rList) {
				r.MDS_Status__c = 'Failed';
				r.Status__c = 'Incomplete';
			}
			upsert rList;
		}
		
		for (SFQPConnector__c sfqp : failedSubs) {
			failedSubscriptionIDs.add(sfqp.relatedid__c);
		}
		
		if (failedSubscriptionIDs.size() > 0) {
			List<Subscriptions__c> sList = [Select id, MDS_Status__c, Status__c from Subscriptions__c where id in :failedSubscriptionIDs];
			for (Subscriptions__c s: sList) {
				s.MDS_Status__c = 'Failed';
				s.Status__c = 'Incomplete';
			}
			upsert sList;
		}
		
		for (SFQPConnector__c sfqp : failedSubRoles) {
			failedSubscriptionRolesIDs.add(sfqp.relatedid__c);
		}
		
		if (failedSubscriptionRolesIDs.size() > 0) {
			List<Subscription_Role__c> sList = [Select id, MDS_Status__c, Status__c from Subscription_Role__c where id in :failedSubscriptionRolesIDs];
			for (Subscription_Role__c s: sList) {
				s.MDS_Status__c = 'Failed';
			}
			upsert sList;
		}
		
		for (SFQPConnector__c sfqp : failedRelAssociations) {
			failedRelationshipAssociationIDs.add(sfqp.relatedid__c);
		}
		if (failedRelationshipAssociationIDs.size() > 0) {
			List<Related_Association__c> rList = [Select id, MDS_Status__c, Status__c from Related_Association__c where id in :failedRelationshipAssociationIDs];
			for (Related_Association__c s: rList) {
				s.MDS_Status__c = 'Failed';
				s.Status__c = 'Incomplete';
			}
			upsert rList;		
		}
		//Create Cases for the failed ones
		Map<String,List<SFQPConnector__c>> failedMessageMaps = new Map<String,List<SFQPConnector__c>>();
	    for (SFQPConnector__c sfqp : qpMessageList) {
	    	try {
	    		List<sObject> sObj = failedMessageMaps.get(sfqp.SFDC_Transaction_ID__c);
	    		if (sObj == null || sObj.size() == 0) {
	    			List<sObject> sObjList = new List<sObject>();
	    			sObjList.add(sfqp);
	    			failedMessageMaps.put(sfqp.SFDC_Transaction_ID__c,sObjList);
	    		}
	    	}	catch (Nullpointerexception npe) {
	    		List<sObject> sObjList = new List<sObject>();
	    		failedMessageMaps.put(sfqp.SFDC_Transaction_ID__c,sObjList);
	    	}
	    }
	    
	    //Check if the case has been created for any of the maps
		List<Case> createCaseList =  [select Id,Import_ID__c from Case where  Import_ID__c in :failedMessageMaps.keySet()];
		
		//If a case is created update that information
		//If a case is not created, create a case
	    QueueSobject processing;
	    try {
		     processing = [SELECT
	                QueueSobject.Id,
	                QueueSobject.SobjectType,
	                QueueSobject.QueueId
	                FROM QueueSobject
	                WHERE QueueSobject.SobjectType = 'Case'
	                AND QueueSobject.Queue.Name = 'Level 3' LIMIT 1];
	    } catch (Queryexception ex) {
	    	
	    }
	    
	    QueueSobject processingAMS = [SELECT
	                QueueSobject.Id,
	                QueueSobject.SobjectType,
	                QueueSobject.QueueId
	                FROM QueueSobject
	                WHERE QueueSobject.SobjectType = 'Case'
	                AND QueueSobject.Queue.Name = 'AMS' LIMIT 1];
	    for (String s: failedMessageMaps.keySet()) {
	    	List<SFQPConnector__c> sfqpList = failedMessageMaps.get(s);
	    	for (SFQPConnector__c sfqp : sfqpList) {
	    		 
	    		if  ((sfqp.ObjectType__c != null) && (('Failed-SFQP'.equals(sfqp.QPStatus__c)) || ('Failed-Sent'.equals(sfqp.QPStatus__c)) 
					|| 'Failed'.equals(sfqp.QPStatus__c))) {
			    	try {
			    		Case c = [select Id,Subscription_ID__c,AccountId,Import_ID__c,description from Case where  Import_ID__c = :s limit 1];
			    		c.description += '------------------' + '\n' + sfqp.ObjectType__c + '\n' +
			    			 'id = ' + sfqp.relatedid__c + '\n' + sfqp.QPMessage__c  + '\n';
			    		if (sfqp.ObjectType__c != null &&'Subscription'.equals(sfqp.ObjectType__c)) {
			    				c.Subscription_ID__c = sfqp.relatedid__c;
			    		}
			    		if (sfqp.ObjectType__c != null && sfqp.ObjectType__c.contains('Account')) {
			    			c.AccountId = sfqp.relatedid__c;
			    		}
			    		if (sfqp.ObjectType__c != null && 'Subscription_Role__c'.equals(sfqp.ObjectType__c)) {
                        	try {
                        	 Subscription_Role__c src=	[select Subscription__c from Subscription_Role__c where id = :sfqp.relatedid__c limit  1];
                        	 c.Subscription_ID__c = src.Subscription__c;
                        	} catch (QueryException e) {
                        		
                        	}
                        }
                        update c;
			    	} catch (Queryexception ex) {
			    		Case c = new Case();
			    		if  ((sfqp.ObjectType__c != null) && (('Failed-SFQP'.equals(sfqp.QPStatus__c)) || 
			    		('Failed-Sent'.equals(sfqp.QPStatus__c)))) {
			    			c.Origin = 'Integration Error';
			    			c.OwnerId = processingAMS.QueueId;
			    		} else {
			    			c.Origin = 'SalesForceErrors@MRIS.net';
			    			c.OwnerId = processing.QueueId;
			    		}
			    		
			    		if  ((sfqp.ObjectType__c != null) && ('Failed-Sent'.equals(sfqp.QPStatus__c))) {
			    			c.Subject = 'SFQP Status is \'Sent\' and not updated from QueueProcessor.';
			    		} else {
			    			c.Subject = 'SFQP Status is \'Failed\'.';	
			    		}
			    		
			    		c.Import_ID__c = s;
			    		if ((sfqp.ObjectType__c != null) && ('Subscription'.equals(sfqp.ObjectType__c))) {
			    				c.Subscription_ID__c = sfqp.relatedid__c;
			    		}
                        if (sfqp.ObjectType__c != null && sfqp.ObjectType__c.contains('Account')) {
                            c.AccountId = sfqp.relatedid__c;
                        }
                        if (sfqp.ObjectType__c!= null && 'Subscription_Role__c'.equals(sfqp.ObjectType__c)) {
                        	try {
                        	 Subscription_Role__c src=	[select Subscription__c from Subscription_Role__c where id = :sfqp.relatedid__c limit  1];
                        	 c.Subscription_ID__c = src.Subscription__c;
                        	} catch (QueryException e) {
                        		
                        	}
                        }
                        
		    			c.Description = '------------------' + '\n' + sfqp.ObjectType__c + '\n' +
		    			 'id = ' + sfqp.relatedid__c + '\n' + sfqp.QPMessage__c  + '\n';
			    		insert c;
			    	}
	    		}
		    	
	    	}
	    	
	    }
	    
	}
	
	
	
	
	
	
}