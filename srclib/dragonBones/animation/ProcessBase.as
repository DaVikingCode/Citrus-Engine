package dragonBones.animation
{
	
	/**
	 * Provides an abstract base class for key-frame processing classes.
	 *
	 */
	internal class ProcessBase
	{
		protected static const SINGLE:int = -4;
		protected static const LIST_START:int = -3;
		protected static const LIST_LOOP_START:int = -2;
		protected static const LIST:int = -1;
		
		protected var _currentFrame:Number;
		protected var _totalFrames:int;
		protected var _currentPrecent:Number;
		
		protected var _durationTween:int;
		protected var _duration:int;
		
		protected var _loop:int;
		protected var _tweenEasing:int;
		
		protected var _toIndex:int;
		
		/**
		 * Indicates whether the animation is playing
		 */
		public function get isPlaying():Boolean
		{
			return !_isComplete && !_isPause;
		}
		
		protected var _isComplete:Boolean;
		/**
		 * Indicates whether the animation is completed
		 */
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		protected var _isPause:Boolean;
		/**
		 * Indicates whether the animation is paused
		 */
		public function get isPause():Boolean
		{
			return _isPause;
		}
		
		protected var _timeScale:Number;
		/**
		 * The amount by which passed time should be scaled. Used to slow down or speed up animations. Defaults to 1.
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}
		public function set timeScale(value:Number):void
		{
			_timeScale = value;
		}
		
		/**
		 * Creates a new <code>ProcessBase</code>
		 */
		public function ProcessBase()
		{
			_timeScale = 1;
			_isComplete = true;
			_isPause = false;
			_currentFrame = 0;
		}
		/**
		 * Cleans up any resources used by the current object.
		 */
		public function dispose():void
		{
		}
		
		/**
		 * Starts playing the specified animation.
		 * @param	animation
		 * @param	_durationTo
		 * @param	durationTween
		 * @param	loop
		 * @param	tweenEasing
		 */
		public function gotoAndPlay(animation:Object, _durationTo:int = 0, durationTween:int = 0, loop:* = false, tweenEasing:Number = NaN):void
		{
			_isComplete = false;
			_isPause = false;
			_currentFrame = 0;
			_totalFrames = _durationTo;
			_tweenEasing = tweenEasing;
		}
		
		/**
		 * Moves the playhead.
		 */
		public function play():void
		{
			if(_isComplete)
			{
				_isComplete = false;
				_currentFrame = 0;
			}
			_isPause = false;
		}
		/**
		 * Stops the playhead
		 */
		public function stop():void
		{
			_isPause = true;
		}
		
		/**
		 * Updates the state.
		 */
		final public function update():void
		{
			if (_isComplete || _isPause)
			{
				return;
			}
			if (_totalFrames <= 0)
			{
				_currentFrame = _totalFrames = 1;
			}
			_currentFrame += _timeScale;
			_currentPrecent = _currentFrame / _totalFrames;
			_currentFrame %= _totalFrames;
			updateHandler();
		}
		
		/**
		 * Provides a abstract function for sub-classes processing the update logic.
		 */
		protected function updateHandler():void
		{
		}
	}
	
}