({
    init: function (cmp, event, helper) {
        //helper.filterData(cmp);
    },
    refreshData : function(cmp,event,helper) 
    {
        helper.resetSelection(cmp);
        if(cmp.get("v.allowFilters") == true){
            helper.populateFilters(cmp);
        }
        helper.filterData(cmp);
    },
    selectAll : function(cmp,event,helper) 
    {
        helper.selectAll(cmp);
    },
    searchTable : function(cmp,event,helper) 
    {
        helper.filterData(cmp);
    },
    handleFilterChange: function (cmp, event, helper) 
    {
        helper.filterData(cmp);
    },
    handleSort : function(component, event, helper){
        component.set('v.currentPage', 1);
        helper.sortByColumn(component, event);
    },
    //Pagination handlers
    lastPage : function(component, event, helper){
        var lastPage = component.get('v.totalPages');
        component.set('v.currentPage', lastPage);
        helper.pageRecords(component);
    },
    
    firstPage : function(component, event, helper){
        component.set('v.currentPage', 1);
        helper.pageRecords(component);
    },
    
    getPage : function(component, event, helper){
        var ctarget = event.currentTarget; 
        var offset = ctarget.dataset.offset;
        component.set('v.currentPage', parseInt(offset));
        helper.pageRecords(component);
    },
})