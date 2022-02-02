({
    doInit : function(component, event, helper) {
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("id");
        console.log('--subId--'+subId);
        component.set("v.subscriptionId", subId);
        helper.fineData(component);
    },
    print : function(component, event, helper) {
        window.open('/customers/apex/Communities_OfficeAccuracy_Print?id='+component.get("v.subscriptionId"));
    },
    export : function(component,event,helper){
        
        var fineData = component.get("v.complianceFines");
        var csv = helper.convertArrayOfObjectsToCSV(component,fineData);  
        if (csv == null){return;}
        
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
        hiddenElement.target = '_self';
        hiddenElement.download = 'Brokerage Accuracy Notifications.csv';  
        document.body.appendChild(hiddenElement); 
        hiddenElement.click(); 
    },
    sortByField : function(component, event, helper) {
        component.set('v.currentPage', 1);
        var fieldAPI = event.currentTarget.dataset.fld;
        helper.sortHelper(component, fieldAPI);
    },
    search : function(component, event, helper) {
        component.set('v.currentPage', 1);
        helper.pageViolations(component);
    },
    handleOfficeFilter : function(component, event, helper) {
        component.set('v.currentPage', 1);
        helper.pageViolations(component);
    },
    toggleOldfines : function(component, event, helper) {
        var toggleId = event.currentTarget.dataset.value;
        var allboxs = component.find("toggleBox");
        if(Array.isArray(allboxs))
        {
            allboxs.forEach(function(eachBox){
                if(eachBox.get("v.name") == toggleId)
                {
                    eachBox.set("v.checked",!eachBox.get("v.checked"));
                }
            });
        }else{
            allboxs.set("v.checked",!allboxs.get("v.checked"));
        }   
        helper.pageViolations(component);
    },
    lastPage : function(component, event, helper){
        var pagination = component.get('v.pagination');
        component.set('v.currentPage',pagination);
        helper.pageViolations(component);
    },
    
    firstPage : function(component, event, helper){
        component.set('v.currentPage', 1);
        helper.pageViolations(component);
    },
    
    previousPage : function(component, event, helper){
        if(component.get('v.currentPage') >1){
            component.set('v.currentPage', component.get('v.currentPage') - 1);
        }
        helper.pageViolations(component);
    },
    
    nextPage : function(component, event, helper){
        if(component.get('v.currentPage') < component.get('v.pagination')){
            component.set('v.currentPage', component.get('v.currentPage') + 1);
        }
        helper.pageViolations(component);
    },
    
    getPage : function(component, event, helper){
        var ctarget = event.currentTarget; 
        var offset = ctarget.dataset.offset;
        component.set('v.currentPage', parseInt(offset));
        helper.pageViolations(component);
    },
    handlePageSize : function(component, event, helper){
        var pageSize = event.getSource().get("v.value");
        component.set('v.currentPage', 1);
        component.set('v.recordsPerPage', parseInt(pageSize));
        helper.pageViolations(component);
    },
    
})