({
    doInit : function(component, event, helper) {
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("id");
        console.log('--subId--'+subId);
        component.set("v.subscriptionId", subId);
        helper.loadData(component);
        
    },
    print : function(component, event, helper) {
        window.open('Communities_OfficeExclusive_Print?id='+component.get("v.subscriptionId"));
    },
    sortByField : function(component, event, helper) {
        component.set('v.currentPage', 1);
        var fieldAPI = event.currentTarget.dataset.fld;
        helper.sortHelper(component, fieldAPI);
    },
    export : function(component,event,helper){
        
        var fineData = component.get("v.officeExclusive");
        var csv = helper.convertArrayOfObjectsToCSV(component,fineData);  
        if (csv == null){return;}
        
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'ExportData.csv';  
        document.body.appendChild(hiddenElement); 
        hiddenElement.click(); 
    },
    search : function(component, event, helper) {
        component.set('v.currentPage', 1);
        helper.pageExclusiveOffices(component);
    },
    handleOfficeFilter : function(component, event, helper) {
        component.set('v.currentPage', 1);
        helper.pageExclusiveOffices(component);
    },
    lastPage : function(component, event, helper){
        var pagination = component.get('v.pagination');
        component.set('v.currentPage',pagination);
        helper.pageExclusiveOffices(component);
    },
    
    firstPage : function(component, event, helper){
        component.set('v.currentPage', 1);
        helper.pageExclusiveOffices(component);
    },
    
    previousPage : function(component, event, helper){
        if(component.get('v.currentPage') >1){
            component.set('v.currentPage', component.get('v.currentPage') - 1);
        }
        helper.pageExclusiveOffices(component);
    },
    
    nextPage : function(component, event, helper){
        if(component.get('v.currentPage') < component.get('v.pagination')){
            component.set('v.currentPage', component.get('v.currentPage') + 1);
        }
        helper.pageExclusiveOffices(component);
    },
    
    getPage : function(component, event, helper){
        var ctarget = event.currentTarget; 
        var offset = ctarget.dataset.offset;
        component.set('v.currentPage', parseInt(offset));
        helper.pageExclusiveOffices(component);
    },
    handlePageSize : function(component, event, helper){
        var pageSize = event.getSource().get("v.value");
        component.set('v.currentPage', 1);
        component.set('v.recordsPerPage', parseInt(pageSize));
        helper.pageExclusiveOffices(component);
    },
    /*
    searchKeyChange: function(component, event) {
        var searchKey = component.find("searchKey").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            component.set("v.officeExclusive", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }  */ 
})