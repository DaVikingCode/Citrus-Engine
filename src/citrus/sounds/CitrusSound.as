package citrus.sounds 
{
	import citrus.core.CitrusEngine;
	import citrus.sounds.cesound;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	public class CitrusSound extends EventDispatcher
	{
		use namespace cesound;
		
		public var hideParamWarnings:Boolean = false;
		
		protected var _name:String;
		protected var _timesToRepeat:int = 0;
		protected var _repeatCount:int = 0;
		protected var _soundTransform:SoundTransform;
		
		protected var _sound:Sound;
		protected var _ioerror:Boolean = false;
		protected var _loadedRatio:Number = 0;
		protected var _loaded:Boolean = false;
		protected var _group:CitrusSoundGroup;
		protected var _isPlaying:Boolean = false;
		protected var _position:Number = 0;
		
		protected var _urlReq:URLRequest;
		protected var _channel:SoundChannel;
		protected var _volume:Number = 1;
		protected var _panning:Number = 0;
		protected var _mute:Boolean = false;
		protected var _paused:Boolean = false;
		protected var _complete:Boolean = false;
		protected var _triggerSoundComplete:Boolean = false;
		protected var _triggerRepeatComplete:Boolean = false;
		
		cesound var kill:Boolean = false;
		cesound static var _sm:SoundManager;
		
		public function CitrusSound(name:String,params:Object = null) 
		{
			_name = name;
			setParams(params);
		}
		
		public function play(resetV:Boolean = true):void
		{
			if (_isPlaying)
				stop();
			else
				if (_urlReq && _loadedRatio == 0)
					_sound.load(_urlReq);
			
			if(resetV)
				reset();
			
			playAt(0);
		}
		
		public function resume():void
		{
			if (_isPlaying)
				return;
				
			if (_paused && !_complete)	
				playAt(_position);
		}
		
		public function pause():void
		{
			_position = _channel.position;
			stop(false);
			_isPlaying = false;
			_paused = true;
		}
		
		public function stop(full:Boolean = true):void
		{
			if (_channel)
			{
				_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
				_channel.stop();
			}
			_isPlaying = false;
			_paused = false;
			if (full)
				reset();
		}
		
		protected function playAt(position:Number):void
		{
			if (_complete)
				return;
				
			_channel = _sound.play(position, 0, _soundTransform);
			refreshSoundTransform();
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			_isPlaying = true;
			_paused = false;
		}
		
		protected function reset():void
		{
			_complete = false;
			_position = 0;
			_repeatCount = 0;
		}
		
		protected function onComplete(e:Event):void
		{
			(e.target as SoundChannel).removeEventListener(Event.SOUND_COMPLETE, onComplete);
			
			_repeatCount++;
			
			if (timesToRepeat == 0)
			{
				if(_triggerSoundComplete)
					_sm.dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_COMPLETE,this));
				playAt(0);
			} else if (repeatCount < timesToRepeat)
			{
				if(_triggerSoundComplete)
					_sm.dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_COMPLETE,this));
				playAt(0);
			}else if (repeatCount == timesToRepeat)
			{
				_complete = true;
				if(_triggerSoundComplete)
					_sm.dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_COMPLETE,this));
				if(_triggerRepeatComplete)
					_sm.dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.REPEAT_COMPLETE,this));
				stop(false);
			}
		}
		
		protected function onIOError(event:ErrorEvent):void
		{
			trace("CitrusSound Error Loading: ", this.name);
			_ioerror = true;
			_sm.dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_ERROR, this));
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			_loadedRatio = _sound.bytesLoaded / _sound.bytesTotal;
			if (_loadedRatio == 1)
			{
				_loaded = true;
				_sm.soundLoaded(this);
			}
		}
		
		cesound function refreshSoundTransform():SoundTransform
		{
			if (_soundTransform == null)
				_soundTransform = new SoundTransform();
				
			if (_group != null)
			{
				_soundTransform.volume = (_mute || _group._mute || _sm.masterMute) ? 0 : _volume * _group._volume * _sm.masterVolume;
				_soundTransform.pan =  _panning;
			
			}else
			{
				_soundTransform.volume = (_mute || _sm.masterMute) ? 0 : _volume * _sm.masterVolume;
				_soundTransform.pan =  _panning;
			}
			
			if (_channel)
				_channel.soundTransform = _soundTransform;
			
			return _soundTransform;
		}
		
		cesound function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		cesound function get isPaused():Boolean
		{
			return _paused;
		}
		
		cesound function set sound(val:Object):void
		{
			if (val is String)
			{
				_urlReq = new URLRequest(val as String);
				_sound = new Sound();
				_ioerror = false;
				_sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.addEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			else if (val is Class)
			{
				_sound = new (val as Class)();
				_ioerror = false;
				_loadedRatio = 1;
				_loaded = true;
			}
			else if (val is Sound)
			{
				_sound = val as Sound;
				_loadedRatio = 1;
				_loaded = true;
			}
		}
		
		cesound function get repeatCount():int
		{
			return _repeatCount;
		}
		
		cesound function set timesToRepeat(val:int):void
		{
			_timesToRepeat = val;
		}
		
		cesound function get sound():Object
		{
			return _sound;
		}
		
		cesound function get group():*
		{
			return _group;
		}
		
		cesound function set volume(val:Number):void
		{
			if (_volume != val)
			{
				_volume = val;
				refreshSoundTransform();
			}
		}
		
		cesound function set panning(val:Number):void
		{
			if (_panning != val)
			{
				_panning = val;
				refreshSoundTransform();
			}
		}
		
		cesound function set mute(val:Boolean):void
		{
			if (_mute != val)
			{
				_mute = val;
				refreshSoundTransform();
			}
		}
		
		cesound function set group(val:*):void
		{
			_group = CitrusEngine.getInstance().sound.getGroup(val);
			if(_group)
				_group.addSound(this);
		}
		
		cesound function get triggerSoundComplete():Boolean
		{
			return _triggerSoundComplete;
		}
		
		cesound function set triggerSoundComplete(val:Boolean):void
		{
			_triggerSoundComplete = val;
		}
		
		cesound function get triggerRepeatComplete():Boolean
		{
			return _triggerRepeatComplete;
		}
		
		cesound function set triggerRepeatComplete(val:Boolean):void
		{
			_triggerRepeatComplete = val;
		}
		
		cesound function setGroup(val:CitrusSoundGroup):void
		{
			_group = val;
		}
		
		cesound function destroy():void
		{
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			
			stop(true);
			_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			reset();
			if (_group)
				_group.removeSound(this);
			if (_channel)
				_channel.stop();
			_channel = null;
			_soundTransform = null;
			_sound = null;
		}
		
		public function get loadedRatio():Number
		{
			return _loadedRatio;
		}
		
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		public function get ioerror():Boolean
		{
			return _ioerror;
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function get panning():Number
		{
			return _panning;
		}
		
		public function get mute():Number
		{
			return cesound::mute;
		}
		
		public function get position():Number
		{
			return _position;
		}
		
		public function get repeatCount():int
		{
			return _repeatCount;
		}
		
		public function get timesToRepeat():int
		{
			return _timesToRepeat;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get group():CitrusSoundGroup
		{
			return _group;
		}
		
		protected function setParams(params:Object):void
		{
			for (var param:String in params)
			{
				try
				{
					if (params[param] == "true")
						cesound::[param] = true;
					else if (params[param] == "false")
						cesound::[param] = false;
					else
						cesound::[param] = params[param];
				}
				catch (e:Error)
				{
					trace(e.message);
					if (!hideParamWarnings)
						trace("Warning: The parameter " + param + " does not exist on " + this);
				}
			}
		}
		
	}

}