package citrus.objects.platformer.box2d {

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;

	import citrus.objects.Box2DPhysicsObject;

	/**
	 * This class creates perpetual hills like the games Tiny Wings, Ski Safari...
	 * Write a class to manage graphics, and extends this one to call graphics function.
	 * For more information, check out CE's Tiny Wings example.
	 * Thanks to <a href="http://www.lorenzonuvoletta.com/create-an-infinite-scrolling-world-with-starling-and-nape/">Lorenzo Nuvoletta</a>.
	 * Thanks to <a href="http://www.emanueleferonato.com/2011/10/04/create-a-terrain-like-the-one-in-tiny-wings-with-flash-and-box2d-%E2%80%93-adding-more-bumps/">Emanuele Feronato</a>.
	 */
	public class Hills extends Box2DPhysicsObject {
		
		/**
		 * This is the height of a slice. 
		 */
		public var sliceHeight:uint = 240;
		
		/**
		 * This is the width of a slice. 
		 */
		public var sliceWidth:uint = 30;
		
		/**
		 * This is the height of the first point.
		 */
		public var hillStartY:Number = 0;
		
		/**
		 * This is the width of the hills visible. Most of the time your stage width. 
		 */
		public var widthHills:Number = 550;
		
		/**
		 * This is the factor that defined the roundness of the hills.
		 */
		public var roundFactor:uint = 10;
		
		
		/**
		 * This is the physics object from which the Hills read its position and create/delete hills. 
		 */
		public var rider:Box2DPhysicsObject;
		
		protected var _slicesCreated:uint;
		protected var _randomHeight:Number = 0;
		protected var _upAmplitude:Number;
		protected var _downAmplitude:Number;
		protected var _currentYPoint:Number = 0;
		protected var _nextYPoint:Number = 0;
		protected var _slicesInCurrentHill:uint;
		protected var _indexSliceInCurrentHill:uint;
		protected var _slices:Vector.<b2Body>;
		protected var _sliceVectorConstructor:Vector.<b2Vec2>;
		protected var _realHeight:Number = 240;
		protected var _realWidth:Number = 0;
		
		public function Hills(name:String, params:Object = null) {
			
			updateCallEnabled = true;
			
			super(name, params);
		}
		
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
		}
		
		override public function addPhysics():void
		{
			super.addPhysics();
			_prepareSlices();
		}
		
		protected function _prepareSlices():void {
			
			_slices = new Vector.<b2Body>();
			
			// Generate a line made of b2Vec2
			_sliceVectorConstructor = new Vector.<b2Vec2>();
			_sliceVectorConstructor.push(new b2Vec2(0, _realHeight));
			_sliceVectorConstructor.push(new b2Vec2(sliceWidth/_box2D.scale, _realHeight));
			
			// fill the stage with slices of hills
			for (var i:uint = 0; i < widthHills / sliceWidth * 1.5; ++i) {
				_createSlice();
			}
		}
		
		protected function _createSlice():void {
			// Every time a new hill has to be created this algorithm predicts where the slices will be positioned
			if (_indexSliceInCurrentHill >= _slicesInCurrentHill) {
				hillStartY += _randomHeight;

				if(roundFactor == 0) ++roundFactor;			
				
				_upAmplitude = 0;
				_downAmplitude = 0;
				
				var hillWidth:Number = sliceWidth * roundFactor + Math.ceil(Math.random() * roundFactor) * sliceWidth;
				
				_slicesInCurrentHill = hillWidth / sliceWidth;
				if(_slicesInCurrentHill % 2 != 0) ++_slicesInCurrentHill;

				_indexSliceInCurrentHill = 0;
				
				if (_realWidth > 0)
				{
					do {
						_upAmplitude =  Math.random() * hillWidth / 7.5;
					} while (Math.abs(_realHeight  + _upAmplitude) > 600);
					
					do {
						_downAmplitude =  Math.random() * hillWidth / 7.5;
					} while (Math.abs(_realHeight - _downAmplitude) < 10);
				} else {
					_upAmplitude = 0;
					_downAmplitude = 0;
				}
				
				_realWidth += hillWidth;
				
				_randomHeight = _upAmplitude;
				_realHeight += _upAmplitude;
				_realHeight -= _downAmplitude;
				hillStartY -= _randomHeight;
			}
			
			
			if (_indexSliceInCurrentHill == _slicesInCurrentHill / 2)
			{
				hillStartY -= _upAmplitude;
				_randomHeight = _downAmplitude;	
				hillStartY += _randomHeight;
			}
			
			// Calculate the position slice
			_currentYPoint = _sliceVectorConstructor[0].y = (hillStartY + _randomHeight *  Math.cos(2 * Math.PI / _slicesInCurrentHill * _indexSliceInCurrentHill)) / _box2D.scale;
			_nextYPoint =_sliceVectorConstructor[1].y = (hillStartY + _randomHeight *  Math.cos(2 * Math.PI / _slicesInCurrentHill * (_indexSliceInCurrentHill+1))) / _box2D.scale;
			
			var slicePolygon:b2PolygonShape = new b2PolygonShape();
			slicePolygon.SetAsVector(_sliceVectorConstructor, 2);
			
			_bodyDef = new b2BodyDef();
			_bodyDef.position.Set(_slicesCreated * sliceWidth/_box2D.scale, 0);
			
			var sliceFixture:b2FixtureDef = new b2FixtureDef();
			sliceFixture.shape = slicePolygon;
			
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
			_body.CreateFixture(sliceFixture);
			_pushHill();
		}
		
		protected function _pushHill():void {		
			_slicesCreated++;
			_indexSliceInCurrentHill++;		
			_slices.push(_body);
		}
		
		protected function _checkHills():void {
			
			if (!rider)
				rider = _ce.state.getFirstObjectByType(Hero) as Hero;
			
			var length:uint = _slices.length;
			
			for (var i:uint = 0; i < length; ++i) {
				
				if (rider.x - _slices[i].GetPosition().x*_box2D.scale > widthHills/2) {
					
					_deleteHill(i);
					--i;
					_createSlice();
					
				} else
					break;
			}
		}
		
		protected function _deleteHill(index:uint):void 
		{
			_box2D.world.DestroyBody(_slices[index]);
			_slices[index] = null;
			_slices.splice(index, 1);
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			_checkHills();
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