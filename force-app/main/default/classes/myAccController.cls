public class myAccController {
  
    private String valueC;// = System.currentPageReference().getParameters().get('subscription');
    private String valueS;// = System.currentPageReference().getParameters().get('contact');
    
    public Contact con {get;set;}
    public List<Subscriptions__c> subs {get;set;}
    public Subscriptions__c sub{get;set;}
    public String QASTypedownSessionToken {get; private set;}
    
    public String showCountry {get; set;}
/*myaccount?contact=003K000000H2flL&subscription=7000056 --> returns subscription 7000056
  myaccount?contact=003K000000H2flL&subscription= --> returns primary subscription for contact*/
  
    public  myAccController() {
System.debug('getName ---> '  + UserInfo.getName());
 // QAS Constructor -- Nick   
        QAS_NA__QAS_CA_Account__c [] accountSObject = [SELECT QAS_NA__ValidationSessionToken__c FROM QAS_NA__QAS_CA_Account__c];        
        if(accountSObject != null || accountSObject.size() > 0) {        
        QASTypedownSessionToken = accountSObject[0].QAS_NA__ValidationSessionToken__c;        
        }    

        System.debug('in the controller');
        valueS = System.currentPageReference().getParameters().get('subscription');
        valueC = System.currentPageReference().getParameters().get('contact');
        System.debug('valueC ---> ' + valueC);
        System.debug('valueS ---> ' + valueS);
        
        if (valueC == null || ''.equals(valueC) ) {
            valueC = getContact().id;
        }

        getSub();
        
    }
    
    public List<Subscriptions__c> getSubs() {
        return this.subs;
    }
    
    public void setSubs(List<Subscriptions__c> s) {
        this.subs = s;
    }
     public Contact getContact() {
        System.debug('in controller');
        String contactID = System.currentPageReference().getParameters().get('contact');
        System.debug('Userinfo.getUserId() ---> ' + Userinfo.getUserId());
        if (contactID == null || ''.equals(contactID)) {
            List<User> uList = [select id,contactID from User where id = :Userinfo.getUserId()];
            System.debug('uList ----> ' + uList);   
            if (uList.size() > 0) {
                contactID = uList.get(0).contactID;
            }
        }
        
         this.con = [SELECT name, id, Description, Phone, Fax, Street_Number__c, Street_Name__c,
                            Street_Type__c, Street_Direction__c, Unit_Type__c, Unit__c, Addl_Display_Name__c,
                            City__c, County__c, Country__c, State__c, Zip__c, Zip_4__c, Billing_Addl_Display_Name__c, 
                            Billing_City__c, Billing_Country__c, Billing_State__c, Billing_Street_Direction__c,
                            Billing_Street_Name__c, Billing_Street_Number__c, Billing_Street_Number_Suffix__c,
                            Billing_Street_Type__c, Billing_Unit_Number__c, Billing_Unit_Type__c,
                            Billing_Zip__c, Billing_Zip_4__c, Copy_Address_to_Billing__c, Voicemail__c, VM_Ext__c,
                            MobilePhone, Home_Fax__c, Agent_Office_Phone__c, Website__c, Public_Email__c, Email,
                            NRDS_ID__c
                            FROM Contact WHERE id =:contactID limit 1];
                           
                           
     System.debug('this.con..........'+this.con);
         return this.con;
         
     }
 
      public String getContactID() {
          Contact c = getContact();
          String cID = c.id;
          String newID = cID.substring(0, cID.length()-3);
          return newID;
      }
 
 public Subscriptions__c getSub(){
    // valueS =System.currentPageReference().getParameters().get('subscription');
     //valueS =System.currentPageReference().getParameters().get('contact');
     System.debug('valueS ----> in sub ' + valueS);
     System.debug('valueC ----> in sub ' + valueC);
     if(valueC != null && valueS != null && valueS != '')    
    {
        System.debug('value of sub name: ' + valueS);
        sub = [SELECT  name, id, Primary_Phone__c, Pager__c, Fax__c, Street_Number__c, Street_Name__c,
                            Street_Type__c, Street_Direction__c, Unit_Type__c, Unit__c, Addl_Display_Name__c,
                            City__c, County__c, Country__c, State__c, Zip__c, Zip_4__c, Billing_Addl_Display_Name__c, 
                            Billing_City__c, Billing_County__c, Billing_Country__c, Billing_State__c, Billing_Street_Direction__c,
                            Billing_Street_Name__c, Billing_Street_Number__c, Billing_Street_Suffix__c, QAS_Billing_Validation_Timestamp__c,
                            Billing_Street_Type__c, Billing_Unit_Number__c, Billing_Unit_Type__c, QAS_Billing_Validation_Status__c,
                            Billing_Zip__c, Billing_Zip_4__c, Copy_Address_to_Billing__c, Voicemail__c, VM_Ext__c,
                            Mobile_Phone__c, Home_Fax__c, Agent_Office_Phone__c, Website__c, Public_Email__c, QAS_Billing_POBox__c,
                            Private_Email__c, NRDS_ID__c, Primary__c, QAS_Mailing_Street_Type__c, QAS_Mailing_Street_Direction__c, 
                            QAS_Mailing_Unit_Type__c, QAS_Billing_Street_Type__C, QAS_Billing_Unit_Type__c, QAS_Billing_Street_Direction__c,
                            QAS_Mailing_County__c, QAS_Mailing_Country__c, QAS_Billing_County__c, QAS_Billing_Country__c, QAS_Mailing_POBox__c,
                            QAS_Validation_Status__c, QAS_Validation_Timestamp__c, Street_Number_Suffix__c, 
                            QAS_Mailing_Record_Type__c, QAS_Billing_Record_Type__c
                            FROM Subscriptions__c WHERE name =: valueS limit 1];    
  
                            
                                        
    }else{
        this.sub = getPrimarySub();
    }
   // System.debug(sub.QAS_Mailing_Street_Type__c);
    return this.sub;
 }
 
 public Subscriptions__c getPrimarySub() {
 
      subs = [SELECT  name, id, Primary_Phone__c, Pager__c, Fax__c, Street_Number__c, Street_Name__c,
                            Street_Type__c, Street_Direction__c, Unit_Type__c, Unit__c, Addl_Display_Name__c,
                            City__c, County__c, Country__c, State__c, Zip__c, Zip_4__c, Billing_Addl_Display_Name__c, 
                            Billing_City__c, Billing_County__c, Billing_Country__c, Billing_State__c, Billing_Street_Direction__c,
                            Billing_Street_Name__c, Billing_Street_Number__c, Billing_Street_Suffix__c, QAS_Billing_Validation_Status__c,
                            Billing_Street_Type__c, Billing_Unit_Number__c, Billing_Unit_Type__c, QAS_Billing_POBox__c,
                            Billing_Zip__c, Billing_Zip_4__c, Copy_Address_to_Billing__c, Voicemail__c, VM_Ext__c,
                            Mobile_Phone__c, Home_Fax__c, Agent_Office_Phone__c, Website__c, Public_Email__c, QAS_Billing_Validation_Timestamp__c,
                            Private_Email__c, NRDS_ID__c, Primary__c, Contact__c, QAS_Mailing_Street_Type__c, QAS_Mailing_Street_Direction__c, 
                            QAS_Mailing_Unit_Type__c, QAS_Billing_Street_Type__C, QAS_Billing_Unit_Type__c, QAS_Billing_Street_Direction__c, 
                            QAS_Mailing_County__c, QAS_Mailing_Country__c, QAS_Billing_County__c, QAS_Billing_Country__c, 
                            QAS_Mailing_POBox__c,QAS_Validation_Status__c, QAS_Validation_Timestamp__c, Street_Number_Suffix__c,                     
                            QAS_Mailing_Record_Type__c, 
                            QAS_Billing_Record_Type__c
                            FROM Subscriptions__c WHERE Contact__c =: valueC AND Primary__c =: true]; 
    /*         
      if(!subs.isEmpty()){          
        Subscriptions__c ns = new Subscriptions__c();
        ns = subs[0];             
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Subs one Country--> ' + ns.Country__c + ' Billing--> '+ ns.Billing_Country__c));
           this.showCountry = ns.Country__c;
      }
       */                    
                            
     if(!subs.isEmpty())       
        return subs[0];  
     else
        return null;
                           
 }
 
 
 public List<Subscriptions__c> getAllSubs() {
 

       //System.debug('valueC: ' + valueC + ' valueS: ' + valueS + ' p email: ' + subs[0].private_email__c);
                            
       this.subs = new List<Subscriptions__c>();
       this.subs.addAll([SELECT  name, id, Primary_Phone__c, Pager__c, Fax__c, Street_Number__c, Street_Name__c,
                        Street_Type__c, Street_Direction__c, Unit_Type__c, Unit__c, Addl_Display_Name__c,
                        City__c, County__c, Country__c, State__c, Zip__c, Zip_4__c, Billing_Addl_Display_Name__c, 
                        Billing_City__c, Billing_County__c, Billing_Country__c, Billing_State__c, Billing_Street_Direction__c,
                        Billing_Street_Name__c, Billing_Street_Number__c, Billing_Street_Suffix__c, QAS_Billing_Validation_Status__c,
                        Billing_Street_Type__c, Billing_Unit_Number__c, Billing_Unit_Type__c, QAS_Billing_POBox__c,
                        Billing_Zip__c, Billing_Zip_4__c, Copy_Address_to_Billing__c, Voicemail__c, VM_Ext__c,
                        Mobile_Phone__c, Home_Fax__c, Agent_Office_Phone__c, Website__c, Public_Email__c, QAS_Billing_Validation_Timestamp__c,
                        Private_Email__c, NRDS_ID__c, QAS_Mailing_Street_Type__c, QAS_Mailing_Street_Direction__c, 
                        QAS_Mailing_Unit_Type__c, QAS_Billing_Street_Type__C, QAS_Billing_Unit_Type__c, QAS_Billing_Street_Direction__c,
                        QAS_Mailing_County__c, QAS_Mailing_Country__c, QAS_Billing_County__c, QAS_Billing_Country__c, QAS_Mailing_POBox__c,
                        QAS_Validation_Status__c, QAS_Validation_Timestamp__c, Street_Number_Suffix__c,
                        QAS_Mailing_Record_Type__c, 
                        QAS_Billing_Record_Type__c
                        FROM Subscriptions__c WHERE Contact__c=:valueC AND Status__c = 'Active']);
                        return this.subs;
 }
 
  public Contact getData() {
        return con;
    }

    public PageReference save() {
        Boolean error=false;
        String commonError = 'The Required fields are missing:  ';
        
   
     // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+' Billing--> '+ sub.Billing_Country__c));
      //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+' Country--> '+ sub.Country__c));           
     // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+' QBillBilling--> '+ sub.QAS_Billing_Country__c));
     
        
//RecType        


//if(sub.Addl_Display_Name__c.Substring(0,2) == 'PO')
//{
//sub.QAS_Mailing_Record_Type__c = 'P';
//}

//UpdateCounty
     if(sub.QAS_Mailing_County__c == 'DISTRICT OF COLUMBIA')
     {
      sub.County__c = 'WASHINGTON';
     }
     else
     {
     sub.County__c = sub.QAS_Mailing_County__c;
     }
     if(sub.QAS_Billing_County__c == 'DISTRICT OF COLUMBIA')
     {
      sub.Billing_County__c = 'WASHINGTON';
     }
     else
     {
     sub.Billing_County__c = sub.QAS_Billing_County__c;
     }

//CopyMailingtoBilling
//          if(sub.Copy_Address_to_Billing__c == TRUE)
  //        {
    //        sub.Billing_Addl_Display_Name__c = sub.Addl_Display_Name__c;
      //      sub.Billing_Box__c = sub.Box__c;
        //    sub.Billing_City__c = sub.City__c;
          //  sub.QAS_Billing_Country__c = sub.QAS_Mailing_Country__c;
            //sub.QAS_Billing_County__c = sub.QAS_Mailing_County__c;
            //sub.Billing_State__c = sub.State__c;
            //sub.QAS_Billing_Street_Direction__c = sub.QAS_Mailing_Street_Direction__c;
          //  sub.Billing_Street_Name__c = sub.Street_Name__c;
          //  sub.Billing_Street_Number__c = sub.Street_Number__c;
            //sub.Billing_Street_Number_Suffix__c = sub.Street_Number_Suffix__c;
          //  sub.QAS_Billing_Street_Type__c = sub.QAS_Mailing_Street_Type__c;
          //  sub.Billing_Unit_Number__c = sub.Unit__c;
          //  sub.QAS_Billing_Unit_Type__c = sub.QAS_Mailing_Unit_Type__c;
          //  sub.Billing_Zip__c = sub.Zip__c;
          //  sub.Billing_Zip_4__c = sub.Zip_4__c;
         //  }
//POBox COde

if((null!=sub.Addl_Display_Name__c) && (sub.Addl_Display_Name__c.Substring(0,2) == 'PO'))
{
sub.QAS_Mailing_POBox__c = sub.Addl_Display_Name__c;
     sub.Street_Type__c = NULL;
     sub.Street_Direction__c = NULL;
     sub.Unit_Type__c = NULL;
sub.QAS_Mailing_Record_Type__c = 'P';
}
else
{
     sub.Addl_Display_Name__c = NULL;
     sub.QAS_Mailing_Record_Type__c = NULL;
     sub.QAS_Mailing_POBox__c = NULL;
}

   //  if(sub.QAS_Mailing_Record_Type__c == 'P')
   //  {
   //  sub.Addl_Display_Name__c = sub.QAS_Mailing_POBox__c;
    // sub.Street_Type__c = '';
    // sub.Street_Direction__c = '';
    // sub.Unit_Type__c = '';
    // }
    // else
    // sub.Addl_Display_Name__c = ' ';
         
if((null!=sub.Billing_Addl_Display_Name__c) && (sub.Billing_Addl_Display_Name__c.Substring(0,2) == 'PO'))
{
sub.QAS_Billing_POBox__c = sub.Billing_Addl_Display_Name__c;
     sub.Billing_Street_Type__c = NULL;
     sub.Billing_Street_Direction__c = NULL;
     sub.Billing_Unit_Type__c = NULL;
sub.QAS_Billing_Record_Type__c = 'P';
}
else
{
     sub.Billing_Addl_Display_Name__c = NULL;
     sub.QAS_Billing_Record_Type__c = NULL;
     sub.QAS_Billing_POBox__c = NULL;
}
      
    // if(sub.QAS_Billing_Record_Type__c == 'P')
    // {
    // sub.Billing_Addl_Display_Name__c = sub.QAS_Billing_POBox__c;
    // sub.Billing_Street_Type__c = '';
    // sub.Billing_Street_Direction__c = '';
    // sub.Billing_Unit_Type__c = '';
    // }
   //  else
   //  {
    // sub.Billing_Addl_Display_Name__c = ' ';
    // }
    
//Street Direction Update

                 if(sub.QAS_Mailing_Street_Direction__c == NULL)
                 {
                   sub.Street_Direction__c = '';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'N')
                 {
                   sub.Street_Direction__c = 'N, NORTH';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'E')
                 {
                   sub.Street_Direction__c = 'E, EAST';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'S')
                 {
                   sub.Street_Direction__c = 'S, SOUTH';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'W')
                 {
                   sub.Street_Direction__c = 'W, WEST';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'NE')
                 {
                   sub.Street_Direction__c = 'NE, NORTHEAST';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'SE')
                 {
                   sub.Street_Direction__c = 'SE, SOUTHEAST';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'NW')
                 {
                   sub.Street_Direction__c = 'NW, NORTHWEST';
                 }
                 if(sub.QAS_Mailing_Street_Direction__c == 'SW')
                 {
                   sub.Street_Direction__c = 'SW, SOUTHWEST';
                 }
                   
//Street Type Update
                 if(sub.QAS_Mailing_Street_Type__c == 'BLFS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }      
                 if(sub.QAS_Mailing_Street_Type__c == 'BRKS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BGS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CTRS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CIRS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CLF') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CMNS')                                                   
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CVS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'DRS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'EXTS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }                                
                 if(sub.QAS_Mailing_Street_Type__c == 'FLT') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }    
                 if(sub.QAS_Mailing_Street_Type__c == 'FRDS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRGS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GDN')                                                   
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GLNS') 
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GRNS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GRVS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'HBRS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'JCTS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LGTS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LF')                                                   
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MNRS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MTWY')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'OPAS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PARK')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PKWY')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PNE')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PTS')                                                   
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PRTS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RAMP')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RPD')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RDGS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RDS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RUE')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SKWY')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SPUR')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SQS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRWY')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRAK')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRFY')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'UPAS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'UNS')                                                   
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VLYS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VLGS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'WALK')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'WAYS')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'WL')
                 {
                   sub.Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == NULL)
                 {
                   sub.Street_Type__c = '';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ST')
                 {
                   sub.Street_Type__c = 'STREET, ST';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ALY')
                 {
                   sub.Street_Type__c = 'ALLEY, ALY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ANX')
                 {
                   sub.Street_Type__c = 'ANNEX, ANX';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ARC')
                 {
                   sub.Street_Type__c = 'ARCADE, ARC';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'AVE')
                 {
                   sub.Street_Type__c = 'AVENUE, AVE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BYU')
                 {
                   sub.Street_Type__c = 'BAYOU, BYU';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BCH ')
                 {
                   sub.Street_Type__c = 'BEACH, BCH';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BLF ')
                 {
                   sub.Street_Type__c = 'BLUFF, BLF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BTM')
                 {
                   sub.Street_Type__c = 'BOTTOM, BTM';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BLVD')
                 {
                   sub.Street_Type__c = 'BOULEVARD, BLVD';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BR')
                 {
                   sub.Street_Type__c = 'BRANCH, BR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BRG')
                 {
                   sub.Street_Type__c = 'BRIDGE, BRG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BRK')
                 {
                   sub.Street_Type__c = 'BROOK, BRK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BG')
                 {
                   sub.Street_Type__c = 'BURG, BG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BYP')
                 {
                   sub.Street_Type__c = 'BYPASS, BYP';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CP')
                 {
                   sub.Street_Type__c = 'CAMP, CP';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CYN')
                 {
                   sub.Street_Type__c = 'CANYON, CYN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CPE')
                 {
                   sub.Street_Type__c = 'CAPE, CPE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CSWY')
                 {
                   sub.Street_Type__c = 'CAUSEWAY, CSWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CTR')
                 {
                   sub.Street_Type__c = 'CENTER, CTR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CIR')
                 {
                   sub.Street_Type__c = 'CIRCLE, CIR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CLFS')
                 {
                   sub.Street_Type__c = 'CLIFFS, CLFS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CLB')
                 {
                   sub.Street_Type__c = 'CLUB, CLB';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CMN')
                 {
                   sub.Street_Type__c = 'COMMON, COM';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'COR')
                 {
                   sub.Street_Type__c = 'CORNER, COR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CORS')
                 {
                   sub.Street_Type__c = 'CORNERS, CORS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CRSE')
                 {
                   sub.Street_Type__c = 'COURSE, CRSE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CT')
                 {
                   sub.Street_Type__c = 'COURT, CT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CTS')
                 {
                   sub.Street_Type__c = 'COURTS, CTS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CV')
                 {
                   sub.Street_Type__c = 'COVE, CV';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CRK')
                 {
                   sub.Street_Type__c = 'CREEK, CRK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CRES')
                 {
                   sub.Street_Type__c = 'CRESCENT, CRES';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'XING')
                 {
                   sub.Street_Type__c = 'CROSSING, XING';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'XRD')
                 {
                   sub.Street_Type__c = 'CROSSROAD, XRD';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'XRDS')
                 {
                   sub.Street_Type__c = 'CROSSROADS, XRDS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CURV')
                 {
                   sub.Street_Type__c = 'CURVE, CURV';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'DL')
                 {
                   sub.Street_Type__c = 'DALE, DL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'DM')
                 {
                   sub.Street_Type__c = 'DAM, DM';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'DV')
                 {
                   sub.Street_Type__c = 'DIVIDE, DV';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'DR')
                 {
                   sub.Street_Type__c = 'DRIVE, DR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'EST')
                 {
                   sub.Street_Type__c = 'ESTATE, EST';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ESTS')
                 {
                   sub.Street_Type__c = 'ESTATES, ESTS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'EXPY')
                 {
                   sub.Street_Type__c = 'EXPRESSWAY, EXPY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'EXT')
                 {
                   sub.Street_Type__c = 'EXTENSION, EXT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FALL')
                 {
                   sub.Street_Type__c = 'FALL, FL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FLS')
                 {
                   sub.Street_Type__c = 'FALLS, FLS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRY')
                 {
                   sub.Street_Type__c = 'FERRY, FRY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FLD')
                 {
                   sub.Street_Type__c = 'FIELD, FLD';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FLDS')
                 {
                   sub.Street_Type__c = 'FIELDS, FLDS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FLTS')
                 {
                   sub.Street_Type__c = 'FLATS, FLT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRD')
                 {
                   sub.Street_Type__c = 'FORD, FRD';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRST')
                 {
                   sub.Street_Type__c = 'FOREST, FRST';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRG')
                 {
                   sub.Street_Type__c = 'FORGE, FRG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRK')
                 {
                   sub.Street_Type__c = 'FORK, FRK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRKS')
                 {
                   sub.Street_Type__c = 'FORKS, FRKS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FT')
                 {
                   sub.Street_Type__c = 'FORT, FT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FWY')
                 {
                   sub.Street_Type__c = 'FREEWAY, FWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GDNS')
                 {
                   sub.Street_Type__c = 'GARDENS, GDNS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GTWY')
                 {
                   sub.Street_Type__c = 'GATEWAY, GTWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GLN')
                 {
                   sub.Street_Type__c = 'GLEN, GLN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GRN')
                 {
                   sub.Street_Type__c = 'GREEN, GRN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GRV')
                 {
                   sub.Street_Type__c = 'GROVE, GRV';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'HBR')
                 {
                   sub.Street_Type__c = 'HARBOR, HBR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'HVN')
                 {
                   sub.Street_Type__c = 'HAVEN, HVN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'HTS')
                 {
                   sub.Street_Type__c = 'HEIGHTS, HTS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'HWY')
                 {
                   sub.Street_Type__c = 'HIGHWAY, HWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'HOLW')
                 {
                   sub.Street_Type__c = 'HOLLOW, HOLW';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'INLT')
                 {
                   sub.Street_Type__c = 'INLET, INLT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'IS')
                 {
                   sub.Street_Type__c = 'ISLAND, ISL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ISS')
                 {
                   sub.Street_Type__c = 'ISLANDS, ISS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ISLE')
                 {
                   sub.Street_Type__c = 'ISLE, ISLE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'JCT')
                 {
                   sub.Street_Type__c = 'JUNCTION, JCT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'KY')
                 {
                   sub.Street_Type__c = 'KEY, KY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'KYS')
                 {
                   sub.Street_Type__c = 'KEYS, KYS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'KNL')
                 {
                   sub.Street_Type__c = 'KNOLL, KNL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'KNLS')
                 {
                   sub.Street_Type__c = 'KNOLLS, KNLS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LK')
                 {
                   sub.Street_Type__c = 'LAKE, LK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LKS')
                 {
                   sub.Street_Type__c = 'LAKES, LKS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LAND')
                 {
                   sub.Street_Type__c = 'LAND, LAND';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LNDG')
                 {
                   sub.Street_Type__c = 'LANDING, LNDG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LN')
                 {
                   sub.Street_Type__c = 'LANE, LN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LGT')
                 {
                   sub.Street_Type__c = 'LIGHT, LGT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LCK')
                 {
                   sub.Street_Type__c = 'LOCK, LCK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LCKS')
                 {
                   sub.Street_Type__c = 'LOCKS, LCKS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LDG')
                 {
                   sub.Street_Type__c = 'LODGE, LDG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LOOP')
                 {
                   sub.Street_Type__c = 'LOOP, LOOP';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MALL')
                 {
                   sub.Street_Type__c = 'MALL, MALL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MNR')
                 {
                   sub.Street_Type__c = 'MANOR, MNR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MDW')
                 {
                   sub.Street_Type__c = 'MEADOW, MDW';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MDWS')
                 {
                   sub.Street_Type__c = 'MEADOWS, MDWS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MEWS')
                 {
                   sub.Street_Type__c = 'MEWS, MEWS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ML')
                 {
                   sub.Street_Type__c = 'MILL, ML';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MLS')
                 {
                   sub.Street_Type__c = 'MILLS, MLS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MSN')
                 {
                   sub.Street_Type__c = 'MISSION, MSN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MT')
                 {
                   sub.Street_Type__c = 'MOUNT, MT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MTN')
                 {
                   sub.Street_Type__c = 'MOUNTAIN, MTN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MTNS')
                 {
                   sub.Street_Type__c = 'MOUNTAINS, MTNS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'NCK')
                 {
                   sub.Street_Type__c = 'NECK, NCK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ORCH')
                 {
                   sub.Street_Type__c = 'ORCHARD, ORCHT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'OVAL')
                 {
                   sub.Street_Type__c = 'OVAL, OVAL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PARK')
                 {
                   sub.Street_Type__c = 'PARK, PARK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PKWY')
                 {
                   sub.Street_Type__c = 'PARKWAY, PKWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PASS')
                 {
                   sub.Street_Type__c = 'PASS, PASS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PSGE')
                 {
                   sub.Street_Type__c = 'PASSAGE, PSGE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PATH')
                 {
                   sub.Street_Type__c = 'PATH, PATH';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PIKE')
                 {
                   sub.Street_Type__c = 'PIKE, PIKE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PNES')
                 {
                   sub.Street_Type__c = 'PINES, PNES';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PL')
                 {
                   sub.Street_Type__c = 'PLACE, PL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PLN')
                 {
                   sub.Street_Type__c = 'PLAIN, PLN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PLNS')
                 {
                   sub.Street_Type__c = 'PLAINS, PLNS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PLZ')
                 {
                   sub.Street_Type__c = 'PLAZA, PLZ';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PT')
                 {
                   sub.Street_Type__c = 'POINT, PT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PRT')
                 {
                   sub.Street_Type__c = 'PORT, PRT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PR')
                 {
                   sub.Street_Type__c = 'PRAIRIE, PR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RADL')
                 {
                   sub.Street_Type__c = 'RADIAL, RADL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RNCH')
                 {
                   sub.Street_Type__c = 'RANCH, RNCH';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RPDS')
                 {
                   sub.Street_Type__c = 'RAPIDS, RPDS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RST')
                 {
                   sub.Street_Type__c = 'REST, RST';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RDG')
                 {
                   sub.Street_Type__c = 'RIDGE, RDG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RIV')
                 {
                   sub.Street_Type__c = 'RIVER, RIV';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RD')
                 {
                   sub.Street_Type__c = 'ROAD, RD';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RTE')
                 {
                   sub.Street_Type__c = 'ROUTE, RTE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'ROW')
                 {
                   sub.Street_Type__c = 'ROW, ROW';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RUN')
                 {
                   sub.Street_Type__c = 'RUN, RUN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SHL')
                 {
                   sub.Street_Type__c = 'SHOAL, SHL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SHLS')
                 {
                   sub.Street_Type__c = 'SHOALS, SHLS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SHR')
                 {
                   sub.Street_Type__c = 'SHORE, SHR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SPG')
                 {
                   sub.Street_Type__c = 'SPRING, SPG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SPGS')
                 {
                   sub.Street_Type__c = 'SPRINGS, SPGS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SPUR')
                 {
                   sub.Street_Type__c = 'SPUR, SPUR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SQ')
                 {
                   sub.Street_Type__c = 'SQUARE, SQ';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'STA')
                 {
                   sub.Street_Type__c = 'STATION, STA';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'STRA')
                 {
                   sub.Street_Type__c = 'STRAVENUE, STV';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'STRM')
                 {
                   sub.Street_Type__c = 'STREAM, STRM';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'STS')
                 {
                   sub.Street_Type__c = 'STREETS, STS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SMT')
                 {
                   sub.Street_Type__c = 'SUMMIT, SMT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TER')
                 {
                   sub.Street_Type__c = 'TERRACE, TER';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRCE')
                 {
                   sub.Street_Type__c = 'TRACE, TRCE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRL')
                 {
                   sub.Street_Type__c = 'TRAIL, TRL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRLR')
                 {
                   sub.Street_Type__c = 'TRAILER, TRLR';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TUNL')
                 {
                   sub.Street_Type__c = 'TUNNEL, TUNL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TPKE')
                 {
                   sub.Street_Type__c = 'TURNPIKE, TPKE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'UN')
                 {
                   sub.Street_Type__c = 'UNION, UN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VLY')
                 {
                   sub.Street_Type__c = 'VALLEY, VLY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VIA')
                 {
                   sub.Street_Type__c = 'VIADUCT, VIA';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VW')
                 {
                   sub.Street_Type__c = 'VIEWS, VWS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VLG')
                 {
                   sub.Street_Type__c = 'VILLAGE, VLG';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VL')
                 {
                   sub.Street_Type__c = 'VILLE, VL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'VIS')
                 {
                   sub.Street_Type__c = 'VISTA, VIS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'WALK')
                 {
                   sub.Street_Type__c = 'WALK, WALK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'WALL')
                 {
                   sub.Street_Type__c = 'WALL, WL';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'WAY')
                 {
                   sub.Street_Type__c = 'WAY, WAY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'WLS')
                 {
                   sub.Street_Type__c = 'WELLS, WLS';
                 }  
                 if(sub.QAS_Mailing_Street_Type__c == 'BLFS')
                 {
                   sub.Street_Type__c = 'BLUFFS, BLFS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BRKS')
                 {
                   sub.Street_Type__c = 'BROOKS, BRKS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'BGS')
                 {
                   sub.Street_Type__c = 'BURGS, BGS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CTRS')
                 {
                   sub.Street_Type__c = 'CENTERS, CTRS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CIRS')
                 {
                   sub.Street_Type__c = 'CIRCLES, CIRS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CLF')
                 {
                   sub.Street_Type__c = 'CLIFF, CLF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CMNS')
                 {
                   sub.Street_Type__c = 'COMMONS, CMNS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'CVS')
                 {
                   sub.Street_Type__c = 'COVES, CVS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'DRS')
                 {
                   sub.Street_Type__c = 'DRIVES, DRS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'EXTS')
                 {
                   sub.Street_Type__c = 'EXTENSIONS, EXTS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FLT')
                 {
                   sub.Street_Type__c = 'FLAT, FLT';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRDS')
                 {
                   sub.Street_Type__c = 'FORDS, FRDS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'FRGS')
                 {
                   sub.Street_Type__c = 'FORGES, FRGS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GDN')
                 {
                   sub.Street_Type__c = 'GARDEN, GDN';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GLNS')
                 {
                   sub.Street_Type__c = 'GLENS, GLNS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GRNS')
                 {
                   sub.Street_Type__c = 'GREENS, GRNS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'GRVS')
                 {
                   sub.Street_Type__c = 'GROVES, GRVS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'HBRS')
                 {
                   sub.Street_Type__c = 'HARBORS, HBRS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'JCTS')
                 {
                   sub.Street_Type__c = 'JUNCTIONS, JCTS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LGTS')
                 {
                   sub.Street_Type__c = 'LIGHTS, LGTS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'LF')
                 {
                   sub.Street_Type__c = 'LOAF, LF';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MNRS')
                 {
                   sub.Street_Type__c = 'MANORS, MNRS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'MTWY')
                 {
                   sub.Street_Type__c = 'MOTORWAY, MTWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'OPAS')
                 {
                   sub.Street_Type__c = 'OVERPASS, OPAS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PNE')
                 {
                   sub.Street_Type__c = 'PINE, PNE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PTS')
                 {
                   sub.Street_Type__c = 'POINTS, PTS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'PRTS')
                 {
                   sub.Street_Type__c = 'PORTS, PRTS ';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RAMP')
                 {
                   sub.Street_Type__c = 'RAMP, RAMP';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RPD')
                 {
                   sub.Street_Type__c = 'RAPID, RPD';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RDGS')
                 {
                   sub.Street_Type__c = 'RIDGES, RDGS ';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RDS')
                 {
                   sub.Street_Type__c = 'ROADS, RDS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'RUE')
                 {
                   sub.Street_Type__c = 'RUE, RUE';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SKWY')
                 {
                   sub.Street_Type__c = 'SKYWAY, SKWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'SQS')
                 {
                   sub.Street_Type__c = 'SQUARES, SQS';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRWY')
                 {
                   sub.Street_Type__c = 'THROUGHWAY, TRWY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRAK')
                 {
                   sub.Street_Type__c = 'TRACK, TRAK';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'TRFY')
                 {
                   sub.Street_Type__c = 'TRAFFICWAY, TRFY';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'UPAS')
                 {
                   sub.Street_Type__c = 'UNDERPASS, UPAS ';
                 }
                 if(sub.QAS_Mailing_Street_Type__c == 'UNS')
                 {
                   sub.Street_Type__c = 'UNIONS, UNS ';
                 }
                  if(sub.QAS_Mailing_Street_Type__c == 'VLYS')
                 {
                   sub.Street_Type__c = 'VALLEYS, VLYS';
                 }
                  if(sub.QAS_Mailing_Street_Type__c == 'VLGS')
                 {
                   sub.Street_Type__c = 'VILLAGES, VLGS';
                 }
                  if(sub.QAS_Mailing_Street_Type__c == 'WAYS')
                 {
                   sub.Street_Type__c = 'WAYS, WAYS';
                 }
                  if(sub.QAS_Mailing_Street_Type__c == 'WL')
                 {
                   sub.Street_Type__c = 'WELL, WL';
                 }
          
//Unit Type Update
                 if(sub.QAS_Mailing_Unit_Type__c == NULL)
                 {
                   sub.Unit_Type__c = '';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'APT')
                 {
                   sub.Unit_Type__c = 'APT, APARTMENT';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'BSMT')
                 {
                   sub.Unit_Type__c = 'BSMT, BASEMENT';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'BLDG')
                 {
                   sub.Unit_Type__c = 'BLDG, BUILDING';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'DEPT')
                 {
                   sub.Unit_Type__c = 'DEPT, DEPARTMENT';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'FL')
                 {
                   sub.Unit_Type__c = 'FL, FLOOR';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'FRNT')
                 {
                   sub.Unit_Type__c = 'FRNT, FRONT';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'HNGR')
                 {
                   sub.Unit_Type__c = 'HNGR, HANGAR';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'KEY')
                 {
                   sub.Unit_Type__c = 'KEY, KEY';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'LBBY')
                 {
                   sub.Unit_Type__c = 'LBBY, LOBBY';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'LOT')
                 {
                   sub.Unit_Type__c = 'LOT, LOT';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'LOWR')
                 {
                   sub.Unit_Type__c = 'LOWR, LOWER';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'OFC')
                 {
                   sub.Unit_Type__c = 'OFC, OFFICE';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'PH')
                 {
                   sub.Unit_Type__c = 'PH, PENTHOUSE';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'PIER')
                 {
                   sub.Unit_Type__c = 'PIER, PIER';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'REAR')
                 {
                   sub.Unit_Type__c = 'REAR, REAR';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'RM')
                 {
                   sub.Unit_Type__c = 'RM, ROOM';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'SIDE')
                 {
                   sub.Unit_Type__c = 'SIDE, SIDE';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'SLIP')
                 {
                   sub.Unit_Type__c = 'SLIP, SLIP';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'SPC')
                 {
                   sub.Unit_Type__c = 'SPC, SPACE';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'STOP')
                 {
                   sub.Unit_Type__c = 'STOP, STOP';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'STE')
                 {
                   sub.Unit_Type__c = 'STE, SUITE';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'TRLR')
                 {
                   sub.Unit_Type__c = 'TRLR, TRAILER';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'UNIT')
                 {
                   sub.Unit_Type__c = 'UNIT, UNIT';
                 }
                 if(sub.QAS_Mailing_Unit_Type__c == 'UPPR')
                 {
                   sub.Unit_Type__c = 'UPPR, UPPER';
                 }
//Billing Street Type
                 if(sub.QAS_Billing_Street_Type__c == 'BLFS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }      
                 if(sub.QAS_Billing_Street_Type__c == 'BRKS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BGS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CTRS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CIRS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CLF') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CMNS')                                                   
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CVS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'DRS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'EXTS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }                                
                 if(sub.QAS_Billing_Street_Type__c == 'FLT') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }    
                 if(sub.QAS_Billing_Street_Type__c == 'FRDS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRGS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GDN')                                                   
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GLNS') 
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GRNS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GRVS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'HBRS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'JCTS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LGTS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LF')                                                   
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MNRS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MTWY')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'OPAS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PARK')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PKWY')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PNE')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PTS')                                                   
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PRTS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RAMP')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RPD')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RDGS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RDS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RUE')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SKWY')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SPUR')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SQS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRWY')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRAK')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRFY')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'UPAS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'UNS')                                                   
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VLYS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VLGS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'WALK')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'WAYS')
                 {
                   sub.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == NULL)
                 {
                   sub.Billing_Street_Type__c = '';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ST')
                 {
                   sub.Billing_Street_Type__c = 'STREET, ST';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ALY')
                 {
                   sub.Billing_Street_Type__c = 'ALLEY, ALY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ANX')
                 {
                   sub.Billing_Street_Type__c = 'ANNEX, ANX';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ARC')
                 {
                   sub.Billing_Street_Type__c = 'ARCADE, ARC';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'AVE')
                 {
                   sub.Billing_Street_Type__c = 'AVENUE, AVE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BYU')
                 {
                   sub.Billing_Street_Type__c = 'BAYOU, BYU';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BCH ')
                 {
                   sub.Billing_Street_Type__c = 'BEACH, BCH';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BLF ')
                 {
                   sub.Billing_Street_Type__c = 'BLUFF, BLF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BTM')
                 {
                   sub.Billing_Street_Type__c = 'BOTTOM, BTM';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BLVD')
                 {
                   sub.Billing_Street_Type__c = 'BOULEVARD, BLVD';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BR')
                 {
                   sub.Billing_Street_Type__c = 'BRANCH, BR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BRG')
                 {
                   sub.Billing_Street_Type__c = 'BRIDGE, BRG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BRK')
                 {
                   sub.Billing_Street_Type__c = 'BROOK, BRK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BG')
                 {
                   sub.Billing_Street_Type__c = 'BURG, BG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BYP')
                 {
                   sub.Billing_Street_Type__c = 'BYPASS, BYP';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CP')
                 {
                   sub.Billing_Street_Type__c = 'CAMP, CP';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CYN')
                 {
                   sub.Billing_Street_Type__c = 'CANYON, CYN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CPE')
                 {
                   sub.Billing_Street_Type__c = 'CAPE, CPE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CSWY')
                 {
                   sub.Billing_Street_Type__c = 'CAUSEWAY, CSWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CTR')
                 {
                   sub.Billing_Street_Type__c = 'CENTER, CTR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CIR')
                 {
                   sub.Billing_Street_Type__c = 'CIRCLE, CIR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CLFS')
                 {
                   sub.Billing_Street_Type__c = 'CLIFFS, CLFS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CLB')
                 {
                   sub.Billing_Street_Type__c = 'CLUB, CLB';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CMN')
                 {
                   sub.Billing_Street_Type__c = 'COMMON, COM';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'COR')
                 {
                   sub.Billing_Street_Type__c = 'CORNER, COR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CORS')
                 {
                   sub.Billing_Street_Type__c = 'CORNERS, CORS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CRSE')
                 {
                   sub.Billing_Street_Type__c = 'COURSE, CRSE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CT')
                 {
                   sub.Billing_Street_Type__c = 'COURT, CT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CTS')
                 {
                   sub.Billing_Street_Type__c = 'COURTS, CTS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CV')
                 {
                   sub.Billing_Street_Type__c = 'COVE, CV';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CRK')
                 {
                   sub.Billing_Street_Type__c = 'CREEK, CRK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CRES')
                 {
                   sub.Billing_Street_Type__c = 'CRESCENT, CRES';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'XING')
                 {
                   sub.Billing_Street_Type__c = 'CROSSING, XING';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'XRD')
                 {
                   sub.Billing_Street_Type__c = 'CROSSROAD, XRD';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'XRDS')
                 {
                   sub.Billing_Street_Type__c = 'CROSSROADS, XRDS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CURV')
                 {
                   sub.Billing_Street_Type__c = 'CURVE, CURV';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'DL')
                 {
                   sub.Billing_Street_Type__c = 'DALE, DL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'DM')
                 {
                   sub.Billing_Street_Type__c = 'DAM, DM';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'DV')
                 {
                   sub.Billing_Street_Type__c = 'DIVIDE, DV';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'DR')
                 {
                   sub.Billing_Street_Type__c = 'DRIVE, DR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'EST')
                 {
                   sub.Billing_Street_Type__c = 'ESTATE, EST';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ESTS')
                 {
                   sub.Billing_Street_Type__c = 'ESTATES, ESTS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'EXPY')
                 {
                   sub.Billing_Street_Type__c = 'EXPRESSWAY, EXPY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'EXT')
                 {
                   sub.Billing_Street_Type__c = 'EXTENSION, EXT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FALL')
                 {
                   sub.Billing_Street_Type__c = 'FALL, FL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FLS')
                 {
                   sub.Billing_Street_Type__c = 'FALLS, FLS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRY')
                 {
                   sub.Billing_Street_Type__c = 'FERRY, FRY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FLD')
                 {
                   sub.Billing_Street_Type__c = 'FIELD, FLD';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FLDS')
                 {
                   sub.Billing_Street_Type__c = 'FIELDS, FLDS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FLTS')
                 {
                   sub.Billing_Street_Type__c = 'FLATS, FLT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRD')
                 {
                   sub.Billing_Street_Type__c = 'FORD, FRD';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRST')
                 {
                   sub.Billing_Street_Type__c = 'FOREST, FRST';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRG')
                 {
                   sub.Billing_Street_Type__c = 'FORGE, FRG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRK')
                 {
                   sub.Billing_Street_Type__c = 'FORK, FRK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRKS')
                 {
                   sub.Billing_Street_Type__c = 'FORKS, FRKS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FT')
                 {
                   sub.Billing_Street_Type__c = 'FORT, FT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FWY')
                 {
                   sub.Billing_Street_Type__c = 'FREEWAY, FWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GDNS')
                 {
                   sub.Billing_Street_Type__c = 'GARDENS, GDNS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GTWY')
                 {
                   sub.Billing_Street_Type__c = 'GATEWAY, GTWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GLN')
                 {
                   sub.Billing_Street_Type__c = 'GLEN, GLN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GRN')
                 {
                   sub.Billing_Street_Type__c = 'GREEN, GRN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GRV')
                 {
                   sub.Billing_Street_Type__c = 'GROVE, GRV';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'HBR')
                 {
                   sub.Billing_Street_Type__c = 'HARBOR, HBR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'HVN')
                 {
                   sub.Billing_Street_Type__c = 'HAVEN, HVN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'HTS')
                 {
                   sub.Billing_Street_Type__c = 'HEIGHTS, HTS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'HWY')
                 {
                   sub.Billing_Street_Type__c = 'HIGHWAY, HWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'HOLW')
                 {
                   sub.Billing_Street_Type__c = 'HOLLOW, HOLW';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'INLT')
                 {
                   sub.Billing_Street_Type__c = 'INLET, INLT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'IS')
                 {
                   sub.Billing_Street_Type__c = 'ISLAND, ISL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ISS')
                 {
                   sub.Billing_Street_Type__c = 'ISLANDS, ISS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ISLE')
                 {
                   sub.Billing_Street_Type__c = 'ISLE, ISLE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'JCT')
                 {
                   sub.Billing_Street_Type__c = 'JUNCTION, JCT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'KY')
                 {
                   sub.Billing_Street_Type__c = 'KEY, KY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'KYS')
                 {
                   sub.Billing_Street_Type__c = 'KEYS, KYS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'KNL')
                 {
                   sub.Billing_Street_Type__c = 'KNOLL, KNL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'KNLS')
                 {
                   sub.Billing_Street_Type__c = 'KNOLLS, KNLS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LK')
                 {
                   sub.Billing_Street_Type__c = 'LAKE, LK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LKS')
                 {
                   sub.Billing_Street_Type__c = 'LAKES, LKS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LAND')
                 {
                   sub.Billing_Street_Type__c = 'LAND, LAND';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LNDG')
                 {
                   sub.Billing_Street_Type__c = 'LANDING, LNDG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LN')
                 {
                   sub.Billing_Street_Type__c = 'LANE, LN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LGT')
                 {
                   sub.Billing_Street_Type__c = 'LIGHT, LGT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LCK')
                 {
                   sub.Billing_Street_Type__c = 'LOCK, LCK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LCKS')
                 {
                   sub.Billing_Street_Type__c = 'LOCKS, LCKS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LDG')
                 {
                   sub.Billing_Street_Type__c = 'LODGE, LDG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LOOP')
                 {
                   sub.Billing_Street_Type__c = 'LOOP, LOOP';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MALL')
                 {
                   sub.Billing_Street_Type__c = 'MALL, MALL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MNR')
                 {
                   sub.Billing_Street_Type__c = 'MANOR, MNR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MDW')
                 {
                   sub.Billing_Street_Type__c = 'MEADOW, MDW';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MDWS')
                 {
                   sub.Billing_Street_Type__c = 'MEADOWS, MDWS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MEWS')
                 {
                   sub.Billing_Street_Type__c = 'MEWS, MEWS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ML')
                 {
                   sub.Billing_Street_Type__c = 'MILL, ML';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MLS')
                 {
                   sub.Billing_Street_Type__c = 'MILLS, MLS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MSN')
                 {
                   sub.Billing_Street_Type__c = 'MISSION, MSN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MT')
                 {
                   sub.Billing_Street_Type__c = 'MOUNT, MT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MTN')
                 {
                   sub.Billing_Street_Type__c = 'MOUNTAIN, MTN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MTNS')
                 {
                   sub.Billing_Street_Type__c = 'MOUNTAINS, MTNS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'NCK')
                 {
                   sub.Billing_Street_Type__c = 'NECK, NCK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ORCH')
                 {
                   sub.Billing_Street_Type__c = 'ORCHARD, ORCHT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'OVAL')
                 {
                   sub.Billing_Street_Type__c = 'OVAL, OVAL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PARK')
                 {
                   sub.Billing_Street_Type__c = 'PARK, PARK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PKWY')
                 {
                   sub.Billing_Street_Type__c = 'PARKWAY, PKWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PASS')
                 {
                   sub.Billing_Street_Type__c = 'PASS, PASS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PSGE')
                 {
                   sub.Billing_Street_Type__c = 'PASSAGE, PSGE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PATH')
                 {
                   sub.Billing_Street_Type__c = 'PATH, PATH';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PIKE')
                 {
                   sub.Billing_Street_Type__c = 'PIKE, PIKE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PNES')
                 {
                   sub.Billing_Street_Type__c = 'PINES, PNES';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PL')
                 {
                   sub.Billing_Street_Type__c = 'PLACE, PL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PLN')
                 {
                   sub.Billing_Street_Type__c = 'PLAIN, PLN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PLNS')
                 {
                   sub.Billing_Street_Type__c = 'PLAINS, PLNS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PLZ')
                 {
                   sub.Billing_Street_Type__c = 'PLAZA, PLZ';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PT')
                 {
                   sub.Billing_Street_Type__c = 'POINT, PT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PRT')
                 {
                   sub.Billing_Street_Type__c = 'PORT, PRT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PR')
                 {
                   sub.Billing_Street_Type__c = 'PRAIRIE, PR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RADL')
                 {
                   sub.Billing_Street_Type__c = 'RADIAL, RADL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RNCH')
                 {
                   sub.Billing_Street_Type__c = 'RANCH, RNCH';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RPDS')
                 {
                   sub.Billing_Street_Type__c = 'RAPIDS, RPDS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RST')
                 {
                   sub.Billing_Street_Type__c = 'REST, RST';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RDG')
                 {
                   sub.Billing_Street_Type__c = 'RIDGE, RDG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RIV')
                 {
                   sub.Billing_Street_Type__c = 'RIVER, RIV';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RD')
                 {
                   sub.Billing_Street_Type__c = 'ROAD, RD';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RTE')
                 {
                   sub.Billing_Street_Type__c = 'ROUTE, RTE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'ROW')
                 {
                   sub.Billing_Street_Type__c = 'ROW, ROW';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RUN')
                 {
                   sub.Billing_Street_Type__c = 'RUN, RUN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SHL')
                 {
                   sub.Billing_Street_Type__c = 'SHOAL, SHL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SHLS')
                 {
                   sub.Billing_Street_Type__c = 'SHOALS, SHLS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SHR')
                 {
                   sub.Billing_Street_Type__c = 'SHORE, SHR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SPG')
                 {
                   sub.Billing_Street_Type__c = 'SPRING, SPG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SPGS')
                 {
                   sub.Billing_Street_Type__c = 'SPRINGS, SPGS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SPUR')
                 {
                   sub.Billing_Street_Type__c = 'SPUR, SPUR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SQ')
                 {
                   sub.Billing_Street_Type__c = 'SQUARE, SQ';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'STA')
                 {
                   sub.Billing_Street_Type__c = 'STATION, STA';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'STRA')
                 {
                   sub.Billing_Street_Type__c = 'STRAVENUE, STV';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'STRM')
                 {
                   sub.Billing_Street_Type__c = 'STREAM, STRM';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'STS')
                 {
                   sub.Billing_Street_Type__c = 'STREETS, STS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SMT')
                 {
                   sub.Billing_Street_Type__c = 'SUMMIT, SMT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TER')
                 {
                   sub.Billing_Street_Type__c = 'TERRACE, TER';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRCE')
                 {
                   sub.Billing_Street_Type__c = 'TRACE, TRCE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRL')
                 {
                   sub.Billing_Street_Type__c = 'TRAIL, TRL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRLR')
                 {
                   sub.Billing_Street_Type__c = 'TRAILER, TRLR';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TUNL')
                 {
                   sub.Billing_Street_Type__c = 'TUNNEL, TUNL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TPKE')
                 {
                   sub.Billing_Street_Type__c = 'TURNPIKE, TPKE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'UN')
                 {
                   sub.Billing_Street_Type__c = 'UNION, UN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VLY')
                 {
                   sub.Billing_Street_Type__c = 'VALLEY, VLY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VIA')
                 {
                   sub.Billing_Street_Type__c = 'VIADUCT, VIA';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VW')
                 {
                   sub.Billing_Street_Type__c = 'VIEWS, VWS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VLG')
                 {
                   sub.Billing_Street_Type__c = 'VILLAGE, VLG';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VL')
                 {
                   sub.Billing_Street_Type__c = 'VILLE, VL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'VIS')
                 {
                   sub.Billing_Street_Type__c = 'VISTA, VIS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'WALK')
                 {
                   sub.Billing_Street_Type__c = 'WALK, WALK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'WALL')
                 {
                   sub.Billing_Street_Type__c = 'WALL, WL';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'WAY')
                 {
                   sub.Billing_Street_Type__c = 'WAY, WAY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'WLS')
                 {
                   sub.Billing_Street_Type__c = 'WELLS, WLS';
                 }  
                 if(sub.QAS_Billing_Street_Type__c == 'BLFS')
                 {
                   sub.Billing_Street_Type__c = 'BLUFFS, BLFS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BRKS')
                 {
                   sub.Billing_Street_Type__c = 'BROOKS, BRKS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'BGS')
                 {
                   sub.Billing_Street_Type__c = 'BURGS, BGS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CTRS')
                 {
                   sub.Billing_Street_Type__c = 'CENTERS, CTRS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CIRS')
                 {
                   sub.Billing_Street_Type__c = 'CIRCLES, CIRS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CLF')
                 {
                   sub.Billing_Street_Type__c = 'CLIFF, CLF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CMNS')
                 {
                   sub.Billing_Street_Type__c = 'COMMONS, CMNS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'CVS')
                 {
                   sub.Billing_Street_Type__c = 'COVES, CVS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'DRS')
                 {
                   sub.Billing_Street_Type__c = 'DRIVES, DRS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'EXTS')
                 {
                   sub.Billing_Street_Type__c = 'EXTENSIONS, EXTS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FLT')
                 {
                   sub.Billing_Street_Type__c = 'FLAT, FLT';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRDS')
                 {
                   sub.Billing_Street_Type__c = 'FORDS, FRDS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'FRGS')
                 {
                   sub.Billing_Street_Type__c = 'FORGES, FRGS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GDN')
                 {
                   sub.Billing_Street_Type__c = 'GARDEN, GDN';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GLNS')
                 {
                   sub.Billing_Street_Type__c = 'GLENS, GLNS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GRNS')
                 {
                   sub.Billing_Street_Type__c = 'GREENS, GRNS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'GRVS')
                 {
                   sub.Billing_Street_Type__c = 'GROVES, GRVS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'HBRS')
                 {
                   sub.Billing_Street_Type__c = 'HARBORS, HBRS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'JCTS')
                 {
                   sub.Billing_Street_Type__c = 'JUNCTIONS, JCTS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LGTS')
                 {
                   sub.Billing_Street_Type__c = 'LIGHTS, LGTS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'LF')
                 {
                   sub.Billing_Street_Type__c = 'LOAF, LF';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MNRS')
                 {
                   sub.Billing_Street_Type__c = 'MANORS, MNRS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'MTWY')
                 {
                   sub.Billing_Street_Type__c = 'MOTORWAY, MTWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'OPAS')
                 {
                   sub.Billing_Street_Type__c = 'OVERPASS, OPAS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PNE')
                 {
                   sub.Billing_Street_Type__c = 'PINE, PNE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PTS')
                 {
                   sub.Billing_Street_Type__c = 'POINTS, PTS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'PRTS')
                 {
                   sub.Billing_Street_Type__c = 'PORTS, PRTS ';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RAMP')
                 {
                   sub.Billing_Street_Type__c = 'RAMP, RAMP';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RPD')
                 {
                   sub.Billing_Street_Type__c = 'RAPID, RPD';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RDGS')
                 {
                   sub.Billing_Street_Type__c = 'RIDGES, RDGS ';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RDS')
                 {
                   sub.Billing_Street_Type__c = 'ROADS, RDS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'RUE')
                 {
                   sub.Billing_Street_Type__c = 'RUE, RUE';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SKWY')
                 {
                   sub.Billing_Street_Type__c = 'SKYWAY, SKWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'SQS')
                 {
                   sub.Billing_Street_Type__c = 'SQUARES, SQS';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRWY')
                 {
                   sub.Billing_Street_Type__c = 'THROUGHWAY, TRWY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRAK')
                 {
                   sub.Billing_Street_Type__c = 'TRACK, TRAK';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'TRFY')
                 {
                   sub.Billing_Street_Type__c = 'TRAFFICWAY, TRFY';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'UPAS')
                 {
                   sub.Billing_Street_Type__c = 'UNDERPASS, UPAS ';
                 }
                 if(sub.QAS_Billing_Street_Type__c == 'UNS')
                 {
                   sub.Billing_Street_Type__c = 'UNIONS, UNS ';
                 }
                  if(sub.QAS_Billing_Street_Type__c == 'VLYS')
                 {
                   sub.Billing_Street_Type__c = 'VALLEYS, VLYS';
                 }
                  if(sub.QAS_Billing_Street_Type__c == 'VLGS')
                 {
                   sub.Billing_Street_Type__c = 'VILLAGES, VLGS';
                 }
                  if(sub.QAS_Billing_Street_Type__c == 'WAYS')
                 {
                   sub.Billing_Street_Type__c = 'WAYS, WAYS';
                 }
                  if(sub.QAS_Billing_Street_Type__c == 'WL')
                 {
                   sub.Billing_Street_Type__c = 'WELL, WL';
                 }
//Billing Street Direction
                 if(sub.QAS_Billing_Street_Direction__c == NULL)
                 {
                   sub.Billing_Street_Direction__c = '';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'N')
                 {
                   sub.Billing_Street_Direction__c = 'N, NORTH';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'E')
                 {
                   sub.Billing_Street_Direction__c = 'E, EAST';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'S')
                 {
                   sub.Billing_Street_Direction__c = 'S, SOUTH';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'W')
                 {
                   sub.Billing_Street_Direction__c = 'W, WEST';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'NE')
                 {
                   sub.Billing_Street_Direction__c = 'NE, NORTHEAST';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'SE')
                 {
                   sub.Billing_Street_Direction__c = 'SE, SOUTHEAST';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'NW')
                 {
                   sub.Billing_Street_Direction__c = 'NW, NORTHWEST';
                 }
                 if(sub.QAS_Billing_Street_Direction__c == 'SW')
                 {
                   sub.Billing_Street_Direction__c = 'SW, SOUTHWEST';
                 }
//Billing Unit Type
                 if(sub.QAS_Billing_Unit_Type__c == NULL)
                 {
                   sub.Billing_Unit_Type__c = '';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'APT')
                 {
                   sub.Billing_Unit_Type__c = 'APT, APARTMENT';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'BSMT')
                 {
                   sub.Billing_Unit_Type__c = 'BSMT, BASEMENT';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'BLDG')
                 {
                   sub.Billing_Unit_Type__c = 'BLDG, BUILDING';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'DEPT')
                 {
                   sub.Billing_Unit_Type__c = 'DEPT, DEPARTMENT';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'FL')
                 {
                   sub.Billing_Unit_Type__c = 'FL, FLOOR';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'FRNT')
                 {
                   sub.Billing_Unit_Type__c = 'FRNT, FRONT';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'HNGR')
                 {
                   sub.Billing_Unit_Type__c = 'HNGR, HANGAR';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'KEY')
                 {
                   sub.Billing_Unit_Type__c = 'KEY, KEY';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'LBBY')
                 {
                   sub.Billing_Unit_Type__c = 'LBBY, LOBBY';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'LOT')
                 {
                   sub.Billing_Unit_Type__c = 'LOT, LOT';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'LOWR')
                 {
                   sub.Billing_Unit_Type__c = 'LOWR, LOWER';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'OFC')
                 {
                   sub.Billing_Unit_Type__c = 'OFC, OFFICE';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'PH')
                 {
                   sub.Billing_Unit_Type__c = 'PH, PENTHOUSE';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'PIER')
                 {
                   sub.Billing_Unit_Type__c = 'PIER, PIER';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'REAR')
                 {
                   sub.Billing_Unit_Type__c = 'REAR, REAR';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'RM')
                 {
                   sub.Billing_Unit_Type__c = 'RM, ROOM';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'SIDE')
                 {
                   sub.Billing_Unit_Type__c = 'SIDE, SIDE';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'SLIP')
                 {
                   sub.Billing_Unit_Type__c = 'SLIP, SLIP';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'SPC')
                 {
                   sub.Billing_Unit_Type__c = 'SPC, SPACE';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'STOP')
                 {
                   sub.Billing_Unit_Type__c = 'STOP, STOP';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'STE')
                 {
                   sub.Billing_Unit_Type__c = 'STE, SUITE';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'TRLR')
                 {
                   sub.Billing_Unit_Type__c = 'TRLR, TRAILER';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'UNIT')
                 {
                   sub.Billing_Unit_Type__c = 'UNIT, UNIT';
                 }
                 if(sub.QAS_Billing_Unit_Type__c == 'UPPR')
                 {
                   sub.Billing_Unit_Type__c = 'UPPR, UPPER';
                 }

        if(sub.Copy_Address_to_Billing__c == true)
        {
            sub.Billing_Addl_Display_Name__c = sub.Addl_Display_Name__c;
            sub.Billing_Box__c = sub.Box__c;
            sub.Billing_City__c = sub.City__c;
            sub.QAS_Billing_Country__c = sub.QAS_Mailing_Country__c;
            sub.QAS_Billing_County__c = sub.QAS_Mailing_County__c;
            sub.Billing_State__c = sub.State__c;
            sub.QAS_Billing_Street_Direction__c = sub.QAS_Mailing_Street_Direction__c;
            sub.Billing_Street_Name__c = sub.Street_Name__c;
            sub.Billing_Street_Number__c = sub.Street_Number__c;
            //sub.Billing_Street_Number_Suffix__c = sub.Street_Number_Suffix__c;
            sub.QAS_Billing_Street_Type__c = sub.QAS_Mailing_Street_Type__c;
            sub.Billing_Unit_Number__c = sub.Unit__c;
            sub.QAS_Billing_Unit_Type__c = sub.QAS_Mailing_Unit_Type__c;
            sub.Billing_Zip__c = sub.Zip__c;
            sub.Billing_Zip_4__c = sub.Zip_4__c;
          }
          
          String zip4s = sub.Zip_4__c + '';
          String bzip4s = sub.Billing_Zip_4__c + '';
          
          if(zip4s.length() != 0 && zip4s.length() != 4) 
          {
              error=true;
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Zip-4 must have 0 or 4 digits'));
          }
          
          if(bzip4s.length() != 0 && bzip4s.length() != 4)
          {
              error=true;
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Billing Zip-4 must have 0 or 4 digits'));
          }
        
          String apS = sub.Agent_Office_Phone__c + '';
          String faxS = sub.Fax__c + '';
          String homefaxS = sub.Home_Fax__c + '';
          String mobileS = sub.Mobile_Phone__c + '';
          String primPhoneS = sub.Primary_Phone__c + '';
          String voicemailS = sub.Voicemail__c + '';
          String pagerS = sub.Pager__c + '';
         /* 
         if(aps.length() != 4 && aps.length() != 14)
         {
             error=true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Agent Office Phone must have 0 or 10 digits.'));
         }
         if(faxs.length() != 4 && faxs.length() != 14)
         {
             error=true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Agent Office Fax must have 0 or 10 digits.'));
         }
         if(homefaxs.length() != 4 && homefaxs.length() != 14)
         {
             error=true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Home Fax must have 0 or 10 digits.'));
         }
         if(mobiles.length() != 4 && mobiles.length() != 14)
         {
             error=true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Mobile Phone must have 10 digits.'));
         }
         if(primphones.length() != 4 && primphones.length() != 14)
         {
             error=true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Primary Phone must have 10 digits.'));
         }
         if(voicemails.length() != 4 && voicemails.length() != 14)
         {
             error=true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Voicemail must have 0 or 10 digits.'));
         }
         if(pagers.length() != 4 && pagers.length() != 14)
         {
             error=true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Pager must have 0 or 10 digits.'));
         }
        */
         if (sub.name == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Subscription name'));
         } 
         /*if (sub.Related_Location_Broker_Office__c == null){
          error=true;
          sub.Related_Location_Broker_Office__c.addError('Related Location Broker Office must be defined');
         }*/
         if(sub.Public_Email__c == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Public Email'));
         }
         if(sub.Primary_Phone__c == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Primary Phone'));
         }
         if(sub.Mobile_Phone__c == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Mobile Phone'));
         }
         if(sub.Zip__c == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Zip'));
         }
         if(sub.City__c == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'City'));
         }
         if(sub.State__c == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'State'));
         }
        /* if(sub.County__c == null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'County'));
        } */
         if(sub.QAS_Billing_County__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Billing County'));                    
         }
          if(sub.QAS_Billing_Country__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Billing Country'));  
         }
            
         if(sub.QAS_Mailing_County__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Mailing County'));                    
         }
          if(sub.QAS_Mailing_Country__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Mailing Country')); 
          }                  
         if(sub.Private_Email__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Private Email'));          
         }
         if(sub.Billing_City__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Billing City'));          
         }
         if(sub.Billing_State__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Billing State'));          
         }
         if(sub.Billing_Zip__c== null){
          error=true;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,commonError+'Billing Zip'));          
         }
         
        if(!error){
        try
        {
            System.debug('con..........'+con);
            update con;
            update sub;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your account is successfully updated'));
        }
        catch (DmlException ex)
          {
              String messak = ex.getMessage();
              messak = messak.substring(messak.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+34,messak.length()-3);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,messak)); 
          }
          catch (Exception ex)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Operation failed due to some Internal Error ')); 
                System.debug('ex........'+ex);
            }
        }
        
       return null;
    }
    public void reset() {
        /*PageReference pageRef = ApexPages.currentPage();
        pageRef.getParameters().clear();
        pageRef.setRedirect(true);
        return pageRef;*/
        //return new ApexPages.StandardController(con).view();
        PageReference p = ApexPages.currentPage();
        p.setRedirect(true);
        getSub();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The Page has been Reset'));
      //  return p;
    }
    
      /* 
    static testMethod void myaccountTest()
    {
        
        CornerstoneAddrUtility c = new CornerstoneAddrUtility();
        c.addAddrs();
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        Test.startTest();
     
        //Create an Account
        Account acc = new Account();
        acc.Name = 'TEST321';
        acc.Account_Name__c = 'Testing Account';
        acc.type = 'Residential';
        acc.Company_Type__c = 'Branch Office';
        acc.Shareholder_Board__c = 'No';
        acc.Street_Number__c = '6824';
        acc.Street_Name__c = 'Dean';
        acc.Zip__c = '22101';
        acc.City__c = 'Herndon';
        acc.State__c = 'VA';
        acc.County__c = 'Fairfax';
        acc.Country__c = 'UNITED STATES';
        acc.Phone = '5559991234';
        insert(acc);
        
       
        
        Account a12 = new Account();
        a12.name = 'ABC1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.company_type__c = 'Corporate Office';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';
        insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);       
        

        Account acc = new Account();
        acc.Name = 'CASE323';
        acc.Account_Name__c = 'Testing Account';
        acc.type = 'Residential';
        acc.Company_Type__c = 'Broker Office';
        acc.Shareholder_Board__c = 'None';
        acc.Street_Number__c = '6824';
        acc.Street_Name__c = 'Dean';
        //acc.Street_Type__c = 'DRIVE, DR';
        acc.Zip__c = '22101';
        acc.City__c = 'Herndon';
        acc.State__c = 'VA';
        acc.Country__c = 'UNITED STATES';
        acc.Phone = '5559991234';
        acc.Company_Type__c = 
        acc.Status__c = 'In Progress';
        acc.QAS_Mailing_County__c = 'Fairfax';
        acc.County__c = 'Fairfax';

        acc.parentid = a12.id;
        
        insert acc; 
        System.debug('Tester After acc Insert ID: ---> ' + acc.id);           
        
        
        
        
        //Create a Contact
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Tom';
        c1.LastName = 'Horton';
        c1.Status__c = 'Active';
        c1.Public_Email__c = 'thorton@rainmaker-llc.com';
        c1.Phone = '7037393328';
        c1.City__c = 'Herndon';
        c1.State__c = 'VA';
        c1.County__c = 'Fairfax';
        c1.Zip__c = '20171';  
        c1.Account = acc;          
        insert(c1);
       
        
        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.AgentKey__c = '123456789';
        s1.Name = '7000163';
       // s1.Primary__c = true;
        s1.City__c = 'Herndon';
        s1.County__c = 'Fairfax';
        s1.State__c = 'VA';
        s1.Public_Email__c = 'sub1@subs.com';
        s1.Primary_Phone__c = '3213213211';
        s1.Mobile_Phone__c = '4444999888';
        s1.Voicemail__c = '2342344231';
        s1.Zip__c = '20171';
        s1.Contact__c = c1.Id;
        s1.Related_Location_Broker_Office__c = acc.id;
        s1.Contact_Type__c = 'Agent';
        s1.Status__c = 'Active';
        insert(s1);
        
        Subscription_Role__c sr3 = new Subscription_Role__c ();
        sr3.Role__c = 'Status Duplicate';
        sr3.Status__c = 'Active';
        sr3.sysPrRoleKey__c = '89752575777';
        sr3.Subscription__c = s1.id;
        insert sr3;              
        
        update(c1);
        
        Subscriptions__c s2 = new Subscriptions__c();
        s2.AgentKey__c = '987654321';
        s2.Name = '7000164';
        //s2.Primary__c = false;
        s2.Status__c = 'Active';
        s2.City__c = 'Herndon';
        s2.State__c = 'VA';
        s2.Public_Email__c = 'sub2@subs.com';
        s2.Primary_Phone__c = '(321)-321-3211';
        s2.Mobile_Phone__c = '(444)-999-8888';
        s2.Voicemail__c = '(234)-234-4231';
        s2.County__c = 'Fairfax';
        s2.Zip__c = '20171';
        s2.Contact__c = c1.Id;
        s2.Related_Location_Broker_Office__c = acc.id;
        s2.Contact_Type__c = 'Agent';
        insert(s2);
        
        Subscription_Role__c sr2 = new Subscription_Role__c ();
        sr2.Role__c = 'Status Duplicate';
        sr2.Status__c = 'Active';
        sr2.sysPrRoleKey__c = '89752575777';
        sr2.Subscription__c = s2.id;
        insert sr2;             
        
        update(c1);

        List<Subscriptions__c> c1s1 = [SELECT name FROM Subscriptions__c WHERE Contact__c =: c1.id];

        for(integer i = 0 ; i < c1s1.size() ; i++)
        {
            System.debug('value of contact sub name: ' + c1s1[i].name);        
        }
        
        System.debug('value of sub: ' + s1);
        
        PageReference pg = Page.myaccount;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('contact', c1.id);        
        ApexPages.currentPage().getParameters().put('subscription', c1s1[0].name);

        myaccController con = new myaccController();
        
        con.getContact();
        con.getContactID();
        con.getSub();
        con.getData();
        con.getPrimarySub();
        con.getAllSubs();
        con.getSub().zip__c = '32123';
        con.save();
        con.reset();
        
        con.getSub().Copy_Address_to_Billing__c = true;
        con.save();
        
        con.getSub().Primary__c = false;
        con.save();
        

        try{
            con.getSub().Zip_4__c = '12';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Billing_Zip_4__c = '12';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Agent_Office_Phone__c = '123';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Fax__c = '123';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Public_Email__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Home_Fax__c = '123';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Mobile_Phone__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Primary_Phone__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }
        
        try{
            con.getSub().Primary_Phone__c = '13';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Voicemail__c = '123';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Pager__c = '123';
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().name = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Zip__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().City__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().County__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }
        
        try{
            con.getSub().State__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        try{
            con.getSub().Country__c = null;
            con.save();
        }catch(Exception e){
            System.assertNotEquals(e, null);
        }

        c1s1[0].Primary__c = false;
        
        ApexPages.currentPage().getParameters().put('subscription', c1s1[0].name);        
        con.getSub();

        ApexPages.currentPage().getParameters().put('subscription', '');        
        con.getSub();
               
        Test.stopTest();
    } */
}