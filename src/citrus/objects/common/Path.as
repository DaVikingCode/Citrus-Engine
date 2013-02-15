package citrus.objects.common
{
    import citrus.core.CitrusObject;
    import citrus.math.MathVector;

    public class Path extends CitrusObject
    {
        private var _nodes:Vector.<MathVector>;

        private var _isPolygon:Boolean = false;

        public function Path(name:String, params:Object = null)
        {
            super(name, params);
            _nodes = new Vector.<MathVector>;
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
