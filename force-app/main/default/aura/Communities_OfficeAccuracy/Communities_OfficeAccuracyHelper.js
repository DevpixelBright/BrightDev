({
    fineData : function(component) {
        var action = component.get("c.getDetails");
        action.setParams({
            subId: component.get("v.subscriptionId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('----state--'+state);
            if (state === "SUCCESS") {
                var violations = response.getReturnValue();
                component.set('v.complianceFines', violations);
                component.set('v.complianceFinesDisplay', violations);
                component.set('v.currentPage', 1);
                this.populateOffice(component);
                this.pageViolations(component);
            }
        });
        $A.enqueueAction(action);   	
    },
    
    populateOffice : function(component) {
        var complianceFinesByOffice = this.groupBy(component.get('v.complianceFines'), "officeId",this);
        var items = [];
        var SelectedOffices = [];
        items.push({
            "label": "All Offices",
            "value": "All Offices",
            "selected" : true
        });
        SelectedOffices.push("All Offices");
        var officeIds = [];
        for(var offId in complianceFinesByOffice){
            officeIds.push(offId);
        }
        officeIds.sort();
        for(var i=0; i<officeIds.length; i++){
            items.push({
                "label": officeIds[i],
                "value": officeIds[i],
                "selected" : true
            });
            SelectedOffices.push(officeIds[i]);
        }
        complianceFinesByOffice["All Offices"] = component.get('v.complianceFines');
        component.set("v.complianceFinesByOffice", complianceFinesByOffice);
        component.set("v.offices", items); 
        
        component.set("v.SelectedOffices", SelectedOffices);
        component.find("officeFilter").refresh();
    },
    groupBy : function(xs, key, helper) {
        return xs.reduce(function(rv, x) {
            (rv[helper.fieldValue(x,key)] = rv[helper.fieldValue(x,key)] || []).push(x);
            return rv;
        }, {});   
    },
    
    sortHelper : function(component, field) {
        var helper = this;
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.complianceFines");
        sortAsc = field == sortField? !sortAsc: true;
        records.sort(function(a,b){
            var a_fld=helper.fieldValue(a,field);
            var b_fld=helper.fieldValue(b,field);
            var t1 = a_fld == b_fld;
            var t2 = a_fld > b_fld;
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.complianceFines", records);
        helper.pageViolations(component);
    },
    filterData : function(cmp) 
    {
        var allRecords = cmp.get("v.complianceFines");
        var searchFilter = cmp.get("v.searchKey");
        //console.log('---searchFilter--'+searchFilter);
        var searchTempArray = [];
        if(!cmp.get('v.SelectedOffices').includes("All Offices"))
        {
            allRecords = this.helperOfficeFilter(cmp, cmp.get('v.SelectedOffices'));
        }
        
        if(!searchFilter || searchFilter=='')
        {
            searchTempArray = allRecords;
        }else{
            searchFilter = searchFilter.toUpperCase();
            var i;
            for(i=0; i < allRecords.length; i++){
                if((allRecords[i].agent && allRecords[i].agent.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].subscriptionId && allRecords[i].subscriptionId.toUpperCase().indexOf(searchFilter) != -1 ) || 
                   (allRecords[i].mlsNumber && allRecords[i].mlsNumber.toUpperCase().indexOf(searchFilter) != -1 )  ||
                   (allRecords[i].violationType && allRecords[i].violationType.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].officeId && allRecords[i].officeId.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].violationNo && allRecords[i].violationNo.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].notificationType && allRecords[i].notificationType.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].notificationDateStr && allRecords[i].notificationDateStr.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].fineAmount && allRecords[i].fineAmount.toString().toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].lastDayToAppealStr && allRecords[i].lastDayToAppealStr.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].status && allRecords[i].status.toUpperCase().indexOf(searchFilter) != -1 ))
                {
                    searchTempArray.push(allRecords[i]);
                }
            }
        }
        //cmp.set("v.complianceFinesDisplay", searchTempArray);   
        return searchTempArray;
    },
    convertArrayOfObjectsToCSV : function(component, sObjectList){
        if (sObjectList == null || sObjectList.length == 0) {
            return null; //
        }
        // CSV file parameters.
        var columnEnd = ',';
        var lineEnd =  '\n';
        // Get the CSV header from the list.
        var keys = new Set();
        keys = Array.from(keys);
        keys = ['agent','subscriptionId','officeId','mlsNumber','violationType','violationNo','notificationType','notificationDate','fineAmount','status','lastDayToAppeal'];
        var childkeys = ['Subscription__r.Contact__r.Name','Subscription__r.Name','Subscription__r.Related_Location_Broker_Office__r.Name','MLS_Number__c','Violation__c','Violation_Number_Formatted__c','Notification_Type__c','Date_of_Fine__c','Fine_Amount__c','Status__c','Last_Date_to_Appeal__c'];
        var headers = ['Agent Name','Subscriber ID','Office ID','MLS#','Violation Type','Violation Number','Notification Type','Notification Date','Fine Amount','Status','Last Date to Appeal'];
        var csvString = '';
        csvString += headers.join(columnEnd);
        csvString += lineEnd;
        for(var i=0; i < sObjectList.length; i++){
            var counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;
                // add , after every value except the first.
                if(counter > 0){
                    csvString += columnEnd;
                }
                // If the column is undefined, leave it as blank in the CSV file.
                var value = this.fieldValue(sObjectList[i],skey);
                if(skey == "fineAmount")
                {
                    csvString += '"'+"$"+ value +'"';
                }else{
                    csvString += '"'+ value +'"';
                }
                counter++;
            }
            csvString += lineEnd;
            //Handle child violations
            if(sObjectList[i].childViolations.length>1)
            {
                for(var j=1; j < sObjectList[i].childViolations.length; j++){
                    counter=0;
                    for(var cTempKey in childkeys) {
                        var ckey = childkeys[cTempKey] ;
                        // add , after every value except the first.
                        if(counter > 0){
                            csvString += columnEnd;
                        }
                        // If the column is undefined, leave it as blank in the CSV file.
                        var value = this.fieldValue(sObjectList[i].childViolations[j],ckey);
                        if(ckey == "Fine_Amount__c")
                        {
                            csvString += '"'+ "$" + value +'"';
                        }else{
                            csvString += '"'+ value +'"';
                        }
                        counter++;
                    }
                    csvString += lineEnd;
                }
            }
        }
        return csvString;
    },
    
    fieldValue : function(record, fieldPath){
        var path = fieldPath.split(/\./), temp = record;
        while(path.length) temp = temp[path.shift()];
        if(temp){
            return temp;
        }else if(fieldPath == "fineAmount" || fieldPath == "Fine_Amount__c"){
            return 0;
        }else{
            return '';
        }
        //return temp;
    },
    
    helperOfficeFilter : function(component, officeIdList) {
        var officeViolations = [];
        if(officeIdList && officeIdList.length>0 && !officeIdList.includes("All Offices"))
        {
            officeIdList.forEach(function(officeId){
                officeViolations = officeViolations.concat(component.get('v.complianceFinesByOffice')[officeId]);
            });
        }else if(officeIdList.includes("All Offices")){
            officeViolations = component.get('v.complianceFinesByOffice')["All Offices"];
        }
        return officeViolations;
    },
    pageViolations : function(component) {
        //var allTemplates=component.get("v.complianceFines");
        var allTemplates = this.filterData(component);
        var page = component.get("v.currentPage");
        var recordToDisplay = component.get("v.recordsPerPage");
        var total = allTemplates.length;
        var pages = Math.ceil(total / recordToDisplay) ;
        var offset= (page-1)*recordToDisplay;
        var pagesku = [];
        
        for(var i=offset;i<(total<(page*recordToDisplay) ? total:page*recordToDisplay);i++)
        {
            pagesku.push(allTemplates[i]); 
        }
        
        var pnums = []; 
        for(var i=1;i<=pages;i++){
            if(parseInt(page)-5 < i && i < parseInt(page) +5){
                pnums.push(i);
            }
        }
        component.set("v.pagination",pages);
        component.set("v.pages",pnums);
        component.set("v.complianceFinesDisplay", pagesku);
    },
    
})