<aura:application extends="force:slds">
   <ltng:require styles="{!$Resource.brightcss }"></ltng:require>
   <ltng:require styles="{!$Resource.sidemenu }"></ltng:require> 
   <ltng:require styles="{!$Resource.bodycontainer }"></ltng:require>
    <aura:attribute name="toggle1" type="boolean" default="false"/>
    
    <aura:attribute name="toggle2" type="boolean" default="false"/>
   	<aura:attribute name="toggle3" type="boolean" default="false"/>
    
   <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" />
   <div class="fullpage slds-scope">
      <div class="slds-grid slds-wrap">
          <c:Bright_Header/>
         <div class="slds-container--x-large new-container">
            <div class="slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12">
                <c:Bright_SideBar/>
                <c:Bright_ResponsibleBroker/>
                
            </div>
         </div>
      
      </div>
       
       <!-- PopUp 1 start -->
       <aura:if isTrue="{!v.popup}">
           <section role="dialog" tabindex="-1" aria-labelledby="modal-heading-01" aria-modal="true" aria-describedby="modal-content-id-1" class="slds-modal slds-fade-in-open">
                <div class="slds-modal__container">
                    <!-- ###### MODAL BOX HEADER Start ######-->
                    <header class="slds-modal__header">
                        <lightning:buttonIcon iconName="utility:close"
                                              onclick="{! c.closeModel }"
                                              alternativeText="close"
                                              variant="bare-inverse"
                                              class="slds-modal__close"/>
                        <h2 id="modal-heading-01" class="slds-text-heading_medium slds-hyphenate email">Submit Completed W-9 Form</h2>
                    </header>
                    <!--###### MODAL BOX BODY Part Start######-->
                    <div class="slds-modal__content slds-p-around_medium" id="modal-content-id-1">
                       <div class="slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12 bodyline">
                      
                        <h3>Fill out the fields below and attach a PDF copy of the completed IRS W-9 form.</h3>
                        
                      
                        
                        
       
                            <div class="slds-col slds-size_12-of-12 slds-small-size_8-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12 bodylinefull">
                       <div class="slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_11-of-12 slds-large-size_11-of-12 bodyline1 ask">
                            <h6>Taxpayer Identifier Number <span>*</span></h6>
                         <lightning:input type="text" name="input3" placeholder="Enter TIN"  variant = "label-hidden" />
                      
                        </div>
                           </div>
                           <div class="slds-col slds-size_12-of-12 slds-small-size_8-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12 bodylinefull">
                       <div class="slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_11-of-12 slds-large-size_11-of-12 bodyline1 ask">
                            <h6>Broker Office Name <span>*</span></h6>
                         <lightning:input type="text" name="input3" placeholder="Enter Name"  variant = "label-hidden" />
                      
                        </div>
                           </div>
                           <div class="slds-col slds-size_12-of-12 slds-small-size_8-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12 bodylinefull">
                        <div class="slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_11-of-12 slds-large-size_11-of-12 bodyline1 ask">
                            <h6>Office ID</h6>
                         <lightning:input type="text" name="input3" placeholder="Enter postal code"  variant = "label-hidden" />
                               </div>
                                <div class="slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_1-of-12 slds-large-size_1-of-12 bodyline1 ask">
                          
                                     <img  class="ask1" src="{!$Resource.bright + '/bright-3.0/images/info-outline.svg'}" alt="info" />
                          </div>
                        </div>
                            <div class="slds-col slds-size_12-of-12 slds-small-size_8-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12 bodylinefull">
                       <div class="slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_11-of-12 slds-large-size_11-of-12 bodyline1 ask">
                           <p>Please attach an electronic copy of the completed IRS W-9 Form below:</p> 
                           
                           <h6 class="add">Add Attachment <span>*</span></h6>
                           
                           <div class="file"><a href=""><span>Choose File</span> No file chosen</a></div>
                         
                        </div>
                           </div>
                    </div>
                    </div>
                    <!--###### MODAL BOX FOOTER Part Start ######-->
                    <footer class="slds-modal__footer">
                         <lightning:button class="brand" variant="brand" label="Submit" title="Brand action" onclick="{! c.handleClick }" />
                       
                        <lightning:button variant="neutral" 
                                          label="Cancel"
                                          title="Cancel"
                                           class="newCancel"
                                          onclick="{! c.closeModel }"/>
                        
                    </footer>
                </div>
            </section>
            <div class="slds-backdrop slds-backdrop_open"></div>
       </aura:if>
       <!-- PopUp 1 end -->
       
   </div>
</aura:application>