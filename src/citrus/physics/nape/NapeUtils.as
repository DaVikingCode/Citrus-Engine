package citrus.physics.nape {

	import citrus.objects.NapePhysicsObject;
	import nape.callbacks.PreCallback;
	import nape.dynamics.Arbiter;
	import nape.phys.Body;
	import nape.phys.Interactor;
	import nape.shape.Shape;

	import nape.callbacks.InteractionCallback;

	/**
	 * This class provides some useful Nape functions.
	 */
	public class NapeUtils {
		
		/**
		 * In Nape we are blind concerning the collision, we are never sure which body is the collider. This function should help.
		 * Call this function to obtain the colliding physics object.
		 * @param self in CE's code, we give this. In your code it will be your hero, a sensor, ...
		 * @param callback the InteractionCallback.
		 * @return the collider.
		 */
		static public function CollisionGetOther(self:NapePhysicsObject, callback:InteractionCallback):NapePhysicsObject {
			return self == callback.int1.userData.myData ? callback.int2.userData.myData : callback.int1.userData.myData;
		}
		
		/**
		 * In Nape we are blind concerning the collision, we are never sure which body is the collider. This function should help.
		 * Call this function to obtain the collided physics object.
		 * @param self in CE's code, we give this. In your code it will be your hero, a sensor, ...
		 * @param callback the InteractionCallback.
		 * @return the collided.
		 */
		static public function CollisionGetSelf(self:NapePhysicsObject, callback:InteractionCallback):NapePhysicsObject {
			return self == callback.int1.userData.myData ? callback.int1.userData.myData : callback.int2.userData.myData;
		}
		
		/**
		 * Similar to CollisionGetOther but for PreCallbacks.
		 * @param self in CE's code, we give this. In your code it will be your hero, a sensor, ...
		 * @param callback the PreCallback.
		 * @return the collider.
		 */
		static public function PreCollisionGetOther(self:NapePhysicsObject, callback:PreCallback):NapePhysicsObject {
			return self == callback.int1.userData.myData ? callback.int2.userData.myData : callback.int1.userData.myData;
		}
		
		/**
		 * Similar to CollisionGetSelf but for PreCallbacks.
		 * @param self in CE's code, we give this. In your code it will be your hero, a sensor, ...
		 * @param callback the PreCallback.
		 * @return the collided.
		 */
		static public function PreCollisionGetSelf(self:NapePhysicsObject, callback:PreCallback):NapePhysicsObject {
			return self == callback.int1.userData.myData ? callback.int1.userData.myData : callback.int2.userData.myData;
		}
		
		/**
		 * get the Interactor object in which self is NOT involved.
		 * @param	self
		 * @param	callback
		 * @return
		 */
		static public function getOtherInteractor(self:NapePhysicsObject, callback:InteractionCallback):Interactor {
			return self == callback.int1.userData.myData ? callback.int2 : callback.int1;
		}
		
		/**
		 * get the Interactor object in which self is involved.
		 * @param	self
		 * @param	callback
		 * @return
		 */
		static public function getSelfInteractor(self:NapePhysicsObject, callback:InteractionCallback):Interactor {
			return self == callback.int1.userData.myData ? callback.int1 : callback.int2;
		}
		
		/**
		 * Return the shape involved in the a arbiter that is part of body.
		 * return null if body is not involved in the arbiter or if neither shape belongs to the body.
		 * @param	body
		 * @param	a
		 * @return
		 */
		static public function getShapeFromArbiter(body:Body, a:Arbiter):Shape
		{
			if (a.body1 == body || a.body2 == body)
				if (a.shape1 && a.shape1.body == body)
					return a.shape1;
				else if (a.shape2 && a.shape2.body == body)
					return a.shape2;
					
			return null;
		}
		
		/**
		 * In Nape we are blind concerning the collision, we are never sure which body is the collider. This function should help.
		 * Call this function to obtain the object of the type wanted.
		 * @param objectClass the class whose you want to pick up the object.
		 * @param callback the InteractionCallback.
		 * @return the object of the class desired.
		 */
		static public function CollisionGetObjectByType(objectClass:Class, callback:InteractionCallback):NapePhysicsObject {
			return callback.int1.userData.myData is objectClass ? callback.int1.userData.myData : callback.int2.userData.myData
		}
	}
}
