package com.citrusengine.input.controllers {

	import com.citrusengine.input.InputController;
	import org.osflash.signals.Signal;
	
	/**
	 * Work In Progress.
	 */
	public class TimeShifter extends InputController
	{
		public var manualSpeedChange:Signal;
		
		protected var _active:Boolean = false;
		
		protected var _Watch:Vector.<Object>;
		protected var _Buffer:Vector.<Object>;
		
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
		
		protected var _doDelay:Boolean = false;
		protected var _playbackDelay:Number = 0;
		protected var _delayedFunc:Function;
		
		protected var _manualMode:Boolean = false;
		
		public function TimeShifter(bufferInSeconds:uint, ... objects)
		{
			super("TimeShifter Controller", 16);
			
			_maxBufferLength = bufferInSeconds * _ce.stage.frameRate;
			
			_Watch = new Vector.<Object>;
			_Buffer = new Vector.<Object>();
			
			var obj:*;
			for each (obj in objects)
				_Watch.push(obj);
			
			_easeFunc = Tween_easeOut;
			
			manualSpeedChange = new Signal();
			manualSpeedChange.add(onManualSpeedChange);
		
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
			(speed < 0) ? manualSpeedChange.dispatch(-speed) : manualSpeedChange.dispatch(speed) ;
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
			(speed < 0) ? manualSpeedChange.dispatch(speed) : manualSpeedChange.dispatch(-speed) ;
		}
		
		protected function replay():void
		{
			_bufferPosition = 0;
			_active = true;
			_input.startRouting(16);
		}
		
		protected function rewind():void
		{
			_bufferPosition = _bufferLength - 1;
			_active = true;
			_input.startRouting(16);
		}
		
		protected function startManualControl():void
		{
			_bufferPosition = _bufferLength - 1;
			_previousBufferIndex = _bufferLength - 1;
			_nextBufferIndex = _bufferLength - 2;
			_active = true;
			_input.startRouting(16);
			_currentSpeed = 0;
			manualSpeedChange.dispatch(0);
		}
		
		protected function onManualSpeedChange(value:Number):void
		{
			_easeTimer = 0;
			_targetSpeed = value;
		}
		
		protected function checkActions():void
		{	
			if (_input.justDid("timeshift", 16) && !_active)
			{
				_manualMode = true;
				startManualControl();
			}
			
			//speed change on playback and when input is routed on manual mode.
			
			if (_input.justDid("down", 16) && _active && _manualMode)
				manualSpeedChange.dispatch(_targetSpeed - 1);
				
			if (_input.justDid("up", 16) && _active && _manualMode)
				manualSpeedChange.dispatch(_targetSpeed + 1);
			
			//Key up
			
			if (!_input.isDoing("timeshift", 16) && _active && _manualMode)
			{
				_manualMode = false;
				reset();
			}
			
		}
		
		protected function writeBuffer():void
		{
			var obj:Object;
			var abuff:Vector.<Object> = _input.getActionsSnapshot();
			var wbuff:Vector.<Object> = new Vector.<Object>();
			
			var newbuffer:Object;
			for each (obj in _Watch)
			{
				newbuffer = {};
				newbuffer.object = obj;
				newbuffer.x = obj.x;
				newbuffer.y = obj.y;
				newbuffer.rotation = obj.rotation;
				newbuffer.velocity = obj.velocity;
				wbuff.push(newbuffer);
			}
			
			_Buffer.push({actionbuffer: abuff, watchbuffer: wbuff});
			_bufferLength++;
			
			if (_bufferLength > _maxBufferLength)
			{
				_Buffer.shift();
				_bufferLength--;
			}
			
			trace("written", _bufferLength);
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
			
			_isBufferFrame = !((_bufferPosition + _currentSpeed) % 1);
			
			_previousBufferFrame = _Buffer[_previousBufferIndex];
			_nextBufferFrame = _Buffer[_nextBufferIndex];
			
			_bufferPosition += _currentSpeed;
			
		}
		
		/**
		 * Sets all objects properties according to position in buffer (and interpolates).
		 */
		protected function readBuffer():void
		{
			var obj:Object;
			var obj2:Object;
			
			for each (obj in _previousBufferFrame.watchbuffer)
			{
				for each (obj2 in _nextBufferFrame.watchbuffer)
				{
					if (obj.object == obj2.object)
					{
						obj.object.x = obj.x + ((obj2.x - obj.x) * _interpolationFactor);
						obj.object.y = obj.y + ((obj2.y - obj.y) * _interpolationFactor);
						obj.object.rotation = obj.rotation + ((obj2.rotation - obj.rotation) * _interpolationFactor);
						obj.object.velocity[0] = obj.velocity[0] + ((obj2.velocity[0] - obj.velocity[0]) * _interpolationFactor);
						obj.object.velocity[1] = obj.velocity[1] + ((obj2.velocity[1] - obj.velocity[1]) * _interpolationFactor);
					}
				}
			}
			
		}
		
		/**
		 * Process speed easing
		 */
		protected function processSpeed():void
		{	
			if (_easeTimer < _easeDuration)
			{
				_easeTimer++;
				_currentSpeed = _easeFunc(_easeTimer, _currentSpeed, _targetSpeed - _currentSpeed, _easeDuration);
					
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
				
				//check if automatic replay or rewind has reached end of buffer.
				if (!_manualMode)
					if (_bufferLength > 0 && (_bufferPosition < 0 || _bufferPosition > _bufferLength - 1))
						reset();
			
				_elapsedFrameCount++;
			}
		}
		
		public function reset():void
		{
			trace("reset",_elapsedFrameCount);
			//do last frame ?
			processSpeed();
			moveBufferPosition();
			readBuffer();
			
			//reset vars
			_elapsedFrameCount = 0;
			_bufferPosition = 0;
			_Buffer.length = 0;
			_bufferLength = 0;
			_active = false;
			_input.resetActions();
			_input.stopRouting();
			_doDelay = false;
			_currentSpeed = 0;
		}
	
	}
}