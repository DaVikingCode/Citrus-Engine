package Box2DAS.Controllers {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.utils.*;

	public class b2Controller {
		
		public var effect:b2Effect;
		public var storage:Dictionary = new Dictionary();
		public var world:b2World;
		public var allBodies:Boolean = false;
		public var priority:int = 0;
		
		public function b2Controller(w:b2World = null, e:b2Effect = null, all:Boolean = false) {
			effect = e;
			allBodies = all;
			if(w) {
				world = w;
				w.AddController(this);
			}
		}
		
		public function destroy():void {
			world.RemoveController(this);
			world = null;
		}
		
		public function toString():String {
			return GetBodies().toString();
		}
		
		public function GetBodies():Array {
			var b:Array = [];
			for(var i:* in storage) {
				b.push(i);
			}
			return b;
		}
		
		public function AddBody(body:b2Body):void {
			storage[body] ||= 0;
			storage[body]++;
			body.m_controllers[this] = true;
		}
		
		public function RemoveBody(body:b2Body):void {
			if(storage[body]) {
				storage[body]--;
				if(storage[body] == 0) {
					delete storage[body];
					delete body.m_controllers[this];
				}
			}
		}
		
		public function Step(e:StepEvent = null):void {
			if(effect) {
				if(allBodies) {
					for(var b:b2Body = world.m_bodyList; b; b = b.m_next) {
						effect.Apply(b);
					}
				}
				else {
					for(var i:* in storage) {
						effect.Apply(i as b2Body);
					}
				}
			}
		}
	}
}