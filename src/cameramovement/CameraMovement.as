package cameramovement {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.State;
	import com.citrusengine.math.MathUtils;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.platformer.box2d.Hero;
	import com.citrusengine.objects.platformer.box2d.Platform;
	import com.citrusengine.physics.box2d.Box2D;

	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	/**
	 * @author Aymeric
	 */
	public class CameraMovement extends State {

		public function CameraMovement() {
			super();
		}

		override public function initialize():void {
			
			super.initialize();

			var box2d:Box2D = new Box2D("box2D", {visible:true});
			box2d.group = 0; // box2d debug view will be behind graphics, default is 1 : can't work on Starling, since the debug view is on the display list
			add(box2d);

			var hero:Hero = new Hero("hero", {x:100, view:"PatchSpriteArt.swf", width:60, height:120, offsetY:15});
			add(hero);

			add(new Platform("platBot", {x:stage.stageWidth / 2, y:stage.stageHeight, width:3000}));
			add(new Platform("cloud", {x:450, y:250, width:200, oneWay:true}));

			view.setupCamera(hero, new MathVector(stage.stageWidth / 2, stage.stageHeight / 2), new Rectangle(0, 0, 1550, 450), new MathVector(.25, .05));

			stage.addEventListener(MouseEvent.MOUSE_WHEEL, _mouseWheel);
		}

		override public function destroy():void {

			stage.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseWheel);

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
			
			if (CitrusEngine.getInstance().input.isDown(Keyboard.R)) {
				
				// if you use Starling, just move the pivot point!
				
				MathUtils.RotateAroundInternalPoint(this, new Point(stage.stageWidth / 2, stage.stageHeight / 2), 1);
				
				view.cameraOffset = new MathVector(stage.stageWidth / 2, stage.stageHeight / 2);
				view.cameraBounds = new Rectangle(0, 0, 1550, 450);
			}
		}
		
		private function _mouseWheel(mEvt:MouseEvent):void {
			
			scaleX = mEvt.delta > 0 ? scaleX + 0.03 : scaleX - 0.03;
			scaleY = scaleX;
			
			view.cameraOffset = new MathVector(stage.stageWidth / 2 / scaleX, stage.stageHeight / 2 / scaleY);
			view.cameraBounds = new Rectangle(0, 0, 1550 * scaleX, 450 * scaleY);
		}
	}
}
