package dragonBones.utils
{
	import flash.geom.Matrix;
	
	import dragonBones.objects.DBTransform;
	
	/**
	 * @author CG
	 */
	final public class TransformUtil
	{
		public static const ANGLE_TO_RADIAN:Number = Math.PI / 180;
		public static const RADIAN_TO_ANGLE:Number = 180 / Math.PI;
		
		private static const HALF_PI:Number = Math.PI * 0.5;
		private static const DOUBLE_PI:Number = Math.PI * 2;
		
		private static const _helpTransformMatrix:Matrix = new Matrix();
		private static const _helpParentTransformMatrix:Matrix = new Matrix();
		
		public static function transformToMatrix(transform:DBTransform, matrix:Matrix):void
		{
			matrix.a = transform.scaleX * Math.cos(transform.skewY)
			matrix.b = transform.scaleX * Math.sin(transform.skewY)
			matrix.c = -transform.scaleY * Math.sin(transform.skewX);
			matrix.d = transform.scaleY * Math.cos(transform.skewX);
			matrix.tx = transform.x;
			matrix.ty = transform.y;
		}
		
		public static function formatRadian(radian:Number):Number
		{
			//radian %= DOUBLE_PI;
			if (radian > Math.PI)
			{
				radian -= DOUBLE_PI;
			}
			if (radian < -Math.PI)
			{
				radian += DOUBLE_PI;
			}
			return radian;
		}
		
		//这个算法如果用于骨骼间的绝对转相对请改为DBTransform.divParent()方法
		public static function globalToLocal(transform:DBTransform, parent:DBTransform):void
		{
			transformToMatrix(transform, _helpTransformMatrix);
			transformToMatrix(parent, _helpParentTransformMatrix);
			
			_helpParentTransformMatrix.invert();
			_helpTransformMatrix.concat(_helpParentTransformMatrix);
			
			matrixToTransform(_helpTransformMatrix, transform, transform.scaleX * parent.scaleX >= 0, transform.scaleY * parent.scaleY >= 0);
		}
		
		public static function matrixToTransform(matrix:Matrix, transform:DBTransform, scaleXF:Boolean, scaleYF:Boolean):void
		{
			transform.x = matrix.tx;
			transform.y = matrix.ty;
			transform.scaleX = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b) * (scaleXF ? 1 : -1);
			transform.scaleY = Math.sqrt(matrix.d * matrix.d + matrix.c * matrix.c) * (scaleYF ? 1 : -1);
			
			var skewXArray:Array = [];
			skewXArray[0] = Math.acos(matrix.d / transform.scaleY);
			skewXArray[1] = -skewXArray[0];
			skewXArray[2] = Math.asin(-matrix.c / transform.scaleY);
			skewXArray[3] = skewXArray[2] >= 0 ? Math.PI - skewXArray[2] : skewXArray[2] - Math.PI;
			
			if(Number(skewXArray[0]).toFixed(4) == Number(skewXArray[2]).toFixed(4) || Number(skewXArray[0]).toFixed(4) == Number(skewXArray[3]).toFixed(4))
			{
				transform.skewX = skewXArray[0];
			}
			else 
			{
				transform.skewX = skewXArray[1];
			}
			
			var skewYArray:Array = [];
			skewYArray[0] = Math.acos(matrix.a / transform.scaleX);
			skewYArray[1] = -skewYArray[0];
			skewYArray[2] = Math.asin(matrix.b / transform.scaleX);
			skewYArray[3] = skewYArray[2] >= 0 ? Math.PI - skewYArray[2] : skewYArray[2] - Math.PI;
			
			if(Number(skewYArray[0]).toFixed(4) == Number(skewYArray[2]).toFixed(4) || Number(skewYArray[0]).toFixed(4) == Number(skewYArray[3]).toFixed(4))
			{
				transform.skewY = skewYArray[0];
			}
			else 
			{
				transform.skewY = skewYArray[1];
			}
		}
		//确保角度在-180到180之间
		public static function normalizeRotation(rotation:Number):Number
		{
			rotation = (rotation + Math.PI)%(2*Math.PI);
			rotation = rotation > 0 ? rotation : 2*Math.PI + rotation;
			return rotation - Math.PI;
		}
	}
}