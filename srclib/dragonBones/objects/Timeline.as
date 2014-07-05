package dragonBones.objects
{
	public class Timeline
	{
		private var _frameList:Vector.<Frame>;
		public function get frameList():Vector.<Frame>
		{
			return _frameList;
		}
		
		public var duration:Number;
		public var scale:Number;
		
		public function Timeline()
		{
			_frameList = new Vector.<Frame>(0, true);
			duration = 0;
			scale = 1;
		}
		
		public function dispose():void
		{
			var i:int = _frameList.length;
			while(i --)
			{
				_frameList[i].dispose();
			}
			_frameList.fixed = false;
			_frameList.length = 0;
			_frameList = null;
		}
		
		public function addFrame(frame:Frame):void
		{
			if(!frame)
			{
				throw new ArgumentError();
			}
			
			if(_frameList.indexOf(frame) < 0)
			{
				_frameList.fixed = false;
				_frameList[_frameList.length] = frame;
				_frameList.fixed = true;
			}
			else
			{
				throw new ArgumentError();
			}
		}
	}
	
}