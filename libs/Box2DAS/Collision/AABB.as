package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// An axis aligned bounding box.
	public class AABB {
		
		public function AABB(l:V2 = null, u:V2 = null) {
			if(l) lowerBound.xy(l.x, l.y);
			if(u) upperBound.xy(u.x, u.y);
		}
		
		public function get width():Number {
			return upperBound.x - lowerBound.x;
		}
		
		public function get height():Number {
			return upperBound.y - lowerBound.y;
		}
		
		/// Verify that the bounds are sorted.
		/// bool IsValid() const;
		public function IsValid():Boolean {
			var v:V2 = V2.subtract(upperBound, lowerBound);
			return v.x > 0 && v.y > 0;
		}
	
		/// Get the center of the AABB.
		/// b2Vec2 GetCenter() const
		public function getCenter():V2 {
			return V2.add(lowerBound, upperBound).divideN(2);
		}
	
		/// Get the extents of the AABB (half-widths).
		/// b2Vec2 GetExtents() const
		public function GetExtents():V2 {
			return V2.subtract(upperBound, lowerBound).divideN(2);
		}
	
		/// Combine two AABBs into this one.
		/// void Combine(const b2AABB& aabb1, const b2AABB& aabb2)
		public function Combine(aabb1:AABB, aabb2:AABB):void {
			lowerBound = V2.min(aabb1.lowerBound, aabb2.lowerBound);
			upperBound = V2.max(aabb1.upperBound, aabb2.upperBound);
		}
	
		/// Does this aabb contain the provided AABB.
		/// bool Contains(const b2AABB& aabb) const
		public function Contains(aabb:AABB):Boolean {
			return (
				(lowerBound.x <= aabb.lowerBound.x) &&
				(lowerBound.y <= aabb.lowerBound.y) &&
				(aabb.upperBound.x <= upperBound.x) &&
				(aabb.upperBound.y <= upperBound.y));
		}
		
		public function Expand(v:Number):void {
			lowerBound.subtractN(v);
			upperBound.addN(v);
		}
		
		public function toString():String {
			return '<AABB <' + lowerBound.x + ', ' + lowerBound.y + '>, <' + upperBound.x + ', ' + upperBound.y + '>>'
		}
		
		public static function FromV2(v:V2, expandX:Number = 0.001, expandY:Number = 0.001):AABB {
			return new AABB(new V2(v.x - expandX, v.y - expandY), new V2(v.x + expandX, v.y + expandY));
		}
		
		public var lowerBound:V2 = new V2();
		public var upperBound:V2 = new V2();
	
	}
}