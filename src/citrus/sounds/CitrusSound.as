package citrus.sounds 
{

	import citrus.core.CitrusEngine;
	import citrus.core.citrus_internal;

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
		use namespace citrus_internal;
		
		public var hideParamWarnings:Boolean = false;
		
		protected var _name:String;
		protected var _timesToPlay:uint = 1;
		protected var _repeatCount:uint = 0;
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
		
		citrus_internal var kill:Boolean = false;
		citrus_internal static var _sm:SoundManager;
		
		public function CitrusSound(name:String,params:Object = null) 
		{
			_name = name;
			if (params["sound"] == null)
				throw new Error(String(String(this) + " sound "+ name+ " has no sound param defined."));
				
			setParams(params);
		}
		
		public function load():void
		{
			if (_urlReq && _loadedRatio == 0 && !_sound.isBuffering)
			{
					_ioerror = false;
					_loaded = false;
					_sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					_sound.addEventListener(ProgressEvent.PROGRESS, onProgress);
					_sound.load(_urlReq);
			}
		}
		
		public function unload():void
		{
			_sound.close();
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			sound = _urlReq;
		}
		
		public function play(resetV:Boolean = true):void
		{
			if (_isPlaying)
				stop();
			else
				load();
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
			if (_channel)
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
			if(_channel)
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
			
			_isPlaying = false;
			_repeatCount++;
			
			if (_timesToPlay <= 0)
			{
				if(_triggerSoundComplete)
					_sm.dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_COMPLETE,this));
				playAt(0);
			} else if (_repeatCount < _timesToPlay)
			{
				if(_triggerSoundComplete)
					_sm.dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_COMPLETE,this));
				playAt(0);
			}else if (_repeatCount == _timesToPlay)
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
			unload();
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
		
		citrus_internal function refreshSoundTransform():SoundTransform
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
		
		citrus_internal function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		citrus_internal function get isPaused():Boolean
		{
			return _paused;
		}
		
		citrus_internal function set sound(val:Object):void
		{
			if (_sound)
			{
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			
			if (val is String)
			{
				_sound = new Sound();
				_urlReq = new URLRequest(val as String);
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
			else if (val is URLRequest)
			{
				_sound = new Sound();
				_urlReq = val as URLRequest;
			}
			else
				throw new Error("CitrusSound, " + val + "is not a valid sound paramater");
		}
		
		citrus_internal function get repeatCount():int
		{
			return _repeatCount;
		}
		
		citrus_internal function set timesToPlay(val:int):void
		{
			_timesToPlay = val;
		}
		
		citrus_internal function get sound():Object
		{
			return _sound;
		}
		
		citrus_internal function get group():*
		{
			return _group;
		}
		
		citrus_internal function set volume(val:Number):void
		{
			if (_volume != val)
			{
				_volume = val;
				refreshSoundTransform();
			}
		}
		
		citrus_internal function set panning(val:Number):void
		{
			if (_panning != val)
			{
				_panning = val;
				refreshSoundTransform();
			}
		}
		
		citrus_internal function set mute(val:Boolean):void
		{
			if (_mute != val)
			{
				_mute = val;
				refreshSoundTransform();
			}
		}
		
		citrus_internal function set group(val:*):void
		{
			_group = CitrusEngine.getInstance().sound.getGroup(val);
			if(_group)
				_group.addSound(this);
		}
		
		citrus_internal function get triggerSoundComplete():Boolean
		{
			return _triggerSoundComplete;
		}
		
		citrus_internal function set triggerSoundComplete(val:Boolean):void
		{
			_triggerSoundComplete = val;
		}
		
		citrus_internal function get triggerRepeatComplete():Boolean
		{
			return _triggerRepeatComplete;
		}
		
		citrus_internal function set triggerRepeatComplete(val:Boolean):void
		{
			_triggerRepeatComplete = val;
		}
		
		citrus_internal function setGroup(val:CitrusSoundGroup):void
		{
			_group = val;
		}
		
		citrus_internal function destroy():void
		{
			if (_sound)
			{
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			if(_channel)
				_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			
			stop(true);
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
		
		public function get mute():Boolean
		{
			return _mute;
		}
		
		public function get position():Number
		{
			return _position;
		}
		
		public function get repeatCount():int
		{
			return _repeatCount;
		}
		
		public function get timesToPlay():int
		{
			return _timesToPlay;
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
						citrus_internal::[param] = true;
					else if (params[param] == "false")
						citrus_internal::[param] = false;
					else
						citrus_internal::[param] = params[param];
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