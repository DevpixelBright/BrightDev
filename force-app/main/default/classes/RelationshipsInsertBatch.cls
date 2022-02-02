public class RelationshipsInsertBatch implements Database.Batchable<Relationship__c>, Database.Stateful {
    List<Relationship__c> relationshipInsert = new List<Relationship__c>();
    Subscription_License__c subscriber; 
    String BORName; 
    Boolean isEdit;
    String errorMessage;
    List<Communities_ResponsibleBroker.officeRecord> lOffice = new List<Communities_ResponsibleBroker.officeRecord>();
    
    public RelationshipsInsertBatch (List<Relationship__c> relationshipInsert,
                                     Subscription_License__c subscriber, 
                                     String BORName, Boolean isEdit,
                                     List<Communities_ResponsibleBroker.officeRecord> lOffice){
                                         this.relationshipInsert = relationshipInsert;
                                         this.subscriber = subscriber;
                                         this.BORName = BORName;
                                         this.isEdit = isEdit;
                                         this.lOffice = lOffice;
                                     }
    public List<Relationship__c> start (Database.BatchableContext bc ) {
        // collect the batches of records or objects to be passed to execute\
        return relationshipInsert;
    }
    public void execute(Database.BatchableContext bc, List<Relationship__c> lRelationship){
        try{
            upsert lRelationship;
            Database.executeBatch(new RelationshipsInsertBatch(lRelationship,subscriber,BORname, isEdit,lOffice),2);
        }catch(DMLException ex){
            errorMessage = 'Only one Responsible Broker can be assigned per state.';
        }
        
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        Communities_ResponsibleBroker resp = new Communities_ResponsibleBroker();
        resp.lOffice = lOffice;
        resp.sendEmailToResponsibleBroker(relationshipInsert,subscriber,BORname, isEdit);
    }
}