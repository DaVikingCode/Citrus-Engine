package games.live4sales {

	import com.citrusengine.objects.platformer.box2d.Hero;
	import Box2DAS.Common.V2;

	import games.live4sales.assets.Assets;

	import starling.display.Image;

	import com.citrusengine.core.StarlingState;
	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.view.starlingview.AnimationSequence;
	import com.citrusengine.view.starlingview.StarlingArt;
	
	/**
	 * @author Aymeric
	 */
	public class Live4Sales extends StarlingState {
		
		private var _grid:Grid;
		
		public function Live4Sales() {
			super();
		}

		override public function initialize() : void {
			
			super.initialize();
			
			var box2D:Box2D = new Box2D("box2D", {gravity:new V2()});
			//box2D.visible = true;
			add(box2D);
			
			var background:CitrusSprite = new CitrusSprite("background", {view:Image.fromBitmap(new Assets.BackgroundPng())});
			add(background);
			
			var saleswomanAnim:AnimationSequence = new AnimationSequence(Assets.getTextureAtlas("Defenders"), ["attack", "stand"], "attack", 30, true);
			StarlingArt.setLoopAnimations(["stand"]);
			
			var saleswoman:Hero = new Hero("hero", {x:200, y:200, width:30, height:60, view:saleswomanAnim});
			add(saleswoman);
			
			_grid = new Grid();
			addChild(_grid);
		}

	}
}
