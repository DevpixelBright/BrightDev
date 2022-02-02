public class RETSUB {
    public void RETSUB1(String n){
       RETS_Product_Order__c r = [Select Start_Date__c from RETS_Product_Order__c where Agent__c = :n order by Start_Date__c DESC LIMIT 1];
       system.debug('test'+r);
       RETS_Product_Order__c re = [Select End_Date__c from RETS_Product_Order__c where Agent__c = :n AND Status_Reason__c !='Misreported' and End_Date__c != Null order by End_Date__c DESC LIMIT 1];
       system.debug('test2' +re);
       datetime dt;
       if(r.Start_Date__c > re.End_Date__c )
           dt=r.Start_Date__c;
       else
          dt= re.End_Date__c ;
          system.debug('dt=========='+dt);   
      }
      }