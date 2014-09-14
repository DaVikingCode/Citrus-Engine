package dragonBones.objects
{
	import flash.geom.Point;
	
	public final class TransformTimeline extends Timeline
	{
		public var name:String;
		public var transformed:Boolean;
		
		public var originTransform:DBTransform;
		public var originPivot:Point;
		
		public var offset:Number;
		
		public var timelineCached:TimelineCached;
		
		private var _slotTimelineCachedMap:Object;
		
		public function TransformTimeline()
		{
			super();
			
			_slotTimelineCachedMap = {};
			
			originTransform = new DBTransform();
			originPivot = new Point();
			offset = 0;
			
			timelineCached = new TimelineCached();
		}
		
		public function getSlotTimelineCached(slotName:String):TimelineCached
		{
			var slotTimelineCached:TimelineCached = _slotTimelineCachedMap[slotName];
			if(!slotTimelineCached)
			{
				_slotTimelineCachedMap[slotName] =
					slotTimelineCached = new TimelineCached();
			}
			return slotTimelineCached;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			timelineCached.dispose();
			
			for each(var slotTimelineCached:TimelineCached in _slotTimelineCachedMap)
			{
				slotTimelineCached.dispose();
			}
			//_slotTimelineCachedMap.clear();
			
			originTransform = null;
			originPivot = null;
			
			timelineCached = null;
			
			_slotTimelineCachedMap = null;
		}
	}
}