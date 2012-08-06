package Box2DAS.Dynamics {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	
	public class b2DebugDraw extends Shape {
		
		/// Colors to use for drawing (array indicates [fill, stroke]).
		public var colors:Object = {
			shape: [0x7f8c7b, 0],
			static: [0x5d6059, 0],
			kinematic: [0x5d5e50, 0],
			inactive: [0xffffff, 0],
			asleep: [0xc4c1ae, 0],
			joints: 0,
			pairs: 0
		}
		
		/// When debug drawing, multiply coordinates by this value.
		public var scale:Number = 1;
		
		/// The world to draw.
		public var world:b2World;
		
		/// Drawing options.
		public var shapes:Boolean = true;
		public var joints:Boolean = true;
		public var pairs:Boolean = false;
		
		public function b2DebugDraw(w:b2World = null, s:Number = 1):void {
			world = w;
			scale = s;
		}
		
		public function Draw():void {
			graphics.clear();
			if(shapes) {
				for(var b:b2Body = world.m_bodyList; b; b = b.GetNext()) {
					var xf:XF = b.GetTransform();
					for(var f:b2Fixture = b.GetFixtureList(); f; f = f.GetNext()) {
						DrawShape(f, xf);
					}
				}
			}
			if(joints) {
				for(var j:b2Joint = world.m_jointList; j; j = j.GetNext()) {
					DrawJoint(j);
				}
			}
			if(pairs) {
				for(var c:b2Contact = world.GetContactList(); c; c = c.GetNext()) {
					DrawPair(c);
				}
			}
		}
		
		public function DrawShape(fixture:b2Fixture, xf:XF):void {
			var b:b2Body = fixture.GetBody();
			var c:Array = 
				!b.IsActive() ? colors.inactive : 
				b.IsStatic() ? colors.static : 
				b.IsKinematic() ? colors.kinematic : 
				!b.IsAwake() ? colors.asleep :
				colors.shape;
				
			graphics.beginFill(c[0]);
			graphics.lineStyle(1, c[1]);
			
			fixture.m_shape.Draw(graphics, xf, scale);			
		}
		
		public function DrawJoint(j:b2Joint):void {
			var b1:b2Body = j.GetBodyA();
			var b2:b2Body = j.GetBodyB();
			var xf1:XF = b1.GetTransform();
			var xf2:XF = b2.GetTransform();
			var x1:V2 = xf1.p;
			var x2:V2 = xf2.p;
			var p1:V2 = j.GetAnchorA();
			var p2:V2 = j.GetAnchorB();

			graphics.lineStyle(1, colors.joint);
			
			switch(j.GetType()) {
				case b2Joint.e_mouseJoint:			
				case b2Joint.e_distanceJoint:
					DrawSegment(p1, p2);
					break;
				case b2Joint.e_pulleyJoint:
					var pulley:b2PulleyJoint = j as b2PulleyJoint;
					var s1:V2 = pulley.GetGroundAnchor1();
					var s2:V2 = pulley.GetGroundAnchor2();
					DrawSegment(s1, p1);
					DrawSegment(s2, p2);
					DrawSegment(s1, s2);
					break;
				default:
					DrawSegment(x1, p1);
					DrawSegment(p1, p2);
					DrawSegment(x2, p2);
					break;
			}
		}
		
		public function DrawPair(c:b2Contact):void {
			var cA:V2 = c.m_fixtureA.m_aabb.aabb.getCenter();
			var cB:V2 = c.m_fixtureB.m_aabb.aabb.getCenter();
			DrawSegment(cA, cB);
		}
		
		public function DrawSegment(p1:V2, p2:V2):void {
			graphics.moveTo(p1.x * scale, p1.y * scale);
			graphics.lineTo(p2.x * scale, p2.y * scale);
		}
	}
}