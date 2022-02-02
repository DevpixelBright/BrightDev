({
    loadData: function(component, event, helper) {
        
        var action = component.get('c.getDataMethod');
        action.setParams({
            subId: component.get("v.subscriptionId")
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            console.log('--state--'+state);
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                var exclusiveOffices = response.getReturnValue();
                component.set('v.officeExclusive', exclusiveOffices);
                component.set('v.officeExclusiveDisplay', exclusiveOffices);
                component.set('v.currentPage', 1);
                this.populateOffice(component);
                this.pageExclusiveOffices(component);
            }
        });
        $A.enqueueAction(action);
    },
    populateOffice : function(component) {
        var complianceFinesByOffice = this.groupBy(component.get('v.officeExclusive'), "officeId", this);
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
        complianceFinesByOffice["All Offices"] = component.get('v.officeExclusive');
        component.set("v.officeExclusiveByOffice", complianceFinesByOffice);
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
    
    helperOfficeFilter : function(component, officeIdList) {
        var exclusiveOffices = [];
        if(officeIdList && officeIdList.length>0 && !officeIdList.includes("All Offices"))
        {
            officeIdList.forEach(function(officeId){
                exclusiveOffices = exclusiveOffices.concat(component.get('v.officeExclusiveByOffice')[officeId]);
            });
        }else if(officeIdList.includes("All Offices")){
            exclusiveOffices = component.get('v.officeExclusiveByOffice')["All Offices"];
        }
        return exclusiveOffices;
    },
    pageExclusiveOffices : function(component) {
        var allTemplates = this.filterData(component);
        allTemplates = this.sortRecords(component, allTemplates, this);
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
        component.set("v.officeExclusiveDisplay", pagesku);
    },
    
    sortHelper : function(component, field) {
        var helper = this;
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField");
        sortAsc = field == sortField? !sortAsc: true;
        
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.officeExclusive", helper.sortRecords(component, component.get("v.officeExclusive"), helper));
        helper.pageExclusiveOffices(component);
    },
    
    sortRecords : function(component, records, helper) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField");
        records.sort(function(a,b){
            var a_fld=helper.fieldValue(a, sortField);
            var b_fld=helper.fieldValue(b, sortField);
            var t1 = a_fld == b_fld;
            var t2 = a_fld > b_fld;
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        return records;
    },
    
    convertArrayOfObjectsToCSV : function(component, sObjectList){
        if (sObjectList == null || sObjectList.length == 0) {
            return null; //
        }
        // CSV file parameters.
        var columnEnd = ',';
        var lineEnd =  '\n';
        // Get the CSV header from the list.
        var keys = ['officeId','listAgentId','agentName','propertyAddress','city','state','zip','submittedOnStr','submittedBy'];
        var headers = ['Office ID','Agent ID','Agent Name','Property Address','City','State','Zip','Office Exclusive Date Submitted','Submitted by'];
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
                //var value = sObjectList[i][skey] === undefined ? '' : sObjectList[i][skey];
                var value = this.fieldValue(sObjectList[i], skey);
                csvString += '"'+ value +'"';
                counter++;
            }
            csvString += lineEnd;
        }
        
        return csvString;
    },
    filterData : function(cmp) 
    {
        var allRecords = cmp.get("v.officeExclusive");
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
                if((allRecords[i].officeId && allRecords[i].officeId.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].listAgentId && allRecords[i].listAgentId.toUpperCase().indexOf(searchFilter) != -1 ) || 
                   (allRecords[i].agentName && allRecords[i].agentName.toUpperCase().indexOf(searchFilter) != -1 )  ||
                   (allRecords[i].propertyAddress && allRecords[i].propertyAddress.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].city && allRecords[i].city.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].state && allRecords[i].state.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].zip && allRecords[i].zip.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].submittedOnStr && allRecords[i].submittedOnStr.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].submittedBy && allRecords[i].submittedBy.toString().toUpperCase().indexOf(searchFilter) != -1 ))
                {
                    searchTempArray.push(allRecords[i]);
                }
            }
        } 
        return searchTempArray;
    },
    
    fieldValue : function(record, fieldPath){
        var path = fieldPath.split(/\./), temp = record;
        while(path.length){
            if(temp == undefined)
                return '';
            temp = temp[path.shift()];
        }
        if(temp){
            return temp;
        }else{
            return '';
        }
    },
    
    
})