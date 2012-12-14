package citrus.objects.platformer.box2d {

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;

	import citrus.objects.Box2DPhysicsObject;

	/**
	 * This class creates perpetual hills like the games Tiny Wings, Ski Safari...
	 * Write a class to manage graphics, and extends this one to call graphics function. Take a look <a href="http://www.emanueleferonato.com/2011/08/26/create-a-terrain-like-the-one-in-tiny-wings-with-flash-and-box2d-adding-textures/">there</a>.
	 * Thanks to <a href="http://www.emanueleferonato.com/2011/10/04/create-a-terrain-like-the-one-in-tiny-wings-with-flash-and-box2d-%E2%80%93-adding-more-bumps/">Emanuele Feronato</a>.
	 */
	public class Hills extends Box2DPhysicsObject {
		
		/**
		 * This is the width of the hills visible. Most of the time your stage width. 
		 */
		public var widthHills:Number = 550;
		
		/**
		 * This is the physics object from which the Hills read its position and create/delete hills. 
		 */
		public var rider:Box2DPhysicsObject;
		
		private var realHeight:Number = 240;
		private var nextHill:Number = 240;
		private var realWidth:Number = 0;

		public function Hills(name:String, params:Object = null) {
			super(name, params);
		}

		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
			
			while (realWidth < widthHills) {
				nextHill = drawHill(10, realWidth, nextHill);
			}
		}
		
		private function drawHill(pixelStep:int, xOffset:Number, yOffset:Number):Number {

			var hillStartY:Number = yOffset;
			var hillWidth:Number = 120 + Math.ceil(Math.random() * 26) * 20;
			realWidth += hillWidth;
			var numberOfSlices:Number = hillWidth / pixelStep;
			var hillVector:Vector.<b2Vec2>;
			var randomHeight:Number;
			if (xOffset == 0) {
				randomHeight = 0;
			} else {
				do {
					randomHeight = Math.random() * hillWidth / 7.5;
				} while (realHeight + randomHeight > 600);
			}
			realHeight += randomHeight;
			hillStartY -= randomHeight;
			for (var j:uint = 0; j < numberOfSlices * 0.5; ++j) {
				hillVector = new Vector.<b2Vec2>();
				hillVector.push(new b2Vec2((j * pixelStep + xOffset) / _box2D.scale, 480 / _box2D.scale));
				hillVector.push(new b2Vec2((j * pixelStep + xOffset) / _box2D.scale, (hillStartY + randomHeight * Math.cos(2 * Math.PI / numberOfSlices * j)) / _box2D.scale));
				hillVector.push(new b2Vec2(((j + 1) * pixelStep + xOffset) / _box2D.scale, (hillStartY + randomHeight * Math.cos(2 * Math.PI / numberOfSlices * (j + 1))) / _box2D.scale));
				hillVector.push(new b2Vec2(((j + 1) * pixelStep + xOffset) / _box2D.scale, 480 / _box2D.scale));
				_bodyDef = new b2BodyDef();
				var centre:b2Vec2 = findCentroid(hillVector, hillVector.length);
				_bodyDef.position.Set(centre.x, centre.y);
				for (var z:uint = 0; z < hillVector.length; ++z) {
					hillVector[z].Subtract(centre);
				}
				var slicePoly:b2PolygonShape = new b2PolygonShape  ;
				slicePoly.SetAsVector(hillVector, 4);
				var sliceFixture:b2FixtureDef = new b2FixtureDef  ;
				sliceFixture.shape = slicePoly;
				_body = _box2D.world.CreateBody(_bodyDef);
				_body.SetUserData(this);
				_body.CreateFixture(sliceFixture);
			}
			hillStartY -= randomHeight;
			if (xOffset == 0) {
				randomHeight = 0;
			} else {
				do {
					randomHeight = Math.random() * hillWidth / 5;
				} while (realHeight - randomHeight < 240);
			}
			realHeight -= randomHeight;
			hillStartY += randomHeight;

			for (j = numberOfSlices * 0.5; j < numberOfSlices; ++j) {
				hillVector = new Vector.<b2Vec2>();
				hillVector.push(new b2Vec2((j * pixelStep + xOffset) / _box2D.scale, 480 / _box2D.scale));
				hillVector.push(new b2Vec2((j * pixelStep + xOffset) / _box2D.scale, (hillStartY + randomHeight * Math.cos(2 * Math.PI / numberOfSlices * j)) / _box2D.scale));
				hillVector.push(new b2Vec2(((j + 1) * pixelStep + xOffset) / _box2D.scale, (hillStartY + randomHeight * Math.cos(2 * Math.PI / numberOfSlices * (j + 1))) / _box2D.scale));
				hillVector.push(new b2Vec2(((j + 1) * pixelStep + xOffset) / _box2D.scale, 480 / _box2D.scale));
				_bodyDef = new b2BodyDef  ;
				centre = findCentroid(hillVector, hillVector.length);
				_bodyDef.position.Set(centre.x, centre.y);
				for (z = 0; z < hillVector.length; ++z) {
					hillVector[z].Subtract(centre);
				}
				slicePoly = new b2PolygonShape  ;
				slicePoly.SetAsVector(hillVector, 4);
				sliceFixture = new b2FixtureDef  ;
				sliceFixture.shape = slicePoly;
				_body = _box2D.world.CreateBody(_bodyDef);
				_body.SetUserData(this);
				_body.CreateFixture(sliceFixture);
			}
			hillStartY = hillStartY + randomHeight;
			return (hillStartY);
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (!rider)
				rider = _ce.state.getFirstObjectByType(Hero) as Hero;
			
			if (rider.x > realWidth - widthHills) {
				
				while (realWidth < rider.x + widthHills)
					nextHill = drawHill(10, realWidth, nextHill);
			}
			
			for (var currentBody:b2Body = _box2D.world.GetBodyList(); currentBody; currentBody = currentBody.GetNext()) {
				
				if (currentBody.GetUserData() is Hills && currentBody.GetPosition().x * _box2D.scale < rider.x - widthHills)
					_box2D.world.DestroyBody(currentBody);
			}
		}

		private function findCentroid(vs:Vector.<b2Vec2>, count:uint):b2Vec2 {
			var c:b2Vec2 = new b2Vec2();
			var area:Number = 0.0;
			var p1X:Number = 0.0;
			var p1Y:Number = 0.0;
			var inv3:Number = 1.0 / 3.0;
			for (var i:int = 0; i < count; ++i) {
				var p2:b2Vec2 = vs[i];
				var p3:b2Vec2 = i + 1 < count ? vs[int(i + 1)] : vs[0];
				var e1X:Number = p2.x - p1X;
				var e1Y:Number = p2.y - p1Y;
				var e2X:Number = p3.x - p1X;
				var e2Y:Number = p3.y - p1Y;
				var D:Number = (e1X * e2Y - e1Y * e2X);
				var triangleArea:Number = 0.5 * D;
				area += triangleArea;
				c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
				c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
			}
			c.x *= 1.0 / area;
			c.y *= 1.0 / area;
			return c;
		}
		
		/**
		 * Bodies are generated automatically, those functions aren't needed.
		 */
		override protected function defineBody():void
		{
		}
		
		override protected function createBody():void
		{
		}
			
		override protected function createShape():void
		{
		}
		
		
		override protected function defineFixture():void
		{
		}
		
		override protected function createFixture():void
		{
		}

	}
}
