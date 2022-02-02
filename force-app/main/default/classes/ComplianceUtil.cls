global without sharing class ComplianceUtil {

   /*
    *  return the fine amount based on the fine code
    */
   global static double fineCode2amt(String fCode) {
      double fAmt = 0.0;
      if (fCode == null)                { fAmt = 0.00;
      } else if (fCode == 'QCDATA0')    { fAmt = 0.00;
      } else if (fCode == 'QCDATA')     { fAmt = 50.00;
      } else if (fCode == 'QCDATA1')    { fAmt = 100.00;
      } else if (fCode == 'QCDATA2')    { fAmt = 200.00;
      } else if (fCode == 'QCDATA5')    { fAmt = 500.00;
      } else if (fCode == 'QCDATA1000') { fAmt = 1000.00;
      } else if (fCode == 'QCDATA2000') { fAmt = 2000.00;
      } else if (fCode == 'CRDATA')     { fAmt = -50.00;
      } else if (fCode == 'CRDATA1')    { fAmt = -100.00;
      } else if (fCode == 'CRDATA15')   { fAmt = -150.00;
      } else if (fCode == 'CRDATA2')    { fAmt = -200.00;
      } else if (fCode == 'CRDATA25')   { fAmt = -250.00;
      } else if (fCode == 'CRDATA3')    { fAmt = -300.00;
      } else if (fCode == 'CRDATA35')   { fAmt = -350.00;
      } else if (fCode == 'CRDATA5')    { fAmt = -500.00;
      } else if (fCode == 'CRDATA55')   { fAmt = -550.00;
      } else if (fCode == 'CRDATA6')    { fAmt = -600.00;
      } else if (fCode == 'CRDATA65')   { fAmt = -650.00;
      } else if (fCode == 'CRDATA7')    { fAmt = -700.00;
      } else if (fCode == 'CRDATA75')   { fAmt = -750.00;
      } else if (fCode == 'CRDATA8')    { fAmt = -800.00;
      } else if (fCode == 'CRDATA85')   { fAmt = -850.00;
      } else if (fCode == 'CRDATA9')    { fAmt = -900.00;
      } else if (fCode == 'CRDATA95')   { fAmt = -950.00;
      } else if (fCode == 'CRDATA1000') { fAmt = -1000.00;
      } else if (fCode == 'CRDATA2000') { fAmt = -2000.00;
      } else if (fCode == 'CRDATA3000') { fAmt = -3000.00;
      }
      return fAmt;
   }
   
   /*
    *  mapping for violation text
    */
   global static String violation2customer(String v1) {
      String v2 = v1;
      if (v1 == '90 Day Sold Data Check') {v2 = 'Inaccurate Sold Information';
//    } else if (v1 == 'Branded Virtual Tour') {v2 = 'Branded Virtual Tour';
//    } else if (v1 == 'Delinquent APP REG Status') {v2 = 'Delinquent APP REG Status';
//    } else if (v1 == 'Delinquent Conting Expir Date') {v2 = 'Delinquent Conting Expir Date';
//    } else if (v1 == 'Delinquent Settlement Date') {v2 = 'Delinquent Settlement Date';
//    } else if (v1 == 'DOM Manipulation') {v2 = 'DOM Manipulation';
      } else if (v1 == 'Duplicate Listing Check') {v2 = 'Duplicate Listing';
//    } else if (v1 == 'Excessive Bedrooms') {v2 = 'Excessive Bedrooms';
//    } else if (v1 == 'Excessive Full Baths') {v2 = 'Excessive Full Baths';
//    } else if (v1 == 'Excessive Half Baths') {v2 = 'Excessive Half Baths';
//    } else if (v1 == 'Fair Housing') {v2 = 'Fair Housing';
      } else if (v1 == 'Fair Housing SI') {v2 = 'Fair Housing';
      } else if (v1 == 'General Compliancy') {v2 = 'Compliance Violation';
//    } else if (v1 == 'Inaccurate CNTG Expir Date') {v2 = 'Inaccurate CNTG Expir Date';
//    } else if (v1 == 'Inaccurate Condo Fee') {v2 = 'Inaccurate Condo Fee';
      } else if (v1 == 'Inaccurate Ownership') {v2 = 'Inaccurate Ownership Type';
//    } else if (v1 == 'Inaccurate Sales Price') {v2 = 'Inaccurate Sales Price';
//    } else if (v1 == 'Inappropriate Address Information') {v2 = 'Inappropriate Address Information';
//    } else if (v1 == 'Inappropriate Direction Info') {v2 = 'Inappropriate Direction Info';
//    } else if (v1 == 'Inappropriate Photos') {v2 = 'Inappropriate Photos';
//    } else if (v1 == 'Inappropriate Remark Info') {v2 = 'Inappropriate Remark Info';
//    } else if (v1 == 'Incorrect Address') {v2 = 'Incorrect Address';
//    } else if (v1 == 'Incorrect Status') {v2 = 'Incorrect Status';
      } else if (v1 == 'Incorrect Status SI') {v2 = 'Incorrect Status';
//    } else if (v1 == 'Late Listing Input') {v2 = 'Late Listing Input';
//    } else if (v1 == 'No Compensation Offered') {v2 = 'No Compensation Offered';
//    } else if (v1 == 'No Photo') {v2 = 'No Photo';
//    } else if (v1 == 'Not Available for Showing') {v2 = 'Not Available for Showing';
      } else if (v1 == 'Not Available for Showing  SI') {v2 = 'Not Available for Showing';
      } else if (v1 == 'PRK Null') {v2 = 'No Tax ID number';
      } else if (v1 == 'Recurring Violations 11plus Fee') {v2 = 'Recurring Violations Fee (11 or More Violations)';
      } else if (v1 == 'Recurring Violations 4 to10 Fee') {v2 = 'Recurring Violations Fee (4 to10 Violations)';
//    } else if (v1 == 'Rental Entered as Sale Listing') {v2 = 'Rental Entered as Sale Listing';
//    } else if (v1 == 'Sale of Business') {v2 = 'Sale of Business';
      } else if (v1 == 'TEMP OFF Status greater than 21 Days') {v2 = 'Delinquent TEMP OFF Status';
      }
      return v2;
   }
}