({
    
    yesResponse : function(component, event, helper) {
        
  var result = sforce.apex.execute('Case_Javascript', 'archive', {
  caseId: ''+helper.idTruncate(component.get('v.sObjectInfo.Id'))+''});
  if (result[0] == 'Success') {
helper.gotoURL(component, '/' + result[1]);
  } else 
    alert('Failed: ' + result[1]);

        
        $A.get("e.force:closeQuickAction").fire();
    },
    
    noResponse : function(component, event, helper) {
        

        
        $A.get("e.force:closeQuickAction").fire();
    }
})