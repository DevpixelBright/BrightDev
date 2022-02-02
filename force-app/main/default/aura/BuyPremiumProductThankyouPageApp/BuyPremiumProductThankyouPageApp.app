<!--<aura:application access="global" extends="ltng:outApp">
	<c:BuyPremiumProductThankyouPage />
</aura:application>-->
<aura:application extends="ltng:outApp" access="GLOBAL" implements="ltng:allowGuestAccess">
    <aura:dependency resource="c:BuyPremiumProductThankyouPage" type="COMPONENT"/>
</aura:application>