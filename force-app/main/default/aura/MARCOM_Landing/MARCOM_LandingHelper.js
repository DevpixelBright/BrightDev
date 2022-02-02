({
	getEmailTemplates : function(component, event, helper) {
        component.set('v.loading', true);
        var status = component.get('v.status');
        var folder = component.get('v.currentFolder');
        var currentPage = component.get('v.currentPage');
        var searchText = component.get('v.searchText');
        var createdDate = component.get('v.createdDate');
        var lastModofiedDate = component.get('v.lastModofiedDate');
        var sortColumn = component.get('v.sortColumn') && !component.get('v.sortColumn').includes(".") ? component.get('v.sortColumn') : "Name";
        var order = component.get('v.descending');
        var category = component.get('v.selectedCategory');
        
		var action = component.get("c.getTemplates");
        action.setParams({ 
            offset : currentPage, 
            status : status, 
            folder : folder, 
            searchText : searchText,
            createdDate : createdDate,
            lastModofiedDate : lastModofiedDate,
            sortColumn : sortColumn,
            order : order,
            category : category
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set('v.selectAllCheckboxes', false);
                component.set('v.isCurrentUserSysAdmin', resp.isSysAdmin);
                
                var filteredTemplates = [];
                
                for(var i = 0; i < resp.lTemplates.length; i++){
                    try{
                    	resp.lTemplates[i].Description = JSON.parse(resp.lTemplates[i].Description);    
                    }catch(ex){
                        if(resp.lTemplates[i].Description == undefined && resp.lTemplates[i].Description == null){
                            resp.lTemplates[i].Description = {};
                        }
                        var desc = resp.lTemplates[i].Description;
                        resp.lTemplates[i].Description = {};
                        resp.lTemplates[i].Description.Desc = desc;
                        resp.lTemplates[i].Description.Automated = 'No';
                    }
                }
                //Filter the templates with search text on Template Id (in Description) / Template Name --start
                for(var i = 0; i < resp.lTemplates.length; i++){
                    if(!component.get('v.searchText') || 
                       (resp.lTemplates[i].Description.Id && 
                        resp.lTemplates[i].Description.Id.toLowerCase().includes(component.get('v.searchText').toLowerCase())) ||
                       (resp.lTemplates[i].Name && 
                        resp.lTemplates[i].Name.toLowerCase().includes(component.get('v.searchText').toLowerCase())))
                       //(resp.lTemplates[i].HtmlValue && 
                        //resp.lTemplates[i].HtmlValue.toLowerCase().includes(component.get('v.searchText').toLowerCase())))
                    {
                        filteredTemplates.push(resp.lTemplates[i]);
                    }
                }
                resp.lTemplates = filteredTemplates;
                //Filter the templates with search text on Template Id (in Description) / Template Name --end
                
                component.set('v.eTempalates', resp.lTemplates);
                if(resp.lTemplates){
                    component.set('v.currentPage', 1);
                    //this.pageTemplates(component);
                    this.sortByColumn(component);
                }
                //component.set('v.pagination', resp.pagination);
                //component.set('v.pages', resp.pages);
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set('v.loading', false);
        });
        $A.enqueueAction(action);
	},
    
    getConfig : function(component, event, helper) {
        var action = component.get("c.getConfigurations");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set('v.folders', resp.lFolder);
                component.set('v.category', resp.lCategory);
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    sortByColumn : function(component, event) {
        var sortColumn = component.get('v.sortColumn');
        var columnName;
        if(event){
            columnName = event.currentTarget.getAttribute('data-columnName');
        }else{
            columnName = sortColumn;
        }
        if(sortColumn == columnName){
            component.set('v.descending', !component.get('v.descending'));
        }else{
            component.set('v.sortColumn', columnName);
            component.set('v.descending', false);
        }
        var order = component.get('v.descending');
        var sortField = component.get("v.sortColumn");
        var records = component.get("v.eTempalates");
        
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
        component.set("v.eTempalates", records);
        this.pageTemplates(component);
    },
    pageTemplates : function(component) {
        component.set("v.selectAllCheckboxes", false);
        var allTemplates=component.get("v.eTempalates");
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
        component.set("v.SKUdata",pagesku);
        component.set("v.page", page);
        component.set("v.total", total);
        component.set("v.pages", pages);
        
        var pnums = []; 
        for(var i=1;i<=pages;i++){
            if(parseInt(page)-5 < i && i < parseInt(page) +5){
                pnums.push(i);
            }
        }
        component.set("v.pagination",pages);
        component.set("v.pages",pnums);
        component.set("v.pageETempalates", pagesku);
    },
})