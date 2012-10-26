package box2dstarling {

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;

	import com.citrusengine.objects.platformer.box2d.Crate;

	/**
	 * @author Aymeric
	 * <p>This is a class created by the software http://www.physicseditor.de/</p>
	 * <p>Just select the CitrusEngine template, upload your png picture, set polygons and export.</p>
	 * <p>Be careful, the registration point is topLeft !</p>
	 * @param peObject : the name of the png file
	 */
    public class PhysicsEditorObjects extends Crate {
		
		[Inspectable(defaultValue="")]
		public var peObject:String = "";

		private var _tab:Array;

		public function PhysicsEditorObjects(name:String, params:Object = null) {

			super(name, params);
		}

		override public function destroy():void {

			super.destroy();
		}

		override public function update(timeDelta:Number):void {

			super.update(timeDelta);
		}

		override protected function defineFixture():void {
			
			super.defineFixture();
			
			_createVertices();

			_fixtureDef.density = _getDensity();
			_fixtureDef.friction = _getFriction();
			_fixtureDef.restitution = _getRestitution();
			
			for (var i:uint = 0; i < _tab.length; ++i) {
				var polygonShape:b2PolygonShape = new b2PolygonShape();
				polygonShape.SetAsArray(_tab[i]);
				_fixtureDef.shape = polygonShape;

				body.CreateFixture(_fixtureDef);
			}
		}
		
        protected function _createVertices():void {
			
			_tab = [];
			var vertices:Array = [];

			switch (peObject) {
				
				case "muffin":
											
			        vertices.push(new b2Vec2(-0.5/_box2D.scale, 81.5/_box2D.scale));
					vertices.push(new b2Vec2(10.5/_box2D.scale, 59.5/_box2D.scale));
					vertices.push(new b2Vec2(46.5/_box2D.scale, 27.5/_box2D.scale));
					vertices.push(new b2Vec2(50.5/_box2D.scale, 27.5/_box2D.scale));
					vertices.push(new b2Vec2(92.5/_box2D.scale, 61.5/_box2D.scale));
					vertices.push(new b2Vec2(99.5/_box2D.scale, 79.5/_box2D.scale));
					vertices.push(new b2Vec2(59.5/_box2D.scale, 141.5/_box2D.scale));
					vertices.push(new b2Vec2(17.5/_box2D.scale, 133.5/_box2D.scale));
					
					_tab.push(vertices);
					vertices = [];
											
			        vertices.push(new b2Vec2(59.5/_box2D.scale, 141.5/_box2D.scale));
					vertices.push(new b2Vec2(99.5/_box2D.scale, 79.5/_box2D.scale));
					vertices.push(new b2Vec2(83.5/_box2D.scale, 133.5/_box2D.scale));
					
					_tab.push(vertices);
					vertices = [];
											
			        vertices.push(new b2Vec2(50.5/_box2D.scale, 27.5/_box2D.scale));
					vertices.push(new b2Vec2(46.5/_box2D.scale, 27.5/_box2D.scale));
					vertices.push(new b2Vec2(42.5/_box2D.scale, -0.5/_box2D.scale));
					
					_tab.push(vertices);
					
					break;
			
			}
		}

		protected function _getDensity():Number {

			switch (peObject) {
				
				case "muffin":
					return 1;
					break;
			
			}

			return 1;
		}
		
		protected function _getFriction():Number {
			
			switch (peObject) {
				
				case "muffin":
					return 0.6;
					break;
			
			}

			return 0.6;
		}
		
		protected function _getRestitution():Number {
			
			switch (peObject) {
				
				case "muffin":
					return 0.3;
					break;
			
			}

			return 0.3;
		}
	}
}
