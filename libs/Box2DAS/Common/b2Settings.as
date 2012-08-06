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
	 * See Box2D/Common/b2Settings.h (the C++ file) for default values and descriptions
	 * of all these variables.
	 *
	 * WARNING: Unfortunately, b2_maxManifoldPoints and b2_maxPolygonVertices cannot
	 * be changed. They are used as array length constants.
	 */
	public class b2Settings extends b2Base {
		
		public static function get b2_maxFloat():Number { return mem._mrf(lib.b2Settings.b2_maxFloat); }
		public static function set b2_maxFloat(v:Number):void { mem._mwf(lib.b2Settings.b2_maxFloat, v); }
		
		public static function get b2_epsilon():Number { return mem._mrf(lib.b2Settings.b2_epsilon); }
		public static function set b2_epsilon(v:Number):void { mem._mwf(lib.b2Settings.b2_epsilon, v); }
		
		public static function get b2_pi():Number { return mem._mrf(lib.b2Settings.b2_pi); }
		public static function set b2_pi(v:Number):void { mem._mwf(lib.b2Settings.b2_pi, v); }
		
		/// DO NOT CHANGE.
		public static function get b2_maxManifoldPoints():int { return mem._mr32(lib.b2Settings.b2_maxManifoldPoints); }
		public static function set b2_maxManifoldPoints(v:int):void { mem._mw32(lib.b2Settings.b2_maxManifoldPoints, v); }
		
		/// DO NOTE CHANGE.
		public static function get b2_maxPolygonVertices():int { return mem._mr32(lib.b2Settings.b2_maxPolygonVertices); }
		public static function set b2_maxPolygonVertices(v:int):void { mem._mw32(lib.b2Settings.b2_maxPolygonVertices, v); }
		
		public static function get b2_aabbExtension():Number { return mem._mrf(lib.b2Settings.b2_aabbExtension); }
		public static function set b2_aabbExtension(v:Number):void { mem._mwf(lib.b2Settings.b2_aabbExtension, v); }
		
		public static function get b2_aabbMultiplier():Number { return mem._mrf(lib.b2Settings.b2_aabbMultiplier); }
		public static function set b2_aabbMultiplier(v:Number):void { mem._mwf(lib.b2Settings.b2_aabbMultiplier, v); }
		
		public static function get b2_linearSlop():Number { return mem._mrf(lib.b2Settings.b2_linearSlop); }
		public static function set b2_linearSlop(v:Number):void { mem._mwf(lib.b2Settings.b2_linearSlop, v); }
		
		public static function get b2_angularSlop():Number { return mem._mrf(lib.b2Settings.b2_angularSlop); }
		public static function set b2_angularSlop(v:Number):void { mem._mwf(lib.b2Settings.b2_angularSlop, v); }
		
		public static function get b2_polygonRadius():Number { return mem._mrf(lib.b2Settings.b2_polygonRadius); }
		public static function set b2_polygonRadius(v:Number):void { mem._mwf(lib.b2Settings.b2_polygonRadius, v); }
		
		public static function get b2_maxSubSteps():Number { return mem._mrf(lib.b2Settings.b2_maxSubSteps); }
		public static function set b2_maxSubSteps(v:Number):void { mem._mwf(lib.b2Settings.b2_maxSubSteps, v); }
		
		public static function get b2_maxTOIContacts():int { return mem._mr32(lib.b2Settings.b2_maxTOIContacts); }
		public static function set b2_maxTOIContacts(v:int):void { mem._mw32(lib.b2Settings.b2_maxTOIContacts, v); }
		
		public static function get b2_velocityThreshold():Number { return mem._mrf(lib.b2Settings.b2_velocityThreshold); }
		public static function set b2_velocityThreshold(v:Number):void { mem._mwf(lib.b2Settings.b2_velocityThreshold, v); }
		
		public static function get b2_maxLinearCorrection():Number { return mem._mrf(lib.b2Settings.b2_maxLinearCorrection); }
		public static function set b2_maxLinearCorrection(v:Number):void { mem._mwf(lib.b2Settings.b2_maxLinearCorrection, v); }
		
		public static function get b2_maxAngularCorrection():Number { return mem._mrf(lib.b2Settings.b2_maxAngularCorrection); }
		public static function set b2_maxAngularCorrection(v:Number):void { mem._mwf(lib.b2Settings.b2_maxAngularCorrection, v); }
		
		public static function get b2_maxTranslation():Number { return mem._mrf(lib.b2Settings.b2_maxTranslation); }
		public static function set b2_maxTranslation(v:Number):void { mem._mwf(lib.b2Settings.b2_maxTranslation, v); }
		
		public static function get b2_maxTranslationSquared():Number { return mem._mrf(lib.b2Settings.b2_maxTranslationSquared); }
		public static function set b2_maxTranslationSquared(v:Number):void { mem._mwf(lib.b2Settings.b2_maxTranslationSquared, v); }
		
		public static function get b2_maxRotation():Number { return mem._mrf(lib.b2Settings.b2_maxRotation); }
		public static function set b2_maxRotation(v:Number):void { mem._mwf(lib.b2Settings.b2_maxRotation, v); }
		
		public static function get b2_maxRotationSquared():Number { return mem._mrf(lib.b2Settings.b2_maxRotationSquared); }
		public static function set b2_maxRotationSquared(v:Number):void { mem._mwf(lib.b2Settings.b2_maxRotationSquared, v); }
		
		public static function get b2_contactBaumgarte():Number { return mem._mrf(lib.b2Settings.b2_contactBaumgarte); }
		public static function set b2_contactBaumgarte(v:Number):void { mem._mwf(lib.b2Settings.b2_contactBaumgarte, v); }
		
		public static function get b2_timeToSleep():Number { return mem._mrf(lib.b2Settings.b2_timeToSleep); }
		public static function set b2_timeToSleep(v:Number):void { mem._mwf(lib.b2Settings.b2_timeToSleep, v); }
		
		public static function get b2_linearSleepTolerance():Number { return mem._mrf(lib.b2Settings.b2_linearSleepTolerance); }
		public static function set b2_linearSleepTolerance(v:Number):void { mem._mwf(lib.b2Settings.b2_linearSleepTolerance, v); }
		
		public static function get b2_angularSleepTolerance():Number { return mem._mrf(lib.b2Settings.b2_angularSleepTolerance); }
		public static function set b2_angularSleepTolerance(v:Number):void { mem._mwf(lib.b2Settings.b2_angularSleepTolerance, v); }
	
	}
}