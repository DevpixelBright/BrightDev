({
	openModel: function(component, event, helper) {
      // for Display Model,set the "popup1" attribute to "true"
      component.set("v.popup1", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "popup1" attribute to "Fasle"  
      component.set("v.popup1", false);
   },
})