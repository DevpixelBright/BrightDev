({
   
    handleClick: function(cmp, event, helper) {
        window.location = '/customers/apex/Communities_AgentAccuracy?id='+cmp.get("v.subId");
    }

})