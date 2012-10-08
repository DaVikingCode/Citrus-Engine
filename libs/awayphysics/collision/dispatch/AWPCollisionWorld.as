package awayphysics.collision.dispatch {
	import awayphysics.AWPBase;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	
	public class AWPCollisionWorld extends AWPBase{
		
		protected var m_collisionObjects : Vector.<AWPCollisionObject>;
		
		public function AWPCollisionWorld(){
			m_collisionObjects =  new Vector.<AWPCollisionObject>();
		}
		
		public function get collisionObjects() : Vector.<AWPCollisionObject> {
			return m_collisionObjects;
		}
		
		/**
		 * add a collisionObject to collision world
		 */
		public function addCollisionObject(obj:AWPCollisionObject, group:int = 1, mask:int = -1):void{
			if(m_collisionObjects.indexOf(obj) < 0){
				m_collisionObjects.push(obj);
				bullet.addCollisionObjectMethod(obj.pointer, group, mask);
			}
		}
		
		/**
		 * remove a collisionObject from collision world, if cleanup is true, release pointer in memory.
		 */
		public function removeCollisionObject(obj:AWPCollisionObject, cleanup:Boolean = false) : void {
			
			if(m_collisionObjects.indexOf(obj) >= 0) {
				m_collisionObjects.splice(m_collisionObjects.indexOf(obj), 1);
				bullet.removeCollisionObjectMethod(obj.pointer);
				
				if (cleanup) {
					obj.dispose();
				}
			}
		}
	}
}