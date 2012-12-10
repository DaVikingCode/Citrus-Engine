package com.citrusengine.input.controllers {

	import com.citrusengine.input.InputController;
	import org.osflash.signals.Signal;
	
	/**
	 * Work In Progress.
	 */
	public class TimeShifter extends InputController
	{
		public var onSpeedChanged:Signal;
		public var onActivated:Signal;
		public var onDeactivated:Signal;
		public var paused:Boolean = false;
		
		protected var _active:Boolean = false;
		
		protected var _Buffer:Vector.<Object>;
		
		/**
		 * a "bufferSet" helps knowing what to record and from what.
		 * the set needs the following properties :
		 * object : the object to record from
		 * continuous : the parameters of this object that will get interpolated such as position, velocity.
		 * discrete : the parameters of this object that will not get interpolated, such as scores, animation, Booleans...
		 * 
		 * ex : {object: hero, continuous:["x","y","rotation"], discrete: ["animation","animationFrame"]}
		 * 
		 * to record and replay animation sequences, you can add something like this to a default Physics Object :
		 * 
		 * public function get animationFrame():uint {
		 *  	return (_view as AnimationSequence).mcSequences[_animation].currentFrame;
		 * }
		 * public function set animationFrame(value:uint):void {
		 *      (_view as AnimationSequence).mcSequences[_animation].currentFrame = value;
		 * }
		 * 
		 * as long as you are sure that _view will be an AnimationSequence.
		 * then puttin "animationFrame to the discrete param list in a bufferSet will record and replay the correct frame!
		 * 
		 * note: "continuous" or "discrete" parameters can be arrays.
		 */
		protected var _BufferSets:Vector.<Object>;
		
		protected var _bufferPosition:Number = 0;
		protected var _bufferLength:uint = 0;
		protected var _maxBufferLength:uint;
		
		protected var _previousBufferIndex:uint;
		protected var _nextBufferIndex:uint;
		
		protected var _previousBufferFrame:Object;
		protected var _nextBufferFrame:Object;
		
		protected var _elapsedFrameCount:uint = 0;
		protected var _isBufferFrame:Boolean = true;
		
		protected var _interpolationFactor:Number = 1;
		
		protected var _previousSpeed:Number = 0; // used for knowing direction.
		protected var _currentSpeed:Number = 0;
		protected var _targetSpeed:Number = 0;
		
		protected var _easeFunc:Function;
		protected var _easeTimer:uint = 0;
		protected var _easeDuration:uint = 80;
		
		/**
		 * saves a factor accessible on speed transitions.
		 */
		public var easeFactor:Number = 0;
		
		protected var _doDelay:Boolean = false;
		protected var _playbackDelay:Number = 0;
		protected var _delayedFunc:Function;
		
		protected var _manualMode:Boolean = false;
		
		public function TimeShifter(bufferInSeconds:uint)
		{
			super("TimeShifter Controller", 16);
			
			_maxBufferLength = bufferInSeconds * _ce.stage.frameRate;
			
			_Buffer = new Vector.<Object>();
			_BufferSets = new Vector.<Object>();
			
			_easeFunc = Tween_easeOut;
			
			onSpeedChanged = new Signal();
			onActivated = new Signal();
			onDeactivated = new Signal();
			onSpeedChanged.add(onSpeedChange);
		}
		
		/**
		 * Adds a "bufferSet" to the record.
		 * @param	bufferSet {object:Object, continuous:["x","y"], discrete:["boolean"] }
		 */
		public function addBufferSet(bufferSet:Object):void
		{
			if (_active)
				throw(new Error("you can't add a bufferSet to TimeShifter if it's active."));
			else
				if(bufferSet.object && (bufferSet.continuous || bufferSet.discrete))
					_BufferSets.push(bufferSet);
		}
		
		/**
		 * starts replay with an optional delay.
		 * @param	delay in seconds
		 */
		public function startReplay(delay:Number = 0, speed:Number = 1):void
		{
			_playbackDelay = (delay < 0) ? Math.abs(delay) * _ce.stage.frameRate : delay * _ce.stage.frameRate;
			_doDelay = true;
			_delayedFunc = replay;
			(speed < 0) ? onSpeedChanged.dispatch(-speed) : onSpeedChanged.dispatch(speed) ;
		}
		
		/**
		 * starts rewind with an optional delay.
		 * @param	delay in seconds
		 */
		public function startRewind(delay:Number = 0, speed:Number = 1):void
		{
			_playbackDelay = (delay < 0) ? Math.abs(delay) * _ce.stage.frameRate : delay * _ce.stage.frameRate;
			_doDelay = true;
			_delayedFunc = rewind;
			(speed < 0) ? onSpeedChanged.dispatch(speed) : onSpeedChanged.dispatch(-speed) ;
		}
		
		protected function replay():void
		{
			_bufferPosition = _previousBufferIndex = 0;
			_nextBufferIndex = 1;
			_active = true;
			onActivated.dispatch();
			_input.startRouting(16);
		}
		
		protected function rewind():void
		{
			_bufferPosition = _previousBufferIndex = _bufferLength - 1;
			_nextBufferIndex = _bufferLength - 2;
			_active = true;
			onActivated.dispatch();
			_input.startRouting(16);
		}
		
		public function pause():void
		{
			_bufferPosition = _previousBufferIndex = _nextBufferIndex = _Buffer.length - 2;
			onActivated.dispatch();
			_currentSpeed = 0;
			onSpeedChanged.dispatch(0);
			_active = true;
			paused = true;
		}
		
		public function startManualControl(startSpeed:Number):void
		{
			_bufferPosition = _previousBufferIndex =_Buffer.length - 1;
			_nextBufferIndex =_Buffer.length - 2;
			_active = true;
			onActivated.dispatch();
			_input.startRouting(16);
			_currentSpeed = startSpeed;
			onSpeedChanged.dispatch(startSpeed);
		}
		
		protected function onSpeedChange(value:Number):void
		{
			_easeTimer = 0;
			_targetSpeed = value;
		}
		
		protected function checkActions():void
		{	
			if (_input.justDid("timeshift", 16) && (!_active || paused))
			{
				_manualMode = true;
				paused = false;
				startManualControl( -1);
			}
			
			//speed change on playback and when input is routed on manual mode.
			
			if (_input.justDid("down", 16) && _active && _manualMode)
				onSpeedChanged.dispatch(_targetSpeed - 1);
			if (_input.justDid("up", 16) && _active && _manualMode)
				onSpeedChanged.dispatch(_targetSpeed + 1);
			
			//Key up
			
			if (!_input.isDoing("timeshift", 16) && (_active || !paused) && _manualMode)
			{
				_manualMode = false;
				reset();
			}
			
		}
		
		protected function writeBuffer():void
		{
			var obj:Object;
			var continuous:Object;
			var discrete:Object;
			var abuff:Vector.<Object> = _input.getActionsSnapshot();
			var wbuff:Vector.<Object> = new Vector.<Object>();
			var ic:Object;
			var id:Object;
			var newbuffer:Object;
			for each (obj in _BufferSets)
			{
				newbuffer = { };
				newbuffer.object = obj.object;
				if (obj.continuous)
					for each (continuous in obj.continuous)
						if (obj.object[continuous] is Array)
						{
							newbuffer[continuous] = new Object();
							for each (ic in obj.object[continuous])
								newbuffer[continuous][ic] = obj.object[continuous][ic];
						}
						else
							newbuffer[continuous] = obj.object[continuous];
				
				if (obj.discrete)
					for each (discrete in obj.discrete)
						if (obj.object[discrete] is Array)
						{
							newbuffer[discrete] = new Object();
							for each (id in obj.object[continuous])
								newbuffer[discrete][id] = obj.object[discrete][id];
						}
						else
							newbuffer[discrete] = obj.object[discrete];
				
				wbuff.push(newbuffer);
				
			}
			
			_Buffer.push({actionbuffer: abuff, watchbuffer: wbuff});
			_bufferLength++;
			
			if (_bufferLength > _maxBufferLength)
			{
				_Buffer.shift();
				_bufferLength--;
			}
			
		}
		
		/**
		 * Moves buffer position
		 * sets previous and next buffer index and the interpolation factor.
		 */
		protected function moveBufferPosition():void
		{
			if (Math.ceil(_bufferPosition + _currentSpeed) < _bufferLength - 1 && Math.floor(_bufferPosition + _currentSpeed) > 0 )
			{
				_previousBufferIndex = (_currentSpeed - _previousSpeed < 0) ? Math.floor(_bufferPosition + _currentSpeed) : Math.ceil(_bufferPosition + _currentSpeed);
				_nextBufferIndex = (_currentSpeed - _previousSpeed < 0) ? Math.floor(_bufferPosition + _currentSpeed) - 1 :  Math.ceil(_bufferPosition + _currentSpeed) + 1;
				_interpolationFactor = (_currentSpeed - _previousSpeed < 0) ? _nextBufferIndex - (_bufferPosition + _currentSpeed)  : (_bufferPosition + _currentSpeed) - _previousBufferIndex;
			}
			
			_bufferPosition += _currentSpeed;
			_isBufferFrame = !((_bufferPosition) % 1);
			
			_previousBufferFrame = _Buffer[_previousBufferIndex];
			_nextBufferFrame = _Buffer[_nextBufferIndex];
			
			if (_bufferPosition > _bufferLength)
				_bufferPosition = _bufferLength - 1;
			else if (_bufferPosition < 0)
				_bufferPosition = 0;
		}
		
		/**
		 * Sets all objects properties according to position in buffer (and interpolates).
		 */
		protected function readBuffer():void
		{
			var obj:Object;
			var obj2:Object;
			var continuous:Object;
			var discrete:Object;
			var buffset:Object;
			var ic:Object;
			var id:Object;
			
			for each (obj in _previousBufferFrame.watchbuffer)
			{
				for each (obj2 in _nextBufferFrame.watchbuffer)
				{	
					for each (buffset in _BufferSets)
					{
						if (buffset.object == obj.object && obj.object == obj2.object)
						{
							if (buffset.continuous)
								for each (continuous in buffset.continuous)
									if (obj.object[continuous] is Array)
										for each (ic in continuous)
											obj.object[continuous][ic] = obj[continuous][ic] + ((obj2[continuous][ic] - obj[continuous][ic]) * _interpolationFactor) ;
									else
									obj.object[continuous] = obj[continuous] + ((obj2[continuous] - obj[continuous]) * _interpolationFactor) ;
						
							if (buffset.discrete)
								for each (discrete in buffset.discrete)
									if (obj.object[discrete] is Array)
										for each (id in discrete)
											obj.object[discrete][id] = obj[discrete][id];
									else
									obj.object[discrete] = obj[discrete];
						}
					}
				}
			}
			
		}
		
		/**
		 * Process speed easing
		 */
		protected function processSpeed():void
		{	
			if (paused)
				return;
			if (_easeTimer < _easeDuration)
			{
				_easeTimer++;
				_currentSpeed = _easeFunc(_easeTimer, _currentSpeed, _targetSpeed - _currentSpeed, _easeDuration);
				easeFactor = 	1 - Math.abs(_currentSpeed - _targetSpeed);
			}
			_previousSpeed = _currentSpeed;
			
		}
		
		/*
		 * Tweening functions for speed . equations by Robert Penner.
		 */
		private function Tween_easeOut(t:Number, b:Number, c:Number, d:Number):Number { t /= d; return -c * t*(t-2) + b; }
		private function Tween_easeIn(t:Number, b:Number, c:Number, d:Number):Number { t /= d; return c * t * t + b;}
		private function Tween_linear(t:Number, b:Number, c:Number, d:Number):Number { t /= d; return c*t/d + b; }
		
		override public function update():void
		{
			if (!enabled)
				return;
			
			checkActions();
			
			if (!_active)
			{
				if(!paused)
					writeBuffer();
				
				if(_doDelay)
					if (_playbackDelay > 0 )
						_playbackDelay--;
					else
					{
						_doDelay = false;
						_delayedFunc();
					}
			}
			else
			{
				processSpeed();
				moveBufferPosition();
				readBuffer();
				
				
				if (!_manualMode)
					if (_bufferLength > 0 && (_bufferPosition < 0 || _bufferPosition > _bufferLength - 1))
						reset();
			
				_elapsedFrameCount++;
			}
		}
		
		public function reset():void
		{
			processSpeed();
			moveBufferPosition();
			readBuffer();
			
			_elapsedFrameCount = 0;
			
			_bufferPosition = 0;
			
			//cut only the future :
			_Buffer.splice(_nextBufferIndex, _Buffer.length - 1);
			_bufferLength = _Buffer.length;
			
			_previousBufferIndex = 0;
			_nextBufferIndex = 0;
			
			_previousSpeed = 0;
			_currentSpeed = 0;
			_targetSpeed = 0;
			
			_active = false;
			onDeactivated.dispatch();
			_doDelay = false;
			
			_input.resetActions();
			_input.stopRouting();
		}
		
		override public function destroy():void
		{
			reset();
			_BufferSets.length = 0;
			_bufferLength = _Buffer.length = 0;
			_previousBufferFrame = null;
			_nextBufferFrame = null;
			_delayedFunc = null;
			super.destroy();
		}
		
		/**
		 * returns the current speed of TimeShifter playback.
		 */
		public function get speed():Number
		{
			return _currentSpeed;
		}
		
		public function get targetSpeed():Number
		{
			return _targetSpeed;
		}
	
	}
}