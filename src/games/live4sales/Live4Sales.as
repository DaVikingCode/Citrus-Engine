package games.live4sales {

	import Box2DAS.Common.V2;

	import games.live4sales.assets.Assets;
	import games.live4sales.characters.SalesWoman;
	import games.live4sales.characters.ShopsWoman;
	import games.live4sales.utils.Grid;

	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.StarlingState;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.view.starlingview.AnimationSequence;
	import com.citrusengine.view.starlingview.StarlingArt;
	
	/**
	 * @author Aymeric
	 */
	public class Live4Sales extends StarlingState {
		
		private var _ce:CitrusEngine;
		private var _grid:Grid;
		
		public function Live4Sales() {
			super();
		}

		override public function initialize() : void {
			
			super.initialize();
			
			var box2D:Box2D = new Box2D("box2D", {gravity:new V2()});
			//box2D.visible = true;
			add(box2D);
			
			StarlingArt.setLoopAnimations(["stand", "attack"]);
			
			var background:CitrusSprite = new CitrusSprite("background", {view:Image.fromBitmap(new Assets.BackgroundPng())});
			add(background);
			
			_grid = new Grid();
			addChild(_grid);
			
			_ce = CitrusEngine.getInstance();
			_ce.starling.stage.addEventListener(TouchEvent.TOUCH, _touchEvent);
		}

		private function _touchEvent(tEvt:TouchEvent):void {
			
				var touchStart:Touch = tEvt.getTouch(_ce.starling.stage, TouchPhase.BEGAN);
				var touchEnd:Touch = tEvt.getTouch(_ce.starling.stage, TouchPhase.ENDED);
				
				if (touchStart) {
					
				} else if (touchEnd) {
					
					//trace(_grid.casePosition(touchEnd.globalX, touchEnd.globalY));
					var casePositions:Array = Grid.getCaseCenter(touchEnd.globalX, touchEnd.globalY);
					
					if (casePositions[0]!=0 && casePositions[1]!=0)
					{
						var saleswomanAnim:AnimationSequence = new AnimationSequence(Assets.getTextureAtlas("Defenders"), ["attack", "stand"], "attack", 30, true);
						var saleswoman:SalesWoman = new SalesWoman("saleswoman", {x:casePositions[0], y:casePositions[1], group:casePositions[2], offsetY:-saleswomanAnim.height * 0.3, fireRate:1000, missileExplodeDuration:0, missileFuseDuration:3000, view:saleswomanAnim});
						add(saleswoman);
						
						var shopswoman:ShopsWoman = new ShopsWoman("shopswoman", {x:450, y:casePositions[1], speed:1});
						add(shopswoman);
						shopswoman.onTouchLeftSide.add(_endGame);
						
					} else trace('no');
					
				}
		}

		private function _endGame():void {
			
			trace('game over');
		}

	}
}
