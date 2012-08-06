package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// Compute the closest points between two shapes. Supports any combination of:
	/// b2CircleShape, b2PolygonShape, b2EdgeShape. The simplex cache is input/output.
	/// On the first call set b2SimplexCache.count to zero.
	/// void b2Distance(b2DistanceOutput* output,
	///				b2SimplexCache* cache, 
	///				const b2DistanceInput* input);	
	public function b2Distance(
		output:b2DistanceOutput = null, 
		cache:b2SimplexCache = null, 
		input:b2DistanceInput = null
	):void {
		output ||= b2Def.distanceOutput;
		cache ||= b2Def.simplexCache;
		input ||= b2Def.distanceInput;
		b2Base.lib.b2Distance(output._ptr, cache._ptr, input._ptr);
	}
}