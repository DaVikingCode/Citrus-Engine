package com.citrusengine.input.controllers {

	import com.citrusengine.input.InputController;
	
	/**
	 * Work In Progress.
	 * 
	 * notes:
	 * see if we can get rid of useless properties.
	 * do not use direction anymore but >speed< which will determine direction.
	 */
	public class TimeShifter extends InputController
	{
		
		protected var _Watch:Vector.<Object>;
		protected var _Buffer:Vector.<Object>;
		
		protected var _overridePlayback:Boolean = false;
		protected var _bufferPosition:Number = 0;
		protected var _bufferLength:uint = 0;
		protected var _maxBufferLength:uint;
		
		protected var _previousBufferIndex:uint;
		protected var _nextBufferIndex:uint;
		
		protected var _previousBufferFrame:Object;
		protected var _nextBufferFrame:Object;
		
		protected var _elapsedFrameCount:uint = 0;
		protected var _isBufferFrame:Boolean = true;
		protected var _direction:int = 1;
		
		protected var _interpolationFactor:Number = 1;
		
		protected var _speed:Number;
		protected var _startSpeed:Number;
		protected var _endSpeed:Number;
		
		protected var _easeFunc:Function;
		
		protected var _doDelay:Boolean = false;
		protected var _playbackDelay:Number = 0;
		protected var _delayFunc:Function;
		
		protected var _holdingReplay:Boolean = false;
		protected var _holdingRewind:Boolean = false;
		
		public function TimeShifter(bufferInSeconds:uint, startSpeed:Number = 1 ,endSpeed:Number = 1, ... objects)
		{
			super("TimeShifter Controller", 16);
			
			_maxBufferLength = bufferInSeconds * _ce.stage.frameRate;
			if (startSpeed > 0 && endSpeed > 0)
			{
				_speed = _startSpeed = startSpeed;
				_endSpeed = endSpeed;
			}
			else if (startSpeed == 0 && endSpeed == 0)
			{
				_speed = _startSpeed = startSpeed;
			}
			else
			{
				trace("Warning:", this, "start and end speeds should be strictly positive.");
				_speed = _startSpeed = 1;
				_endSpeed = 1;
			}
			
			_Watch = new Vector.<Object>;
			_Buffer = new Vector.<Object>();
			
			//register all objects in _Watch
			var obj:*;
			for each (obj in objects)
				_Watch.push(obj);
			
			//easing
			_easeFunc = Tween_easeOut;
		
		}
		
		/**
		 * starts replay with an optional delay.
		 * @param	delay in seconds
		 */
		public function startReplay(delay:Number = 0):void
		{
			if (delay < 0)
				_playbackDelay = Math.abs(delay) * _ce.stage.frameRate;
			else
				_playbackDelay = delay * _ce.stage.frameRate;
			_doDelay = true;
			_delayFunc = replay;
		}
		
		/**
		 * starts rewind with an optional delay.
		 * @param	delay in seconds
		 */
		public function startRewind(delay:Number = 0):void
		{
			if (delay < 0)
				_playbackDelay = Math.abs(delay) * _ce.stage.frameRate;
			else
				_playbackDelay = delay * _ce.stage.frameRate;
			_doDelay = true;
			_delayFunc = rewind;
		}
		
		protected function replay():void
		{
			_bufferPosition = 0;
			_direction = 1;
			_overridePlayback = true;
			_input.startRouting(16);
		}
		
		protected function rewind():void
		{
			_bufferPosition = _bufferLength - 1;
			_direction = -1;
			_overridePlayback = true;
			_input.startRouting(16);
		}
		
		protected function checkActions():void
		{	
			if (_input.justDid("rewind", 16) && !_overridePlayback)
			{
				_holdingRewind = true;
				startRewind();
			}
			
			if (_input.justDid("replay", 16) && !_overridePlayback)
			{
				_holdingReplay = true;
				startReplay();
			}
			
			//Highly experimental part - speed change on playback and when input is routed.
			
			if (_input.justDid("down", 16) && _overridePlayback)
			{
				_startSpeed -= 0.2;
				_endSpeed -= 0.2;
			}
				
			if (_input.justDid("up", 16) && _overridePlayback)
			{
				_startSpeed += 0.2;
				_endSpeed += 0.2;
			}
			
			//Key up
			
			if (!_input.isDoing("rewind", 16) && _overridePlayback && _holdingRewind)
			{
				_holdingRewind = false;
				reset();
			}
			
			if (!_input.isDoing("replay", 16) && _overridePlayback && _holdingReplay)
			{
				_holdingReplay = false;
				reset();
			}
			
			
			
		}
		
		public function seekTo(position:Number):void
		{
			if (position < 0 && position > -_bufferLength - 1)
				_bufferPosition = _bufferLength - position - 1;
			if (position > 0 && position < _bufferLength - 1)
				_bufferPosition = position;
		}
		
		protected function buffer():void
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
		}
		
		protected function seekToNext():void
		{
			if (_direction > 0 && Math.ceil(_bufferPosition + _speed) + 1 < _bufferLength - 1)
			{
				_bufferPosition += _speed;
				_previousBufferIndex = Math.floor(_bufferPosition);
				_nextBufferIndex = _previousBufferIndex + 1;
			}
			else if (_direction < 0 && Math.floor(_bufferPosition - _speed) > 0)
			{
				_bufferPosition -= _speed;
				_nextBufferIndex = Math.ceil(_bufferPosition);
				_previousBufferIndex = _nextBufferIndex - 1;
			}
			else
			{
				reset();
				return;
			}
			
			if (_direction > 0)
				_interpolationFactor = _bufferPosition - _previousBufferIndex;
			else if (_direction < 0)
				_interpolationFactor = _bufferPosition - _nextBufferIndex;
			
			_isBufferFrame = !(_bufferPosition % 1);
			
			_previousBufferFrame = _Buffer[_previousBufferIndex];
			_nextBufferFrame = _Buffer[_nextBufferIndex];
			
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
			
			_previousBufferFrame = _Buffer[_nextBufferIndex];
			
			if (_endSpeed != _startSpeed)
			{
				if (_direction > 0)
					if(_startSpeed < _endSpeed)
						_speed = _easeFunc(_bufferPosition, _startSpeed, _endSpeed, _bufferLength - 1);
					else
						_speed = _easeFunc(_bufferPosition, _startSpeed, _endSpeed - _startSpeed, _bufferLength - 1);
				else if (_direction < 0) 
					if(_startSpeed < _endSpeed)
						_speed = _easeFunc(_bufferLength - 1 - _bufferPosition, _startSpeed, _endSpeed, _bufferLength - 1);
					else
						_speed = _easeFunc(_bufferLength - 1 - _bufferPosition, _startSpeed, _endSpeed - _startSpeed, _bufferLength - 1);
			}
			else
			_speed = _endSpeed;
			
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
			
			if (!_overridePlayback)
			{
				if (_doDelay)
					if ( _playbackDelay > 0 )
						_playbackDelay--;
					else
					{
						_delayFunc();
						_doDelay = false;
					}
				
				buffer();
			}
			else
			{
				seekToNext();
				_elapsedFrameCount++;
			}
		}
		
		public function reset():void
		{
			_elapsedFrameCount = 0;
			_bufferPosition = 0;
			_Buffer.length = 0;
			_bufferLength = 0;
			_overridePlayback = false;
			_input.resetActions();
			_input.stopRouting();
			_doDelay = false;
			_direction = 0;
			
			//_startSpeed = _endSpeed = 0;
		}
	
	}

}