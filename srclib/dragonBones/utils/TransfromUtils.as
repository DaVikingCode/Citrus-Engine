package dragonBones.utils {
	import dragonBones.objects.Node;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/** @private */
	public class TransfromUtils {
		private static var helpMatrix1:Matrix = new Matrix();
		private static var helpMatrix2:Matrix = new Matrix();
		
		private static var helpPoint1:Point = new Point();
		private static var helpPoint2:Point = new Point();
		
		public static function transfromPointWithParent(_boneData:Node, _parentData:Node):void {
			nodeToMatrix(_boneData, helpMatrix1);
			nodeToMatrix(_parentData, helpMatrix2);
			
			helpMatrix2.invert();
			helpMatrix1.concat(helpMatrix2);
			
			matrixToNode(helpMatrix1, _boneData);
		}
		
		private static function nodeToMatrix(_node:Node, _matrix:Matrix):void{
			_matrix.a = _node.scaleX * Math.cos(_node.skewY)
			_matrix.b = _node.scaleX * Math.sin(_node.skewY)
			_matrix.c = -_node.scaleY * Math.sin(_node.skewX);
			_matrix.d = _node.scaleY * Math.cos(_node.skewX);
			
			_matrix.tx = _node.x;
			_matrix.ty = _node.y;
		}
		
		private static function matrixToNode(_matrix:Matrix, _node:Node):void{
			helpPoint1.x = 0;
			helpPoint1.y = 1;
			helpPoint1 = _matrix.deltaTransformPoint(helpPoint1);
			helpPoint2.x = 1;
			helpPoint2.y = 0;
			helpPoint2 = _matrix.deltaTransformPoint(helpPoint2);
			
			_node.skewX = Math.atan2(helpPoint1.y, helpPoint1.x) - Math.PI * 0.5;
			_node.skewY = Math.atan2(helpPoint2.y, helpPoint2.x);
			_node.scaleX = Math.sqrt(_matrix.a * _matrix.a + _matrix.b * _matrix.b);
			_node.scaleY = Math.sqrt(_matrix.c * _matrix.c + _matrix.d * _matrix.d);
			_node.x = _matrix.tx;
			_node.y = _matrix.ty;
		}
	}
	
}