({
    doInitHelper : function(component) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        this.checkAndSetSelected(component);
    },
    
    checkAndSetSelected : function(component) {
        var value = component.get('v.value');
        var values = component.get('v.values');
		if( !$A.util.isEmpty(value) || !$A.util.isEmpty(values) ) {
            var searchString;
        	var count = 0;
            var multiSelect = component.get('v.multiSelect');
			var options = component.get('v.options');
            options.forEach( function(element, index) {
                if(multiSelect) {
                    if(values.includes(element.value)) {
                        element.selected = true;
                        count++;
                    }  
                } else {
                    if(element.value == value) {
                        searchString = element.label;
                    }
                }
            });
            
            component.set('v.options', options);
            this.setSearchString(component);
		}
    },
    
    filterOptionsHelper : function(component) {
        component.set("v.message", '');
        var searchText = component.get('v.searchString');
		var options = component.get("v.options");
		var minChar = component.get('v.minChar');
		if(searchText.length >= minChar) {
            var flag = true;
			options.forEach( function(element,index) {
                if(element.label.toLowerCase().trim().startsWith(searchText.toLowerCase().trim())) {
					element.isVisible = true;
                    flag = false;
                } else {
					element.isVisible = false;
                }
			});
			component.set("v.options",options);
            if(flag) {
                component.set("v.message", "No results found for '" + searchText + "'");
            }
		}
        $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
	},
    
    selectItemHelper : function(component, event) {
        var options = component.get('v.options');
        var multiSelect = component.get('v.multiSelect');
        var searchString = component.get('v.searchString');
        var values = component.get('v.values') || [];
        var value;
        var count = 0;
        var doSelectAll=false, doUnselectAll=false, checkAllbox=true;
        
        options.forEach( function(element, index) {
            if(element.value === event.currentTarget.id) {
                if(multiSelect) {
                    if(values.includes(element.value)) {
                        values.splice(values.indexOf(element.value), 1);
                    } else {
                        values.push(element.value);
                    }
                    element.selected = element.selected ? false : true;
                    //handleAll
                    if(event.currentTarget.id == component.get('v.allValue'))
                    {
                        if(element.selected)
                        {
                            doSelectAll = true;
                        }
                        else
                        {
                            doUnselectAll = true;
                        }
                    }
                    //
                } else {
                    value = element.value;
                    searchString = element.label;
                }
            }
            if(element.selected) {
                count++;
            }
            if(element.value != component.get('v.allValue'))
            checkAllbox = (checkAllbox && element.selected == true);
        });
        component.set('v.value', value);
        
        if(!doSelectAll && !doUnselectAll)
        {
            options.forEach( function(element, index) {
                if(element.value === component.get('v.allValue')) {
                    element.selected = checkAllbox;
                    if(values.includes(element.value) && !checkAllbox) {
                        values.splice(values.indexOf(element.value), 1);
                    } else if(checkAllbox && !values.includes(element.value)){
                        values.push(element.value);
                    }
                }
            });
            component.set('v.values', values);
            component.set('v.options', options);
        }else{
            this.handleAll(component, doSelectAll);
        }
        
        this.setSearchString(component);
        
        if(multiSelect)
            event.preventDefault();
        else
        	$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
    
    removePillHelper : function(component, event) {
        var value = event.getSource().get('v.name');
        var multiSelect = component.get('v.multiSelect');
        var count = 0;
        var options = component.get("v.options");
        var values = component.get('v.values') || [];
        options.forEach( function(element, index) {
            if(element.value === value) {
                element.selected = false;
                values.splice(values.indexOf(element.value), 1);
            }
            if(element.selected) {
                count++;
            }
        });
        component.set('v.values', values)
        component.set("v.options", options);
        this.setSearchString(component);
    },
    
    blurEventHelper : function(component, event) {
        this.setSearchString(component);
        var multiSelect = component.get('v.multiSelect');
        
    	if(multiSelect)
        	$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
    
    setSearchString : function(component) {
        var selectedValue = component.get('v.value');
        var selectedValues = component.get('v.values');
        var multiSelect = component.get('v.multiSelect');
        var previousLabel;
        var count = 0;
        var options = component.get("v.options");
        options.forEach( function(element, index) {
            if(element.value === selectedValue) {
                previousLabel = element.label;
            }
            if(element.selected && element.value != component.get('v.allValue')) {
                count++;
            }
        });
        
        if(multiSelect)
        {
            /*
            if(selectedValues && selectedValues.length ==1){
                component.set('v.searchString', selectedValues[0]);  
            }else 
                */
            if(selectedValues && options && selectedValues.length == options.length){
                component.set('v.searchString', 'All selected'); 
            }else if(count == 0){
                component.set('v.searchString', 'None selected');
            }else{
                component.set('v.searchString', count + ' selected');  
            }
        }
        else{
        	component.set('v.searchString', previousLabel);
        }
    },
    
    handleAll : function(component, allSelected) {
        var options = component.get("v.options");
        var values = [];
        options.forEach( function(element, index) {
            element.selected = allSelected;
            if(allSelected){
                values.push(element.value);
            }
        });
        component.set("v.values", values);
        component.set("v.options", options);
    }
})