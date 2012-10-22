package objectpooling {

	import com.citrusengine.core.State;
	import com.citrusengine.datastructures.DoublyLinkedListNode;
	import com.citrusengine.datastructures.PoolObject;
	import com.citrusengine.objects.NapePhysicsObject;
	import com.citrusengine.objects.platformer.nape.Platform;
	import com.citrusengine.physics.nape.Nape;
	import com.citrusengine.view.spriteview.SpriteArt;
	import flash.utils.setTimeout;


	/**
	 * @author Aymeric
	 */
	public class ObjectPoolingGameState extends State {
		
		private var _poolPhysics:PoolObject;
		private var _poolGraphic:PoolObject;

		public function ObjectPoolingGameState() {
			super();
		}

		override public function initialize():void {
			
			super.initialize();
			
			var box2D:Nape = new Nape("Nape");
			box2D.visible = true;
			add(box2D);
			
			add(new Platform("platformBot", {x:0, y:380, width:4000, height:20}));
			
			// the Citrus Engine separates physics from art so we use two PoolObjects.
			// all objects in a PoolObject must have the same type.
			// PoolObject isn't render through the state, you have to manage it in your GameState.
			_poolPhysics = new PoolObject(NapePhysicsObject, 50, 5, true);
			_poolGraphic = new PoolObject(SpriteArt, 50, 5, false);
			
			for (var i:uint = 0; i < 5; ++i) {
				
				var physicsNode:DoublyLinkedListNode = _poolPhysics.create({x:i * 40 + 60, view:"crate.png"});
				addChild(_poolGraphic.create(physicsNode.data).data);
			}
			
			setTimeout(removeAndAddObjects, 3000);
		}
			
		override public function destroy():void {
			
			_poolPhysics.disposeAll();
			
			// for the graphic pool, we have to removeChild each object, it can't be made in the PoolObject since it's not a display object.
			while (_poolGraphic.head)
				removeChild(_poolGraphic.disposeNode(_poolGraphic.head).data);
			
			super.destroy();
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			// update pool objects
			_poolPhysics.updatePhysics(timeDelta);
			_poolGraphic.updateArt(view);
		}
		
		public function removeAndAddObjects():void {
			
			_poolPhysics.disposeAll();
			
			while (_poolGraphic.head)
				removeChild(_poolGraphic.disposeNode(_poolGraphic.head).data);
				
			// reassign object
			for (var i:uint = 0; i < 7; ++i) {
				var physicsNode:DoublyLinkedListNode = _poolPhysics.create({x:i * 40 + 150, view:"crate.png"});
				addChild(_poolGraphic.create(physicsNode.data).data);
			}
			
		}

	}
}
