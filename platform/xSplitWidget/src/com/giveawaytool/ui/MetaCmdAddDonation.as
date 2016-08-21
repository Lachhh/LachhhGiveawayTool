package com.giveawaytool.ui {
	import com.giveawaytool.MainGame;
	import com.giveawaytool.meta.MetaDonation;
	import com.giveawaytool.meta.MetaDonationsConfig;
	import com.giveawaytool.meta.MetaNewDonation;
	import com.lachhh.io.Callback;
	import com.lachhh.lachhhengine.ui.UIBase;
	/**
	 * @author LachhhSSD
	 */
	public class MetaCmdAddDonation extends MetaCmd{
		static public var AMOUNT_TO_TRIGGER_BIG:int = 5;
		public var metaDonation:MetaNewDonation;
		private var metaDonationConfig : MetaDonationsConfig;

		public function MetaCmdAddDonation(m:MetaNewDonation) {
			metaDonation = m;
		}

		override public function execute(pMetaConfig:MetaDonationsConfig):void {
			metaDonationConfig = pMetaConfig;
			startNewDonationAnim(metaDonation); 
		}
		
		private function startNewDonationAnim(m:MetaNewDonation):void {
			UI_News.closeAllNews();
			UI_NewTweet.closeAllTweets();
			
			var showBigAnim:Boolean = (m.amount >= AMOUNT_TO_TRIGGER_BIG);
			
			if(metaDonationConfig.metaBigGoal.willBeNewlyCompletedIfAdded(m.amount)) showBigAnim = true;
			if(metaDonationConfig.metaRecurrentGoal.willBeNewlyCompletedIfAdded(m.amount)) showBigAnim = true;
			if(!metaDonationConfig.metaBigGoal.isEnabled() && !metaDonationConfig.metaRecurrentGoal.isEnabled()) showBigAnim = false;
			
			metaDonationConfig.feedAwardsOfDonator(m);
			 
			if(showBigAnim) {
				var ui:UIDonationIntro = new UIDonationIntro(m);
				ui.callbackOnClose = new Callback(startDonationGivingBasedOnConfig, this, [m]);
			} else {
				var uiSmall:UIDonationIntroSmall = new UIDonationIntroSmall(m, metaDonationConfig);
				uiSmall.callbackOnClose = new Callback(onEndDonation, this, [m]);
			}
		}
		
		private function startDonationGivingBasedOnConfig(m:MetaNewDonation):void {
			var ui:UIDonationAdd = new UIDonationAdd(m, metaDonationConfig);
			ui.callbackOnClose = new Callback(onEndDonation, this, [m]);
		}
		
		private function onEndDonation(pMetaDonation : MetaNewDonation):void {
			var hasNewTopDonator:Boolean = (metaDonationConfig.topDonation == null || pMetaDonation.amount > metaDonationConfig.topDonation.amount);
			var uiWidget:UI_DonationWidget = UIBase.manager.getFirst(UI_DonationWidget) as UI_DonationWidget;
			
			if(hasNewTopDonator) {
				if(uiWidget) uiWidget.flashTopDonator();
			}
			
			if(uiWidget) uiWidget.flashFuel();
			metaDonationConfig.addDonation(pMetaDonation);
			MainGame.instance.createNews();
			if(uiWidget) uiWidget.refresh();
			
			var uiHalloween:UI_Charity = UIBase.manager.getFirst(UI_Charity) as UI_Charity;
			if(uiHalloween) uiHalloween.removeWaitFromDonation(pMetaDonation);
			
			endCmd();
		}
	}
}
