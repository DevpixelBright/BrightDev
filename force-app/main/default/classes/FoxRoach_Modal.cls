/***********************************************************************************************
*       Class Name      : FoxRoach_Modal
*       Date            : 10/13/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Apex Class is used for wraper(custom structure) needed for FoxRoach
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/13/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_Modal 
{
    public class Language
    {
        public decimal id;
        public string name;
        public string description;
    }
    public class Address
    {
        public string address1;
        public string address2;
        public string city;
        public string stateOrProvince;
        public string postalCode;
        public string country;
    }
    public class Account
    {
        public decimal id;
        public decimal companyID;
        public string title;
        public string userName;
        public string firstName;
        public string lastName;
        public string email;
        public Address address;
        public list<PhoneNumber> phoneNumbers;
        //public boolean accountOnHOldFlag;
        //public boolean nonParticipating;
        //public decimal siteManagementCode;
        public string inactiveDate;
        public string lastUpdateDate;
        public string insertDate;
        //public list<Language> languages;
        //public string primaryDomain;
        //public string primarySubdomain;
        public decimal officeID;
        public decimal primaryOfficeID;
        public string licenseNbr;
        public string officeName;
        public string officeText;
        //public string alternateOfficeIDs;
        //public string alternateOfficeNames;
        //public string photoUrl;
        //public boolean hasPhoto;
        //public decimal roleID;
        public string roleName;
        public string franchiseAgentCode;
        //public boolean isStaff;
        //public boolean hasWebsite;
        public string legacyFranchiseAgentCode;
        //public string geoCodeLat;
        //public string geoCodeLong;
        //public string geoCodeRound4Combo;
        //public decimal accountType;
        //public boolean bioCompanyActiveFlag;
        //public boolean bioAccountActiveFlag;
        //public string languagesString;
        //public string specialtiesString;
        //public string bioText;
        //public string externalWebsiteUrl;
        //public list<string> listingAgentIdentifiers;
        //public string socialMediaCollection;
        public string licenseInfo;
        public string officePhone;
        //public boolean showOnRosterOffice;
        //public boolean showOnRosterAccount;
        //public string testimonialTreeRating;
        public decimal totalCount;
        public string team;
        public string teamRelationship;
        public string teamAccountID;
        //public string team_2;
        //public string teamRelationship_2;
        //public string teamAccountID_2;
        //public string team_3;
        //public string teamRelationship_3;
        //public string teamAccountID_3;
        //public string rosterAttributes;
        public string appCode;
        //public list<string> preferredPartner;
    }
    public class Membership
    {
        public decimal mlsID;
        public string membershipID;
    }
    public class PhoneNumber
    {
        public string label;
        public string phoneNumber;
    }
    public class Geocode
    {
        public string latitude;
        public string longitude;
    }
    public class Office
    {
        public decimal id;
        public string name;
        public string email;
        public string franchiseCode;
        public Address address;
        public Geocode geocode;
        public PhoneNumber phoneNumber;
        public string photoUrl;
        public string primaryDomain;
        public list<Membership> mlsMemberships;
        public string userID;
        public decimal geoCodeRound4Combo;
        public string lastUpdateDate;
        public string insertDate;
    }
}