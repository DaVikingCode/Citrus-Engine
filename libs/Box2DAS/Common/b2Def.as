package Box2DAS.Common {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/**
	 * Holds static Box2D definition objects that can be reused for performance.
	 */
	public class b2Def {
			
		/// Body, shape, fixture & joint defs that can be reused for performance.
		public static var body:b2BodyDef;
		public static var fixture:b2FixtureDef;
		public static var polygon:b2PolygonShape;
		public static var circle:b2CircleShape;
		public static var edge:b2EdgeShape;
		public static var loop:b2LoopShape;
		public static var distanceJoint:b2DistanceJointDef;
		public static var gearJoint:b2GearJointDef;
		public static var lineJoint:b2LineJointDef;
		public static var mouseJoint:b2MouseJointDef;
		public static var prismaticJoint:b2PrismaticJointDef;
		public static var pulleyJoint:b2PulleyJointDef;
		public static var revoluteJoint:b2RevoluteJointDef;
		public static var weldJoint:b2WeldJointDef;
		public static var frictionJoint:b2FrictionJointDef;
		public static var ropeJoint:b2RopeJointDef;
		
		/// Reusable b2Distance objects.
		public static var distanceInput:b2DistanceInput;
		public static var distanceOutput:b2DistanceOutput;
		public static var simplexCache:b2SimplexCache;
		
		/**
		 * Create static definition objects. Can be re-called to re-initialize.
		 */
		public static function initialize():void {
			if(body) {
				destroy();
			}
			body = new b2BodyDef();
			fixture = new b2FixtureDef();
			polygon = new b2PolygonShape();
			circle = new b2CircleShape();
			edge = new b2EdgeShape();
			loop = new b2LoopShape();
			distanceJoint = new b2DistanceJointDef();
			gearJoint = new b2GearJointDef();
			lineJoint = new b2LineJointDef();
			mouseJoint = new b2MouseJointDef();
			prismaticJoint = new b2PrismaticJointDef();
			pulleyJoint = new b2PulleyJointDef();
			revoluteJoint = new b2RevoluteJointDef();
			weldJoint = new b2WeldJointDef();
			frictionJoint = new b2FrictionJointDef();
			ropeJoint = new b2RopeJointDef();
			
			distanceInput = new b2DistanceInput();
			distanceOutput = new b2DistanceOutput();
			simplexCache = new b2SimplexCache();
		}
		
		/**
		 * Destroy all definitions.
		 */
		public static function destroy():void {
			if(!body) {
				return;
			}
			body.destroy();
			fixture.destroy();
			polygon.destroy();
			circle.destroy();
			edge.destroy();
			loop.destroy();
			distanceJoint.destroy();
			gearJoint.destroy();
			lineJoint.destroy();
			mouseJoint.destroy();
			prismaticJoint.destroy();
			pulleyJoint.destroy();
			revoluteJoint.destroy();
			weldJoint.destroy();
			frictionJoint.destroy();
			ropeJoint.destroy();
			
			body = null;
			fixture = null;
			polygon = null;
			circle = null;
			edge = null;
			loop = null;
			distanceJoint = null;
			gearJoint = null;
			lineJoint = null;
			mouseJoint = null;
			prismaticJoint = null;
			pulleyJoint = null;
			revoluteJoint = null;
			weldJoint = null;
			frictionJoint = null;
			
			distanceInput.destroy();
			distanceOutput.destroy();
			simplexCache.destroy();
			
			distanceInput = null;
			distanceOutput = null;
			simplexCache = null;
		}
	}
}