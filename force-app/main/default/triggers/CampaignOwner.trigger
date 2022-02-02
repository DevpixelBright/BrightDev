trigger CampaignOwner on Feedback__c (before insert) {
   for( Feedback__c fb : trigger.new ) {
     if(fb.Campaign_Owner_Id__c !=null){ fb.ownerId=fb.Campaign_Owner_Id__c; }  
   }
}