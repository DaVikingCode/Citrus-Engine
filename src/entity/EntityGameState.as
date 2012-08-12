package entity {

	import com.citrusengine.core.State;
	import com.citrusengine.objects.platformer.box2d.Platform;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.system.Entity;
	import com.citrusengine.system.components.InputComponent;
	import com.citrusengine.system.components.box2d.hero.HeroCollisionComponent;
	import com.citrusengine.system.components.box2d.hero.HeroMovementComponent;
	import com.citrusengine.system.components.box2d.hero.HeroPhysicsComponent;
	import com.citrusengine.system.components.box2d.hero.HeroViewComponent;

	/**
	 * @author Aymeric
	 */
	public class EntityGameState extends State {
		
		private var heroEntity:Entity;
		private var input:InputComponent;
		private var _view:HeroViewComponent;
		private var physics:HeroPhysicsComponent;

		public function EntityGameState() {
			
			super();
		}

		override public function initialize():void {
			
			super.initialize();
			
			var box2d:Box2D = new Box2D("box2D");
			box2d.visible = true;
			add(box2d);
			
			heroEntity = new Entity("heroEntity");
			
			physics = new HeroPhysicsComponent("physics", {x:200, y:270, width:40, height:60, entity:heroEntity});
			input = new InputComponent("input", {entity:heroEntity});
			var collision:HeroCollisionComponent = new HeroCollisionComponent("collision", {entity:heroEntity});
			var move:HeroMovementComponent = new HeroMovementComponent("move", {entity:heroEntity});
			_view = new HeroViewComponent("view", {view:"Patch.swf", entity:heroEntity});
			
			heroEntity.add(physics).add(input).add(collision).add(move).add(_view);
			heroEntity.initialize();
			
			addEntity(heroEntity, _view);
			
			add(new Platform("platform", {x:600, y:350, width:1800, height:20}));
		}

	}
}
