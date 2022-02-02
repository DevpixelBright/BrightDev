({
	populateFilters : function(cmp) 
    {
        if(cmp.get("v.columns") && cmp.get("v.columns").length > 0 && cmp.get("v.data") && cmp.get("v.data").length > 0){
            console.log('populate filters ---started');
            var filterColumns = [];
            cmp.get("v.columns").forEach(function(eachColumn){
                if(eachColumn && eachColumn.filter && eachColumn.filter == true){
                    filterColumns.push(eachColumn);
                }
            });
            var allData = cmp.get("v.data");
            var filterConfigs = [];
            if(filterColumns && filterColumns.length >0){
                filterColumns.forEach(function(eachFilter){
                    const unique = [...new Set(allData.map(item => item[eachFilter.fieldName]))];
                    var options = [{"label": "All", "value": "All"}];
                    unique.forEach(function(eachUniqueOpt){
                        options.push({"label": eachUniqueOpt, "value": eachUniqueOpt});
                    });
                    filterConfigs.push({"label": eachFilter.label, "fieldName": eachFilter.fieldName, "options" : options});
                });
                cmp.set("v.filterConfigurations", filterConfigs);
                //const unique = [...new Set(allData.map(item => item[filterColumns[0].fieldName]))];
                console.log('filterConfigs---'+JSON.stringify(filterConfigs));
            }
        }
    },
    resetSelection : function(cmp) 
    {
        if(cmp.get("v.data") && cmp.get("v.data").length>0 && cmp.get("v.allowRowSelect")){
            var allData = cmp.get("v.data");
            allData.forEach(function(eachRowData){
                eachRowData.selected = false;
            });
            cmp.set("v.data", allData);
        }
    },
    selectAll : function(cmp) 
    {
        if(cmp.get("v.data") && cmp.get("v.data").length>0){
            var allData = cmp.get("v.data");
            allData.forEach(function(eachRowData){
                eachRowData.selected = cmp.get("v.selectAllCheckboxes");
            });
            cmp.set("v.data", allData);
        }
        if(cmp.get("v.filteredData") && cmp.get("v.filteredData").length>0){
            var filteredData = cmp.get("v.filteredData");
            filteredData.forEach(function(eachRowData){
                eachRowData.selected = cmp.get("v.selectAllCheckboxes");
            });
            cmp.set("v.filteredData", filteredData);
        }
        if(cmp.get("v.pageRecords") && cmp.get("v.pageRecords").length>0){
            var pageRecords = cmp.get("v.pageRecords");
            pageRecords.forEach(function(eachRowData){
                eachRowData.selected = cmp.get("v.selectAllCheckboxes");
            });
            cmp.set("v.pageRecords", pageRecords);
        }
    },
    
    filterData : function(cmp) 
    {
        var allRecords = cmp.get("v.data");
        var searchFilter = cmp.get("v.searchKey");
        var searchTempArray = [];
        if(!searchFilter)
        {
            searchTempArray = allRecords;
        }else{
            searchFilter = searchFilter.toUpperCase();
            var i,isFiltered;
            for(i=0; i < allRecords.length; i++){
                isFiltered = false;
                cmp.get("v.columns").forEach(function(fld){
                    if(fld.searchable == true && allRecords[i][fld.fieldName] && 
                       allRecords[i][fld.fieldName].toUpperCase().indexOf(searchFilter) != -1){
                        isFiltered = true;
                    }
                });
                if(isFiltered == true){
                    searchTempArray.push(allRecords[i]);
                }
            }
        }
        
        
        var selectedOptionValue = cmp.get("v.statusFilter");
        console.log("Option selected with value: '" + selectedOptionValue + "'");
        var filterTempArray = [];
        
        var filterConfigurations = cmp.get("v.filterConfigurations");
        var firstFilter = true;
        
        if(filterConfigurations && filterConfigurations.length >0){
            filterConfigurations.forEach(function(eachFilter){
                //alert(eachFilter.label+'--'+eachFilter.value);
                if(firstFilter == true){
                    if(eachFilter.value == 'All' || !eachFilter.value){
                        filterTempArray = searchTempArray;
                    }else{
                        
                        for(var i=0; i < searchTempArray.length; i++){
                            if(searchTempArray[i][eachFilter.fieldName] && searchTempArray[i][eachFilter.fieldName] == eachFilter.value)
                            {
                                filterTempArray.push(searchTempArray[i]);
                            }
                        } 
                    }
                    firstFilter = false;
                }else{
                    var tempFilterArray = [];
                    if(eachFilter.value == 'All' || !eachFilter.value){
                        tempFilterArray = filterTempArray;
                    }else{
                        for(var i=0; i < filterTempArray.length; i++){
                            if(filterTempArray[i][eachFilter.fieldName] && filterTempArray[i][eachFilter.fieldName] == eachFilter.value)
                            {
                                tempFilterArray.push(filterTempArray[i]);
                            }
                        }
                    }
                    filterTempArray = tempFilterArray;
                }
                //alert(eachFilter.label+'--'+eachFilter.value+'--'+filterTempArray.length);
            });
        }else{
            filterTempArray = searchTempArray;
        }
        
        var rowsToLoad = cmp.get("v.rowsToLoad");
        console.log('rowsToLoad---'+rowsToLoad);
        console.log('filterTempArray---'+filterTempArray.length);
        
        
        cmp.set("v.filteredData", filterTempArray);
        this.pageRecords(cmp); 
    },
    sortData : function(component,fieldName,sortDirection)
    {
        var data = component.get("v.data");
        data = this.sort(data, fieldName,sortDirection);
        //set sorted data to accountData attribute
        component.set("v.data",data);
        this.filterData(component);
    },
    sort : function(data, fieldName, sortDirection)
    {
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? -1: 1;
        
        data.sort(function(a,b){ 
            var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a>b) - (b>a));
        });  
        return data;
    },
    sortByColumn : function(component, event) {
        var sortColumn = component.get('v.sortBy');
        var columnName;
        if(event){
            columnName = event.currentTarget.getAttribute('data-columnName');
        }else{
            columnName = sortColumn;
        }
        if(sortColumn == columnName){
            component.set('v.sortDirection', !component.get('v.sortDirection'));
        }else{
            component.set('v.sortBy', columnName);
            component.set('v.sortDirection', false);
        }
        var order = component.get('v.sortDirection');
        var sortField = component.get("v.sortBy");
        var records = component.get("v.data");
        
        if(records)
        records.sort(function(a,b){
            var t1,t2,a_fld,b_fld;
            if(sortField.includes(".")){
                a_fld = (a[sortField.split(".")[0]] && a[sortField.split(".")[0]][sortField.split(".")[1]]) ? a[sortField.split(".")[0]][sortField.split(".")[1]] : '';
                b_fld = (b[sortField.split(".")[0]] && b[sortField.split(".")[0]][sortField.split(".")[1]]) ? b[sortField.split(".")[0]][sortField.split(".")[1]] : '';
                a_fld = (a_fld && a_fld != true)? a_fld.toLowerCase() : a_fld;
                b_fld = (b_fld && b_fld != true)? b_fld.toLowerCase() : b_fld;
            }else{
                a_fld = (a[sortField] && a[sortField] != true)?a[sortField].toLowerCase() : a[sortField];
                b_fld = (b[sortField] && b[sortField] != true)?b[sortField].toLowerCase() : b[sortField];
            }
            t1 = a_fld == b_fld;
            t2 = a_fld > b_fld;
            return t1? 0: (order?-1:1)*(t2?-1:1);
        });
        component.set("v.data", records);
        this.filterData(component);
    },
    pageRecords : function(component) {
        var allRecs = component.get("v.filteredData");
        var page = component.get("v.currentPage");
        var recordToDisplay = component.get("v.recordsPerPage");
        var total = allRecs ? allRecs.length : 0;
        var pages = Math.ceil(total / recordToDisplay) ;
        var offset= (page-1)*recordToDisplay;
        var pageRecs = [];
        
        for(var i=parseInt(offset); i<(total<(page*recordToDisplay) ? total : page*recordToDisplay); i++)
        {
            pageRecs.push(allRecs[i]); 
        }
        component.set("v.page", page);
        component.set("v.total", total);
        component.set("v.totalPages", pages);
        component.set("v.pageRecords", pageRecs);
        
        var pnums = []; 
        for(var i=1;i<=pages;i++){
            if(parseInt(page)-5 < i && i < parseInt(page) +5){
                pnums.push(i);
            }
        }
        component.set("v.pages", pnums);        
    },
})