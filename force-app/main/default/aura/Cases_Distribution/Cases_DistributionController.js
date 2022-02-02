// Case_DistributionTableController.js 

({
doInit : function(component, event, helper)
{
var pageSize = component.get("v.pageSize");
var action = component.get("c.getCases");
action.setCallback(this, function(response)
{
var state = response.getState();
if (component.isValid() && state === "SUCCESS")
{
component.set('v.caseList', response.getReturnValue());
component.set("v.totalSize", component.get("v.caseList").length);
component.set("v.start",0);
component.set("v.end",pageSize-1);
var paginationList = [];
for(var i=0; i< pageSize; i++)
{
paginationList.push(response.getReturnValue()[i]);
}
component.set('v.paginationList', paginationList);
//console.log(paginationList);
}
});
$A.enqueueAction(action);
},

onSelectChange : function(component, event, helper) {
var selected = component.find("records").get("v.value");
var paginationList = [];
var casList = component.get("v.caseList");
for(var i=0; i< selected; i++)
{
paginationList.push(casList[i]);
}
component.set('v.paginationList', paginationList);
},

searchKeyChange: function(component, event) {
var searchKey =  component.find("input1").get("v.value");

    alert(searchKey);
    
var action = component.get("c.getByName");
var keysize = component.get("v.totalSize");
       
action.setParams({
"searchKey": searchKey
});
   
action.setCallback(this, function(response) {
var state = response.getState();
if (component.isValid() && state === "SUCCESS")
{
component.set('v.caseList', response.getReturnValue());
component.set("v.totalSize", component.get("v.caseList").length);
var paginationList = [];
for(var i=0; i< keysize; i++)
{
paginationList.push(response.getReturnValue()[i]);
}
component.set('v.paginationList', paginationList);
}
});
$A.enqueueAction(action);
},
first : function(component, event, helper)
{
var casList = component.get("v.caseList");
var pageSize = component.get("v.pageSize");
var paginationList = [];
for(var i=0; i< pageSize; i++)
{
paginationList.push(casList[i]);
}
component.set('v.paginationList', paginationList);
},
last : function(component, event, helper)
{
var casList = component.get("v.caseList");
var pageSize = component.get("v.pageSize");
var totalSize = component.get("v.totalSize");
var paginationList = [];
for(var i=totalSize-pageSize+1; i< totalSize; i++)
{
paginationList.push(casList[i]);
}
component.set('v.paginationList', paginationList);
},
next : function(component, event, helper)
{
var casList = component.get("v.caseList");
var end = component.get("v.end");
var start = component.get("v.start");
var pageSize = component.get("v.pageSize");
var paginationList = [];
var counter = 0;
for(var i=end+1; i<end+pageSize+1; i++)
{
if(casList.length > end)
{
paginationList.push(casList[i]);
counter ++ ;
}
}
start = start + counter;
end = end + counter;
component.set("v.start",start);
component.set("v.end",end);
component.set('v.paginationList', paginationList);
},
previous : function(component, event, helper)
{
var casList = component.get("v.caseList");
var end = component.get("v.end");
var start = component.get("v.start");
var pageSize = component.get("v.pageSize");
var paginationList = [];
var counter = 0;
for(var i= start-pageSize; i < start ; i++)
{
if(i > -1)
{
paginationList.push(casList[i]);
counter ++;
}
else {
start++;
}
}
start = start - counter;
end = end - counter;
component.set("v.start",start);
component.set("v.end",end);
component.set('v.paginationList', paginationList);
}
})