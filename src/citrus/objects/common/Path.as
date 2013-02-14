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

        public function get isPolygon():Boolean
        {
            return _isPolygon;
        }

        public function set isPolygon(value:Boolean):void
        {
            _isPolygon = value;
        }

        public function add(x:Number, y:Number):void
        {
            _nodes.push(new MathVector(x, y));			
        }

        public function addPoint(value:MathVector):void
        {
            _nodes.push(value);
        }

        public function getPointAt(index:uint):MathVector
        {
            if (_nodes.length > index)
            {
                return _nodes[index] as MathVector;
            }

            return null;
        }

        public function head():MathVector
        {
            if (_nodes.length > 0)
            {
                return _nodes[0];
            }

            return null;
        }

        public function tail():MathVector
        {
            if (_nodes.length > 0)
            {
                return _nodes[_nodes.length - 1];
            }

            return null;
        }

        public function get length():uint
        {
            return _nodes.length;
        }
    }
}
