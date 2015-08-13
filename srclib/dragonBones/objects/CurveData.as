package dragonBones.objects
{
	import flash.geom.Point;

	/**
	 * 目前只支持两个控制点的贝塞尔曲线
	 * @author CG
	 */
	public class CurveData
	{
		private static const SamplingTimes:int = 20;
		private static const SamplingStep:Number = 0.05;
		private var _dataChanged:Boolean = false;
		
		private var _pointList:Array = [];
		public var sampling:Vector.<Point> = new Vector.<Point>(SamplingTimes);
		
		public function CurveData()
		{
			for(var i:int=0; i < SamplingTimes-1; i++)
			{
				sampling[i] = new Point();
			}
			sampling.fixed = true;
		}
		
		public function getValueByProgress(progress:Number):Number
		{
			if(_dataChanged)
			{
				refreshSampling();
			}
			for (var i:int = 0; i < SamplingTimes-1; i++) 
			{
				var point:Point = sampling[i];
				if (point.x >= progress) 
				{
					if(i == 0)
					{
						return point.y * progress / point.x;
					}
					else
					{
						var prevPoint:Point = sampling[i-1];
						return prevPoint.y + (point.y - prevPoint.y) * (progress - prevPoint.x) / (point.x - prevPoint.x);
					}
					
				}
			}
			return point.y + (1 - point.y) * (progress - point.x) / (1 - point.x);
		}
		
		public function refreshSampling():void
		{
			for(var i:int = 0; i < SamplingTimes-1; i++)
			{
				bezierCurve(SamplingStep * (i+1), sampling[i]);
			}
			_dataChanged = false;
		}
		
		private function bezierCurve(t:Number, outputPoint:Point):void
		{	
			var l_t:Number = 1-t;
			outputPoint.x = 3* point1.x*t*l_t*l_t + 3*point2.x*t*t*l_t + Math.pow(t,3);
			outputPoint.y = 3* point1.y*t*l_t*l_t + 3*point2.y*t*t*l_t + Math.pow(t,3);
		}
		
		public function set pointList(value:Array):void
		{
			_pointList = value;
			_dataChanged = true;
		}
		
		public function get pointList():Array
		{
			return _pointList;
		}
		
		public function isCurve():Boolean
		{
			return point1.x != 0 || point1.y != 0 || point2.x != 1 || point2.y != 1;
		}
		public function get point1():Point
		{
			return pointList[0];
		}
		public function get point2():Point
		{
			return pointList[1];
		}
	}
}