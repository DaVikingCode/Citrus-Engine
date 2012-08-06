package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// A fixture definition is used to create a fixture. This class defines an
	/// abstract fixture definition. You can reuse fixture definitions safely.
	public class b2FixtureDef extends b2Base {
		
		/// The constructor sets the default fixture definition values.
		public function b2FixtureDef() {
			_ptr = lib.b2FixtureDef_new(this);
			filter = new b2Filter(_ptr + 26);
		}
		
		public override function destroy():void {
			lib.b2FixtureDef_delete(_ptr);
			super.destroy();
		}
		
		public function create(b:b2Body):b2Fixture {
			return new b2Fixture(b, this);
		}

		/// The shape, this must be set. The shape will be cloned, so you
		/// can create the shape on the stack.	
		public var _shape:b2Shape;
		public function get shape():b2Shape { return _shape; }
		public function set shape(v:b2Shape):void { mem._mw32(_ptr + 4, v ? v._ptr : 0); _shape = v; }

		/// Use this to store application specific fixture data.
		public var userData:*;
		
		/// The friction coefficient, usually in the range [0,1].
		public function get friction():Number { return mem._mrf(_ptr + 12); }
		public function set friction(v:Number):void { mem._mwf(_ptr + 12, v); }
		
		/// The restitution (elasticity) usually in the range [0,1].
		public function get restitution():Number { return mem._mrf(_ptr + 16); }
		public function set restitution(v:Number):void { mem._mwf(_ptr + 16, v); }
		
		/// The density, usually in kg/m^2.
		public function get density():Number { return mem._mrf(_ptr + 20); }
		public function set density(v:Number):void { mem._mwf(_ptr + 20, v); }
		
		/// A sensor shape collects contact information but never generates a collision
		/// response.
		public function get isSensor():Boolean { return mem._mru8(_ptr + 24) == 1; }
		public function set isSensor(v:Boolean):void { mem._mw8(_ptr + 24, v ? 1 : 0); }
		
		/// Contact filtering data.
		public var filter:b2Filter;
	
	}
}