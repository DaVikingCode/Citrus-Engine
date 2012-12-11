package com.citrusengine.physics.nape {

	import nape.callbacks.InteractionCallback;

	import com.citrusengine.objects.NapePhysicsObject;
	
	/**
	 * This class provides some useful Nape functions.
	 */
	public class NapeUtils {
		
		/**
		 * In Nape we are blind concerning the collision, we are never sure which body is the collider. This function should help.
		 * Call this function to obtain the colliding physics object.
		 * @param self in CE's code, we give this. In your code it will be your hero, a sensor, ...
		 * @param callback the InteractionCallback
		 * @return the collider
		 */
		static public function CollisionGetOther(self:NapePhysicsObject, callback:InteractionCallback):NapePhysicsObject {
			return self == callback.int1.userData.myData ? callback.int2.userData.myData : callback.int1.userData.myData;
		}
		
		/**
		 * In Nape we are blind concerning the collision, we are never sure which body is the collider. This function should help.
		 * Call this function to obtain the collided physics object.
		 * @param self in CE's code, we give this. In your code it will be your hero, a sensor, ...
		 * @param callback the InteractionCallback
		 * @return the collided
		 */
		static public function CollisionGetSelf(self:NapePhysicsObject, callback:InteractionCallback):NapePhysicsObject {
			return self == callback.int1.userData.myData ? callback.int1.userData.myData : callback.int2.userData.myData;
		}
	}
}
