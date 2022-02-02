<aura:application extends="force:slds">
    
    <aura:attribute name="options" type="List" default="[{'label':'Bob','value':'123'},
                                                        {'label':'Shubham','value':'234'},
                                                        {'label':'Chrissey','value':'345'},
                                                        {'label':'Jessica','value':'456','disabled': true},
                                                        {'label':'Sunny','value':'567'}]" />
    
    <aura:attribute name="selectedValue" type="String" default="" description="Selected value in single Select" />
    <!--    
        <c:MultiSelectCombobox options="{!v.options}" value="{!v.selectedValue}" label="Single Select Combobox"/>
        -->
    
    
    <aura:attribute name="selectedValues" type="List" default="" description="Selected value in Multi Select" />
    
    <c:bcomHeader />
    
    <div style="width:200px;">
        
        <c:MultiSelectCombobox options="{!v.options}" values="{!v.selectedValues}" multiSelect="true" label="Offices"/>
        
        
    </div>
    
</aura:application>