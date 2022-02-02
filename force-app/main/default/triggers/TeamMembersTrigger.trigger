Trigger TeamMembersTrigger on Team_Members__c (before insert, after insert, after update, before update) 
{
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        TeamMembersHandler.teamSubscription();
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
       TeamMembersHandler.updatedDateConversion();
    }
}