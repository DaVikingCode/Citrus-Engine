package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// A body definition holds all the data needed to construct a rigid body.
	/// You can safely re-use body definitions.
	/// Shapes are added to a body after construction.
	public class b2BodyDef extends b2Base {
		
		public function b2BodyDef() {
			_ptr = lib.b2BodyDef_new(this);
			position = new b2Vec2(_ptr + 4);
			linearVelocity = new b2Vec2(_ptr + 16);
		}
		
		public function create(w:b2World):b2Body {
			return new b2Body(w, this);
		}
		
		public override function destroy():void {
			lib.b2BodyDef_delete(_ptr);
			super.destroy();
		}
		
		/// Use this to store application specific body data.
		public var userData:*;

		/// The world position of the body. Avoid creating bodies at the origin
		/// since this can lead to many overlapping shapes.
		public var position:b2Vec2;

		/// The linear velocity of the body in world co-ordinates.
		public var linearVelocity:b2Vec2;

		/// The world angle of the body in radians.
		public function get angle():Number { return mem._mrf(_ptr + 12); }
		public function set angle(v:Number):void { mem._mwf(_ptr + 12, v); }

		/// The angular velocity of the body.
		public function get angularVelocity():Number { return mem._mrf(_ptr + 24); }
		public function set angularVelocity(v:Number):void { mem._mwf(_ptr + 24, v); }

		/// Linear damping is use to reduce the linear velocity. The damping parameter
		/// can be larger than 1.0f but the damping effect becomes sensitive to the
		/// time step when the damping parameter is large.
		public function get linearDamping():Number { return mem._mrf(_ptr + 28); }
		public function set linearDamping(v:Number):void { mem._mwf(_ptr + 28, v); }

		/// Angular damping is use to reduce the angular velocity. The damping parameter
		/// can be larger than 1.0f but the damping effect becomes sensitive to the
		/// time step when the damping parameter is large.
		public function get angularDamping():Number { return mem._mrf(_ptr + 32); }
		public function set angularDamping(v:Number):void { mem._mwf(_ptr + 32, v); }

		/// Set this flag to false if this body should never fall asleep. Note that
		/// this increases CPU usage.
		public function get allowSleep():Boolean { return mem._mru8(_ptr + 36) == 1; }
		public function set allowSleep(v:Boolean):void { mem._mw8(_ptr + 36, v ? 1 : 0); }

		/// Is this body initially sleeping?
		public function get awake():Boolean { return mem._mru8(_ptr + 37) == 1; }
		public function set awake(v:Boolean):void { mem._mw8(_ptr + 37, v ? 1 : 0); }

		/// Should this body be prevented from rotating? Useful for characters.
		public function get fixedRotation():Boolean { return mem._mru8(_ptr + 38) == 1; }
		public function set fixedRotation(v:Boolean):void { mem._mw8(_ptr + 38, v ? 1 : 0); }
	
		/// Is this a fast moving body that should be prevented from tunneling through
		/// other moving bodies? Note that all bodies are prevented from tunneling through
		/// static bodies.
		/// @warning You should use this flag sparingly since it increases processing time.
		public function get bullet():Boolean { return mem._mru8(_ptr + 39) == 1; }
		public function set bullet(v:Boolean):void { mem._mw8(_ptr + 39, v ? 1 : 0); }

		public function get type():int { return mem._mrs16(_ptr + 0); }
		public function set type(v:int):void { mem._mw16(_ptr + 0, v); }
		public function get active():Boolean { return mem._mru8(_ptr + 40) == 1; }
		public function set active(v:Boolean):void { mem._mw8(_ptr + 40, v ? 1 : 0); }
		public function get inertiaScale():Number { return mem._mrf(_ptr + 48); }
		public function set inertiaScale(v:Number):void { mem._mwf(_ptr + 48, v); }

	}
}