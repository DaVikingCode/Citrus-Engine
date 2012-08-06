package com.citrusengine.physics {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;

	/**
	 * The CitrusSolver is a simple math-based collision-detection system built for doing simple collision detection in games where physics needs are light
	 * and Box2D is overkill (also useful for mobile). The Citrus Solver works with the CitrusSprite objects, and uses their x, y, width, and height properties to 
	 * report and adjust for collisions.
	 * 
	 * The CitrusSolver is not useful for the following cases: 1) Rotated (non-axis-aligned) objects, angular velocity, mass-based collision reactions, and dynamic-to-dynamic object
	 * collisions (only static-to-dynamic works). If you need any of those physics features, you should use Box2D instead.
	 * If you only need to know if an overlap occured and you don't need to solve the collision, then you may test collisions between two dynamic
	 * (moving) objects.
	 * 
	 * After you create your CitrusSolver instance, you will want to call the collide() and/or overlap() methods to tell the solver which object types to test for collisions/overlaps
	 * against. See the documentation for those two classes for more info.
	 */
	public class SimpleCitrusSolver extends CitrusObject {

		private var _ce:CitrusEngine;
		private var _collideChecks:Array = new Array();
		private var _overlapChecks:Array = new Array();

		public function SimpleCitrusSolver(name:String, params:Object = null) {
			
			super(name, params);
			
			_ce = CitrusEngine.getInstance();
		}

		/**
		 * Call this method once after the CitrusSolver constructor to tell the solver to report (and solve) collisions between the two specified objects.
		 * The CitrusSolver will then automatically test collisions between any game object of the specified type once per frame.
		 * You can only test collisions between a dynamic (movable) object and a static (non-moviable) object.
		 * @param	dynamicObjectType The object that will be moved away from overlapping during a collision (probably your hero or something else that moves).
		 * @param	staticObjectType The object that does not move (probably your platform or wall, etc).
		 */
		public function collide(dynamicObjectType:Class, staticObjectType:Class):void {
			
			_collideChecks.push({a:dynamicObjectType, b:staticObjectType});
		}

		/**
		 * Call this method once after the CitrusSolver constructor to tell the solver to report overlaps between the two specified objects.
		 *  The CitrusSolver will then automatically test overlaps between any game object of the specified type once per frame.
		 * With overlaps, you ARE allowed to test between two dynamic (moving) objects.
		 * @param	typeA The first type of object you want to test for collisions against the second object type.
		 * @param	typeB The second type of object you want to test for collisions against the first object type.
		 */
		public function overlap(typeA:Class, typeB:Class):void {
			
			_overlapChecks.push({a:typeA, b:typeB});
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);

			for each (var pair:Object in _collideChecks) {
				
				if (pair.a == pair.b) {
					throw new Error("CitrusSolver does not test collisions against objects of the same type.");
				} else {
					// compare A's to B's
					var groupA:Vector.<CitrusObject> = _ce.state.getObjectsByType(pair.a);
					
					for (var i:uint = 0; i < groupA.length; ++i) {
						
						var itemA:CitrusSprite = groupA[i] as CitrusSprite;
						var groupB:Vector.<CitrusObject> = _ce.state.getObjectsByType(pair.b);
						
						for (var j:uint = 0; j < groupB.length; ++j) {
							
							var itemB:CitrusSprite = groupB[j] as CitrusSprite;
							collideOnce(itemA, itemB);
						}
					}
				}
			}

			for each (pair in _overlapChecks) {
				
				if (pair.a == pair.b) {
					// compare A's to each other
					var group:Vector.<CitrusObject> = _ce.state.getObjectsByType(pair.a);
					
					for (i = 0; i < groupA.length; ++i) {
						
						itemA = group[i] as CitrusSprite;
						
						for (j = i + 1; j < group.length; ++j) {
							
							itemB = group[j] as CitrusSprite;
							overlapOnce(itemA, itemB);
						}
					}
					
				} else {
					// compare A's to B's
					groupA = _ce.state.getObjectsByType(pair.a);
					
					for (i = 0; i < groupA.length; ++i) {
						
						itemA = groupA[i] as CitrusSprite;
						groupB = _ce.state.getObjectsByType(pair.b);
						
						for (j = 0; j < groupB.length; ++j) {
							
							itemB = groupB[j] as CitrusSprite;
							overlapOnce(itemA, itemB);
						}
					}
				}
			}
		}

		public function collideOnce(a:CitrusSprite, b:CitrusSprite):Boolean {
			
			var diffX:Number = (a.width / 2 + b.width / 2) - Math.abs(a.x - b.x);
			if (diffX >= 0) {
				
				var diffY:Number = (a.height / 2 + b.height / 2) - Math.abs(a.y - b.y);
				if (diffY >= 0) {
					
					var collisionType:uint;
					var impact:Number;
					var normal:Number;
					
					if (diffX < diffY) {
						// horizontal collision
						
						if (a.x < b.x) {
							a.x -= diffX;
							normal = 1;

							if (a.velocity.x > 0)
								a.velocity.x = 0;
								
						} else {
							a.x += diffX;
							normal = -1;

							if (a.velocity.x < 0)
								a.velocity.x = 0;
						}

						impact = Math.abs(b.velocity.x - a.velocity.x);

						if (!a.collisions[b]) {
							
							a.collisions[b] = new SimpleCollision(a, b, new MathVector(normal, 0), -impact, SimpleCollision.BEGIN);
							a.onCollide.dispatch(a, b, new MathVector(0, normal), -impact);
							
							b.collisions[a] = new SimpleCollision(b, a, new MathVector(-normal, 0), impact, SimpleCollision.BEGIN);
							b.onCollide.dispatch(b, a, new MathVector(0, -normal), impact);
							
						} else {
							
							a.collisions[b].type = SimpleCollision.PERSIST;
							a.collisions[b].impact = impact;
							a.collisions[b].normal.x = normal;
							a.collisions[b].normal.y = 0;
							a.onPersist.dispatch(a, b, a.collisions[b].normal);
							
							b.collisions[a].type = SimpleCollision.PERSIST;
							b.collisions[a].impact = -impact;
							b.collisions[a].normal.x = -normal;
							b.collisions[a].normal.y = 0;
							b.onPersist.dispatch(b, a, b.collisions[a].normal);
						}

					} else {
						// vertical collision
						
						if (a.y < b.y) {
							a.y -= diffY;
							normal = 1;

							if (a.velocity.y > 0)
								a.velocity.y = 0;
								
						} else {
							a.y += diffY;
							normal = -1;

							if (a.velocity.y < 0)
								a.velocity.y = 0;
						}

						impact = Math.abs(b.velocity.y - a.velocity.y);

						if (!a.collisions[b]) {
							
							a.collisions[b] = new SimpleCollision(a, b, new MathVector(0, normal), -impact, SimpleCollision.BEGIN);
							a.onCollide.dispatch(a, b, new MathVector(0, normal), -impact);
							
							b.collisions[a] = new SimpleCollision(b, a, new MathVector(0, -normal), impact, SimpleCollision.BEGIN);
							b.onCollide.dispatch(b, a, new MathVector(0, -normal), impact);
							
						} else {
							
							a.collisions[b].type = SimpleCollision.PERSIST;
							a.collisions[b].impact = impact;
							a.collisions[b].normal.x = 0;
							a.collisions[b].normal.y = normal;
							a.onPersist.dispatch(a, b, a.collisions[b].normal);
							
							b.collisions[a].type = SimpleCollision.PERSIST;
							b.collisions[a].impact = -impact;
							b.collisions[a].normal.x = 0;
							b.collisions[a].normal.y = -normal;
							b.onPersist.dispatch(b, a, b.collisions[a].normal);
						}
					}
					
					return true;
				}
			}

			if (a.collisions[b]) {
				
				a.onSeparate.dispatch(a, b);
				delete a.collisions[b];
				
				b.onSeparate.dispatch(b, a);
				delete b.collisions[a];
			}
			
			return false;
		}

		public function overlapOnce(a:CitrusSprite, b:CitrusSprite):Boolean {
			
			var overlap:Boolean = (a.x + a.width / 2 >= b.x - b.width / 2 && a.x - a.width / 2 <= b.x + b.width / 2 && // x axis overlaps 
								a.y + a.height / 2 >= b.y - b.height / 2 && a.y - a.height / 2 <= b.y + b.height / 2); // y axis overlaps
								
			if (overlap) {
				a.onCollide.dispatch(a, b, null, 0);
				b.onCollide.dispatch(b, a, null, 0);
			}
			
			return overlap;
		}
	}
}