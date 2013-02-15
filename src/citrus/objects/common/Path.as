package citrus.objects.common {

	import citrus.core.CitrusObject;
	import citrus.math.MathVector;
	
	/**
	 * This class defines a set of points (MathVector) that can be used with the MovingPlatform or other objects. 
	 * Don't call the State's add method on this object, because you don't want to create a graphic object neither than calling 
	 * an no needed update method. Also don't forget to call yourself the destroy method!
	 */
    public class Path extends CitrusObject
    {
        private var _nodes:Vector.<MathVector>;

        private var _isPolygon:Boolean = false;

        public function Path(name:String, params:Object = null)
        {
            super(name, params);
            _nodes = new Vector.<MathVector>;
        }
			
		override public function destroy():void {
			
			_nodes.length = 0;
			
			super.destroy();
		}

        /**
         * Determines if the path is a continuous polygon.
         * Example. can be used to make MovingPlatform to follow certain path in a "circle".
         */
        public function get isPolygon():Boolean
        {
            return _isPolygon;
        }

        public function set isPolygon(value:Boolean):void
        {
            _isPolygon = value;
        }

        /**
         * Add a new node to the end of the path at the specified location.
         */
        public function add(x:Number, y:Number):void
        {
            _nodes.push(new MathVector(x, y));
        }

        /**
         * Sometimes its easier or faster to just pass a point object instead of separate X and Y coordinates.
         */
        public function addPoint(value:MathVector):void
        {
            _nodes.push(value);
        }

        /**
         * Returns a node from a certain index.
         */
        public function getPointAt(index:uint):MathVector
        {
            if (_nodes.length > index)
            {
                return _nodes[index] as MathVector;
            }

            return null;
        }

        /**
         * Get the first node in the list.
         */
        public function head():MathVector
        {
            if (_nodes.length > 0)
            {
                return _nodes[0];
            }

            return null;
        }

        /**
         * Get the last node in the list.
         */
        public function tail():MathVector
        {
            if (_nodes.length > 0)
            {
                return _nodes[_nodes.length - 1];
            }

            return null;
        }

        /**
         *  Length of the path in nodes.
         */
        public function get length():uint
        {
            return _nodes.length;
        }
    }
}
