package entity {

	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.core.State;
	import com.citrusengine.objects.platformer.box2d.Platform;
	import com.citrusengine.physics.box2d.Box2D;
	import com.citrusengine.system.Entity;
	import com.citrusengine.system.components.InputComponent;
	import com.citrusengine.system.components.box2d.hero.HeroCollisionComponent;
	import com.citrusengine.system.components.box2d.hero.HeroMovementComponent;
	import com.citrusengine.system.components.box2d.hero.HeroViewComponent;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;


	/**
	 * @author Aymeric
	 */
	public class EntityGameState extends State {
		
		private var _heroEntity:Entity;
		private var _view:HeroViewComponent;
		private var _physics:DraggableHeroPhysicsComponent;

		public function EntityGameState() {
			
			super();
		}

		override public function initialize():void {
			
			super.initialize();
			
			var box2d:Box2D = new Box2D("box2D");
			//box2d.visible = true;
			add(box2d);
			
			_heroEntity = new Entity("heroEntity");
			
			_physics = new DraggableHeroPhysicsComponent("physics", {x:200, y:270, width:40, height:60, entity:_heroEntity});
			var input:InputComponent = new InputComponent("input", {entity:_heroEntity});
			var collision:HeroCollisionComponent = new HeroCollisionComponent("collision", {entity:_heroEntity});
			var move:HeroMovementComponent = new HeroMovementComponent("move", {entity:_heroEntity});
			_view = new HeroViewComponent("view", {view:"PatchSpriteArt.swf", entity:_heroEntity});
			
			_heroEntity.add(_physics).add(input).add(collision).add(move).add(_view);
			_heroEntity.initialize();
			
			addEntity(_heroEntity, _view);
			
			var draggableHeroArt:DisplayObject = view.getArt(_view) as DisplayObject;
			draggableHeroArt.addEventListener(MouseEvent.MOUSE_DOWN, _handleGrab);

			stage.addEventListener(MouseEvent.MOUSE_UP, _handleRelease);
			
			add(new Platform("platform", {x:600, y:350, width:1800, height:20}));
		}
		
		private function _handleGrab(mEvt:MouseEvent):void {

			var clickedObject:CitrusObject = view.getObjectFromArt(mEvt.currentTarget) as CitrusObject;

			if (clickedObject)
				_physics.enableHolding(mEvt.currentTarget.parent);
		}

		private function _handleRelease(mEvt:MouseEvent):void {
			_physics.disableHolding();
		}

	}
}
