({
    
    fineData : function(component) {
        var action = component.get("c.getDetails");
        action.setParams({
            subId: component.get("v.subscriptionId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var violations = response.getReturnValue();
                var tempViolations = [];
                
                for(var i=0; i<violations.length; i++){
                    //violations[i]["showRemainingFines"] = true;   
                    var viol = {};
                    viol.compliance = violations[i];
                    viol["showRemainingFines"] = false;
                    tempViolations.push(viol);
                }
                console.log('----violations--'+JSON.stringify(tempViolations));
                component.set('v.complianceFines', tempViolations);
                component.set('v.complianceFinesDisplay', tempViolations);
                this.populateOffice(component);
            }
        });
        $A.enqueueAction(action);   	
    },
    
    populateOffice : function(component) {
        var complianceFinesByOffice = this.groupBy(component.get('v.complianceFines'), "compliance.Subscription__r.Related_Location_Broker_Office__r.Name",this);
        //console.log('---complianceFinesByOffice--'+JSON.stringify(complianceFinesByOffice));
        var items = [];
        items.push({
            "label": "All Offices",
            "value": "All Offices"
        });
        for (var offId in complianceFinesByOffice){
            var item = {
                "label": offId,
                "value": offId
            };
            items.push(item);
        }
        complianceFinesByOffice["All Offices"] = component.get('v.complianceFines');
        component.set("v.complianceFinesByOffice", complianceFinesByOffice);
        component.set("v.offices", items); 
        component.set("v.SelectedOffices", "All Offices");
        
    },
    groupBy : function(xs, key, helper) {
        return xs.reduce(function(rv, x) {
            /*
            if(key.includes(".")){
                // (rv[x[key.split(".")[0]][key.split(".")[1]]] = rv[x[key.split(".")[0]][key.split(".")[1]]] || []).push(x);
                (rv[x[key.split(".")[0]][key.split(".")[1]][key.split(".")[2]]] = rv[x[key.split(".")[0]][key.split(".")[1]][key.split(".")[2]]] || []).push(x);
            }
            else{
                (rv[x[key]] = rv[x[key]] || []).push(x);
            }
            */
            (rv[helper.fieldValue(x,key)] = rv[helper.fieldValue(x,key)] || []).push(x);
            return rv;
        }, {});   
    },
    
    sortHelper : function(component, field) {
        var helper = this;
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.complianceFinesDisplay");
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
        component.set("v.complianceFinesDisplay", records);
    },
    filterData : function(cmp) 
    {
        var allRecords = cmp.get("v.complianceFines");
        var searchFilter = cmp.get("v.searchKey");
        console.log('---searchFilter--'+searchFilter);
        var searchTempArray = [];
        if(!searchFilter)
        {
            searchTempArray = allRecords;
        }else{
            searchFilter = searchFilter.toUpperCase();
            var i;
            for(i=0; i < allRecords.length; i++){
                if((allRecords[i].compliance.Compliance_Fines__r[0].Subscription__r.Contact__r.Name && allRecords[i].compliance.Compliance_Fines__r[0].Subscription__r.Contact__r.Name.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].compliance.Subscription__r.Name && allRecords[i].compliance.Subscription__r.Name.toUpperCase().indexOf(searchFilter) != -1 ) || 
                   (allRecords[i].compliance.Compliance_Fines__r[0].MLS_Number__c && allRecords[i].compliance.Compliance_Fines__r[0].MLS_Number__c.toUpperCase().indexOf(searchFilter) != -1 )  ||
                   (allRecords[i].compliance.Compliance_Fines__r[0].Violation__c && allRecords[i].compliance.Compliance_Fines__r[0].Violation__c.toUpperCase().indexOf(searchFilter) != -1 )
                   (allRecords[i].compliance.Compliance_Fines__r[0].Status__c && allRecords[i].compliance.Compliance_Fines__r[0].Status__c.toUpperCase().indexOf(searchFilter) != -1 ))
                {
                    searchTempArray.push(allRecords[i]);
                }
            }
        }
        cmp.set("v.complianceFinesDisplay", searchTempArray);        
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
        /*
        sObjectList.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                keys.add(key);
            });
        });
        */
        //
        keys = Array.from(keys);
        keys = ['Subscription__r.Contact__r.Name','Subscription__r.Name','Subscription__r.Related_Location_Broker_Office__r.Name','MLS_Number__c','Violation__c','Compliance_Violation__r.Name','Notification_Type__c','Date_of_Fine__c','Fine_Amount__c','Status__c','Last_Date_to_Appeal__c'];
        var headers = ['Agent','Subscription Id','Office Id','MLS Number','Violation Type','Violation Number','Notification Type','Notification Date','Fine Amount','Status','Last Date to Appeal'];
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
                //var value = sObjectList[i][skey] === undefined ? '' : sObjectList[i][skey];
                var value = this.fieldValue(sObjectList[i],skey);
                value = value=== undefined ? '' : value;
                csvString += '"'+ value +'"';
                counter++;
            }
            csvString += lineEnd;
        }
        return csvString;
    },
    
    fieldValue : function(record, fieldPath){
        var path = fieldPath.split(/\./), temp = record;
        while(path.length) temp = temp[path.shift()];
        return temp;
    },
    
    
})