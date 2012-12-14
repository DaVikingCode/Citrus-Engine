package citrus.objects.platformer.nape {

	import citrus.objects.NapePhysicsObject;

	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;

	/**
	 * This class creates perpetual hills like the games Tiny Wings, Ski Safari...
	 * Write a class to manage graphics, and extends this one to call graphics function.
	 * For more information, check out CE's Tiny Wings example.
	 * Thanks to <a href="http://www.lorenzonuvoletta.com/create-an-infinite-scrolling-world-with-starling-and-nape/">Lorenzo Nuvoletta</a>.
	 */
	public class Hills extends NapePhysicsObject {
		
		/**
		 * This is the height of a slice. 
		 */
		public var sliceHeight:uint = 600;
		
		/**
		 * This is the width of a slice. 
		 */
		public var sliceWidth:uint = 30;
		
		/**
		 * This is the height of the first point.
		 */
		public var currentYPoint:Number = 200;
		
		/**
		 * This is the width of the hills visible. Most of the time your stage width. 
		 */
		public var widthHills:Number = 550;
		
		/**
		 * This is the physics object from which the Hills read its position and create/delete hills. 
		 */
		public var rider:NapePhysicsObject;
		
		protected var _slicesCreated:uint;
		protected var _currentAmplitude:Number;
		protected var _nextYPoint:Number;
		protected var _slicesInCurrentHill:uint;
		protected var _indexSliceInCurrentHill:uint;
		protected var _slices:Vector.<Body>;
		protected var _sliceVectorConstructor:Vector.<Vec2>;

		public function Hills(name:String, params:Object = null) {
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
			
			_prepareSlices();
		}
		
		protected function _prepareSlices():void {
			
			_slices = new Vector.<Body>();

			// Generate a rectangle made of Vec2
			_sliceVectorConstructor = new Vector.<Vec2>();
			_sliceVectorConstructor.push(new Vec2(0, sliceHeight));
			_sliceVectorConstructor.push(new Vec2(0, 0));
			_sliceVectorConstructor.push(new Vec2(sliceWidth, 0));
			_sliceVectorConstructor.push(new Vec2(sliceWidth, sliceHeight));
			
			// fill the stage with slices of hills
			for (var i:uint = 0; i < widthHills / sliceWidth * 1.2; ++i) {
				_createSlice();
			}
		}
		
		protected function _createSlice():void {
			
			// Every time a new hill has to be created this algorithm predicts where the slices will be positioned
			if (_indexSliceInCurrentHill >= _slicesInCurrentHill) {
				_slicesInCurrentHill = Math.random() * 40 + 10;
				_currentAmplitude = Math.random() * 60 - 20;
				_indexSliceInCurrentHill = 0;
			}
			// Calculate the position of the next slice
			_nextYPoint = currentYPoint + (Math.sin(((Math.PI / _slicesInCurrentHill) * _indexSliceInCurrentHill)) * _currentAmplitude);
			_sliceVectorConstructor[2].y = _nextYPoint - currentYPoint;
			var slicePolygon:Polygon = new Polygon(_sliceVectorConstructor);
			_body = new Body(BodyType.STATIC);
			_body.userData.myData = this;
			_body.shapes.add(slicePolygon);
			_body.position.x = _slicesCreated * sliceWidth;
			_body.position.y = currentYPoint;
			_body.space = _nape.space;
			
			_pushHill();
		}
		
		protected function _pushHill():void {
			
			_slicesCreated++;
			_indexSliceInCurrentHill++;
			currentYPoint = _nextYPoint;
			
			 _slices.push(_body);
		}
		
		protected function _checkHills():void {
			
			if (!rider)
				rider = _ce.state.getFirstObjectByType(Hero) as Hero;
			
			var length:uint = _slices.length;
			
			for (var i:uint = 0; i < length; ++i) {
				
				if (rider.body.position.x - _slices[i].position.x > widthHills * 0.5 + 100) {
					
					_deleteHill(i);
					--i;
					_createSlice();
					
				} else
					break;
			}
		}
		
		protected function _deleteHill(index:uint):void {
			
			_nape.space.bodies.remove(_slices[index]);
			_slices.splice(index, 1);
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			_checkHills();
		}
		
		/**
		 * Bodies are generated automatically, those functions aren't needed.
		 */
		override protected function defineBody():void {
		}
		
		override protected function createBody():void {
		}
		
		override protected function createMaterial():void {
		}
		
		override protected function createShape():void {
		}
		
		override protected function createFilter():void {
		}
		
		override protected function createConstraint():void {
		}
	}
}
