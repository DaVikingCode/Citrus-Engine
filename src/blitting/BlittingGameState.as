package blitting {

	import com.citrusengine.core.State;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.box2d.Hero;
	import com.citrusengine.objects.platformer.box2d.Platform;
	import com.citrusengine.physics.box2d.Box2D;
	import com.citrusengine.view.CitrusView;
	import com.citrusengine.view.blittingview.AnimationSequence;
	import com.citrusengine.view.blittingview.BlittingArt;
	import com.citrusengine.view.blittingview.BlittingView;

	import flash.geom.Rectangle;

	/**
	 * @author Aymeric
	 */
	public class BlittingGameState extends State {

		// embed your graphics
		[Embed(source = '/../embed/hero_idle.png')]
		private var _heroIdleClass:Class;
		
		[Embed(source = '/../embed/hero_walk.png')]
		private var _heroWalkClass:Class;
		
		[Embed(source = '/../embed/hero_jump.png')]
		private var _heroJumpClass:Class;
		
		[Embed(source = '/../embed/bg_hills.png')]
		private var _hillsClass:Class;

		public function BlittingGameState() {
			super();
		}

		override public function initialize():void {
			
			super.initialize();

			var box2D:Box2D = new Box2D("box2D");
			//box2D.visible = true;
			add(box2D);

			add(new Platform("P1", {x:320, y:400, width:2000, height:20}));

			// You can quickly create a graphic by passing the embedded class into a new blitting art object.
			add(new CitrusSprite("Hills", {parallax:0.5, view:new BlittingArt(_hillsClass)}));

			// Set up your game object's animations like this;
			var heroArt:BlittingArt = new BlittingArt();
			heroArt.addAnimation(new AnimationSequence(_heroIdleClass, "idle", 40, 40, true, true));
			heroArt.addAnimation(new AnimationSequence(_heroWalkClass, "walk", 40, 40, true, true));
			heroArt.addAnimation(new AnimationSequence(_heroJumpClass, "jump", 40, 40, false, true));

			// pass the blitting art object into the view.
			var hero:Hero = new Hero("Hero", {x:320, y:150, view:heroArt});
			add(hero);

			view.setupCamera(hero, new MathVector(320, 240), new Rectangle(0, 0, 1200, 400));

			// If you update any properties on the state's view, call updateCanvas() afterwards.
			view.cameraLensWidth = 800;
			view.cameraLensHeight = 400;
			BlittingView(view).backgroundColor = 0xffffcc88;
			BlittingView(view).updateCanvas(); // Don't forget to call this
		}

		// Make sure and call this override to specify Blitting mode.
		override protected function createView():CitrusView {
			
			return new BlittingView(this);
		}
	}
}
