({
    doInit : function(component, event, helper) {
        var currentUrl = new URL(window.location);
        var subId = currentUrl.searchParams.get("id");
        console.log('--subId--'+subId);
        component.set("v.subscriptionId", subId);
        helper.fineData(component);
    },
    print : function(component, event, helper) {
        window.print();
    },
    export : function(component,event,helper){
        
        var fineData = component.get("v.complianceFines");
        var csv = helper.convertArrayOfObjectsToCSV(component,fineData);  
        if (csv == null){return;}
        
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'ExportData.csv';  
        document.body.appendChild(hiddenElement); 
        hiddenElement.click(); 
    },
    sortByField : function(component, event, helper) {
        var fieldAPI = event.currentTarget.dataset.fld;
        helper.sortHelper(component, fieldAPI);
    },
    search : function(component, event, helper) {
        helper.filterData(component);
    },
    handleOfficeFilter : function(component, event, helper) {
        component.set('v.complianceFinesDisplay', component.get('v.complianceFinesByOffice')[component.get('v.SelectedOffices')]);
    },
    toggleOldfines : function(component, event, helper) {
        var toggleId = event.currentTarget.dataset.value;
        var allboxs = component.find("toggleBox");
        if(Array.isArray(allboxs))
        {
            //alert("array");
            allboxs.forEach(function(eachBox){
                if(eachBox.get("v.name") == toggleId)
                {
                    eachBox.set("v.checked",!eachBox.get("v.checked"));
                }
            });
        }else{
            allboxs.set("v.checked",!allboxs.get("v.checked"));
        }                          
    }
    
})