({
	init : function(cmp, event, helper) {
		var action = cmp.get("c.fetchAccountData");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.data", response.getReturnValue());
                //this.filterData(cmp);
                cmp.find("accountTable").refreshTable();
            }
        });
        $A.enqueueAction(action);
        
        cmp.set('v.columns', [
            { label: 'Name', fieldName: 'Name', type: 'clickable', sortable : true, searchable : true, filter : false },
            { label: 'Type', fieldName: 'Type', type: 'text', sortable : true, searchable : true, filter : true },
            { label: 'Phone', fieldName: 'Phone', type: 'text', sortable : true, searchable : true },
            { label: 'Date Joined', fieldName: 'Date_Joined__c', type: 'text', sortable : true, searchable : true },
            { label: 'Status', fieldName: 'Status__c', type: 'text', sortable : true, searchable : true, filter : true }
        ]);
	}
})