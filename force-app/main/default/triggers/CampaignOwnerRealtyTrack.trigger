trigger CampaignOwnerRealtyTrack on MRIS_RealtyTrac_Survey__c (before insert, before update) {
   for( MRIS_RealtyTrac_Survey__c fb : trigger.new ) {
     if(fb.Campaign_Owner_Id__c !=null){ fb.ownerId=fb.Campaign_Owner_Id__c; }  
   }
   }