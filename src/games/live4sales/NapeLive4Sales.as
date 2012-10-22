package games.live4sales {

	import games.live4sales.assets.Assets;
	import games.live4sales.events.MoneyEvent;
	import games.live4sales.nape.characters.SalesWoman;
	import games.live4sales.nape.characters.ShopsWoman;
	import games.live4sales.nape.objects.Block;
	import games.live4sales.nape.objects.Cash;
	import games.live4sales.runtime.CoinsCreation;
	import games.live4sales.runtime.nape.BaddiesCreation;
	import games.live4sales.ui.Hud;
	import games.live4sales.utils.Grid;

	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;

	import starling.core.Starling;
	import starling.display.Image;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.StarlingState;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.physics.nape.Nape;
	import com.citrusengine.view.starlingview.AnimationSequence;
	import com.citrusengine.view.starlingview.StarlingArt;
	
	/**
	 * @author Aymeric
	 */
	public class NapeLive4Sales extends StarlingState {

		private var _ce:CitrusEngine;
		private var _hud:Hud;
		private var _coinsCreation:CoinsCreation;
		private var _baddiesCreation:BaddiesCreation;

		public function NapeLive4Sales() {
			
			super();

			_ce = CitrusEngine.getInstance();
		}

		override public function initialize():void {
			
			super.initialize();

			Assets.contentScaleFactor = Starling.current.contentScaleFactor;

			var nape:Nape = new Nape("nape", {gravity:new Vec2()});
			//nape.visible = true;
			add(nape);
			
			nape.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, ShopsWoman.SHOPSWOMAN, CbType.ANY_BODY, nape.contactListener.onInteractionBegin));
			nape.space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, ShopsWoman.SHOPSWOMAN, CbType.ANY_BODY, nape.contactListener.onInteractionEnd));
			
			_hud = new Hud();
			addChild(_hud);
			_hud.onIconePositioned.add(_createObject);

			_coinsCreation = new CoinsCreation();
			addChild(_coinsCreation);

			StarlingArt.setLoopAnimations(["stand", "fire", "attack", "walk"]);

			var background:CitrusSprite = new CitrusSprite("background", {view:Image.fromBitmap(new Assets.BackgroundPng())});
			add(background);

			_baddiesCreation = new BaddiesCreation();
		}
			
		override public function destroy():void {
			
			_hud.destroy();
			removeChild(_hud, true);
			
			_coinsCreation.destroy();
			removeChild(_coinsCreation, true);
			
			_baddiesCreation.destroy();
			
			super.destroy();
		}

		private function _createObject(name:String, posX:uint, posY:uint):void {
			
			if (Hud.money >= 50) {
				
				var casePositions:Array = Grid.getCaseCenter(posX, posY);

				if (casePositions[0] != 0 && casePositions[1] != 0) {
					
					if (name == "SalesWoman") {
						
						var saleswomanAnim:AnimationSequence = new AnimationSequence(Assets.getTextureAtlas("Objects"), ["fire", "stand"], "fire", 30, true);
						var saleswoman:SalesWoman = new SalesWoman("saleswoman", {x:casePositions[0], y:casePositions[1], group:casePositions[2], offsetY:-saleswomanAnim.height * 0.3, fireRate:1000, missileExplodeDuration:0, missileFuseDuration:3000, view:saleswomanAnim});
						add(saleswoman);
						
					} else if (name == "Block") {
						
						var blockAnimation:AnimationSequence = new AnimationSequence(Assets.getTextureAtlas("Objects"), ["block1", "block2", "block3", "blockDestroyed"], "block1");
						var block:Block = new Block("block", {x:casePositions[0], y:casePositions[1], group:casePositions[2], offsetY:-15, view:blockAnimation});
						add(block);
						
					} else if (name == "Cash") {
						
						var cash:Cash = new Cash("cash", {x:casePositions[0], y:casePositions[1], group:casePositions[2], offsetY:-15, view:new Image(Assets.getAtlasTexture("cash", "Objects"))});
						add(cash);
					}

					_ce.dispatchEvent(new MoneyEvent(MoneyEvent.BUY_ITEM));
					
				} else trace('case not empty');
				
			} else trace('no money');
		}
	}
}
