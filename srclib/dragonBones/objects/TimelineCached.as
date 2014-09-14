package dragonBones.objects
{
	import flash.geom.Matrix;

	public final class TimelineCached
	{
		private var _timeline:Vector.<FrameCached>;
		public function get timeline():Vector.<FrameCached>
		{
			return _timeline;
		}
		
		public function TimelineCached()
		{
			_timeline = new Vector.<FrameCached>;
		}
		
		public function dispose():void
		{
			var i:int = _timeline.length;
			while(i --)
			{
				_timeline[i].dispose();
			}
			_timeline.fixed = false;
			_timeline.length = 0;
			_timeline = null;
		}
		
		public function getFrame(framePosition:int):FrameCached
		{
			return _timeline.length > framePosition?_timeline[framePosition]:null;
		}
		
		public function addFrame(transform:DBTransform, matrix:Matrix, framePosition:int, frameDuration:int):void
		{
			if(_timeline.length < framePosition + frameDuration)
			{
				_timeline.fixed = false;
				_timeline.length = framePosition + frameDuration;
				_timeline.fixed = true;
			}
			
			var frame:FrameCached = new FrameCached();
			if(transform)
			{
				frame.transform = new DBTransform();
				frame.transform.copy(transform);
			}
			frame.matrix = new Matrix();
			frame.matrix.copyFrom(matrix);
			
			for(var i:int = framePosition;i < framePosition + frameDuration;i ++)
			{
				_timeline[i] = frame;
			}
		}
	}
}