({  
    openModel: function(component, event, helper) {
      // for Display Model,set the "popup1" attribute to "true"
      component.set("v.popup1", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "popup1" attribute to "Fasle"  
      component.set("v.popup1", false);
   },
    openModel1: function(component, event, helper) {
      // for Display Model,set the "popup2" attribute to "true"
      component.set("v.popup2", true);
   },
 
   closeModel1: function(component, event, helper) {
      // for Hide/Close Model,set the "popup2" attribute to "Fasle"  
      component.set("v.popup2", false);
   },
	treeMenu : function(component, event, helper) {
		var elements = document.getElementsByClassName("submenu1");
        if(elements[0].style.display == 'none') {
            elements[0].style.display = 'block';
        } else {
            elements[0].style.display = 'none';
        }   
        
	},
    
    treeMenu1 : function(component, event, helper) {
		var elements = document.getElementsByClassName("submenu2");
        if(elements[0].style.display == 'none') {
            elements[0].style.display = 'block';
        } else {
            elements[0].style.display = 'none';
        }   
        
	},
    
    treeMenu2 : function(component, event, helper) {
		var elements = document.getElementsByClassName("submenu3");
        if(elements[0].style.display == 'none') {
            elements[0].style.display = 'block';
        } else {
            elements[0].style.display = 'none';
        }   
        
	},
    
    treeMenu3 : function(component, event, helper) {
		var elements = document.getElementsByClassName("submenu4");
        if(elements[0].style.display == 'none') {
            elements[0].style.display = 'block';
        } else {
            elements[0].style.display = 'none';
        }   
        
	},
    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        
    }
})