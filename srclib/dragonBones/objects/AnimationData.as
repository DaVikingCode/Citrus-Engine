package dragonBones.objects
{
	final public class AnimationData extends Timeline
	{
		public var name:String;
		public var frameRate:uint;
		public var fadeTime:Number;
		public var playTimes:int;
		//use frame tweenEase, NaN
		//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
		public var tweenEasing:Number;
		public var autoTween:Boolean;
		public var lastFrameDuration:int;
		
		public var hideTimelineNameMap:Vector.<String>;
		
		private var _timelineList:Vector.<TransformTimeline>;
		public function get timelineList():Vector.<TransformTimeline>
		{
			return _timelineList;
		}
		
		public function AnimationData()
		{
			super();
			fadeTime = 0;
			playTimes = 0;
			autoTween = true;
			tweenEasing = NaN;
			hideTimelineNameMap = new Vector.<String>;
			hideTimelineNameMap.fixed = true;
			
			_timelineList = new Vector.<TransformTimeline>;
			_timelineList.fixed = true;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			hideTimelineNameMap.fixed = false;
			hideTimelineNameMap.length = 0;
			hideTimelineNameMap = null;
			
			_timelineList.fixed = false;
			for each(var timeline:TransformTimeline in _timelineList)
			{
				timeline.dispose();
			}
			_timelineList.fixed = false;
			_timelineList.length = 0;
			_timelineList = null;
		}
		
		public function getTimeline(timelineName:String):TransformTimeline
		{
			var i:int = _timelineList.length;
			while(i --)
			{
				if(_timelineList[i].name == timelineName)
				{
					return _timelineList[i];
				}
			}
			return null;
		}
		
		public function addTimeline(timeline:TransformTimeline):void
		{
			if(!timeline)
			{
				throw new ArgumentError();
			}
			
			if(_timelineList.indexOf(timeline) < 0)
			{
				_timelineList.fixed = false;
				_timelineList[_timelineList.length] = timeline;
				_timelineList.fixed = true;
			}
		}
	}
}