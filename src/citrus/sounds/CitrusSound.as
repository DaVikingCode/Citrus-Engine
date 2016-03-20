package citrus.sounds 
{

	import citrus.core.CitrusEngine;
	import citrus.events.CitrusEvent;
	import citrus.events.CitrusEventDispatcher;
	import citrus.events.CitrusSoundEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import citrus.core.citrus_internal;

	public class CitrusSound extends CitrusEventDispatcher
	{
		use namespace citrus_internal;
		
		public var hideParamWarnings:Boolean = false;
		
		protected var _name:String;
		protected var _soundTransform:SoundTransform;
		protected var _sound:Sound;
		protected var _ioerror:Boolean = false;
		protected var _loadedRatio:Number = 0;
		protected var _loaded:Boolean = false;
		protected var _group:CitrusSoundGroup;
		protected var _isPlaying:Boolean = false;
		protected var _urlReq:URLRequest;
		protected var _volume:Number = 1;
		protected var _panning:Number = 0;
		protected var _mute:Boolean = false;
		protected var _paused:Boolean = false;		
		
		protected var _ce:CitrusEngine;
		
		/**
		 * times to loop :
		 * if negative, infinite looping will be done and loops won't be tracked in CitrusSoundInstances.
		 * if you want to loop infinitely and still keep track of loops, set loops to int.MAX_VALUE instead, each time a loop completes
		 * the SOUND_LOOP event would be fired and loops will be counted.
		 */
		public var loops:int = 0;
		
		/**
		 * a list of all CitrusSoundInstances that are active (playing or paused)
		 */
		internal var soundInstances:Vector.<CitrusSoundInstance>;
		
		/**
		 * if permanent is set to true, no new CitrusSoundInstance
		 * will stop a sound instance from this CitrusSound to free up a channel.
		 * it is a good idea to set background music as 'permanent'
		 */
		public var permanent:Boolean = false;
		
		/**
		 * When the CitrusSound is constructed, it will load itself.
		 */
		public var autoload:Boolean = false;
		
		public function CitrusSound(name:String,params:Object = null) 
		{
			_ce = CitrusEngine.getInstance();
			_ce.sound.addDispatchChild(this);
			
			_name = name;
            if (!("sound" in params) || params["sound"] == null)
				throw new Error(String(String(this) + " sound "+ name+ " has no sound param defined."));
				
			soundInstances = new Vector.<CitrusSoundInstance>();
			
			setParams(params);
			
			if (autoload)
				load();
		}
		
		public function load():void
		{
			unload();
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
			if(_sound.isBuffering)
				_sound.close();
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			sound = _urlReq;
		}
		
		public function play():CitrusSoundInstance
		{
			return new CitrusSoundInstance(this, true, true);
		}
		
		/**
		 * creates a sound instance from this CitrusSound.
		 * you can use this CitrusSoundInstance to play at a specific position and control its volume/panning.
		 * @param	autoplay
		 * @param	autodestroy
		 * @return CitrusSoundInstance
		 */
		public function createInstance(autoplay:Boolean = false,autodestroy:Boolean = true):CitrusSoundInstance
		{
			return new CitrusSoundInstance(this, autoplay, autodestroy);
		}
		
		public function resume():void
		{
			var soundInstance:CitrusSoundInstance;
			for each (soundInstance in soundInstances)
				if(soundInstance.isPaused)
					soundInstance.resume();
		}
		
		public function pause():void
		{
			var soundInstance:CitrusSoundInstance;
			for each (soundInstance in soundInstances)
				if(soundInstance.isPlaying)
					soundInstance.pause();
		}
		
		public function stop():void
		{
			var soundInstance:CitrusSoundInstance;
			for each (soundInstance in soundInstances)
				if(soundInstance.isPlaying || soundInstance.isPaused)
					soundInstance.stop();
		}
		
		protected function onIOError(event:ErrorEvent):void
		{
			unload();
			trace("CitrusSound Error Loading: ", this.name);
			_ioerror = true;
			dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_ERROR, this, null) as CitrusEvent);
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			_loadedRatio = _sound.bytesLoaded / _sound.bytesTotal;
			if (_loadedRatio == 1)
			{
				_loaded = true;
				dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_LOADED,this,null));
			}
		}
		
		internal function resetSoundTransform(applyToInstances:Boolean = false):SoundTransform
		{
			if (_soundTransform == null)
				_soundTransform = new SoundTransform();
				
			if (_group != null)
			{
				_soundTransform.volume = (_mute || _group._mute || _ce.sound.masterMute) ? 0 : _volume * _group._volume * _ce.sound.masterVolume;
				_soundTransform.pan =  _panning;
			
			}else
			{
				_soundTransform.volume = (_mute || _ce.sound.masterMute) ? 0 : _volume * _ce.sound.masterVolume;
				_soundTransform.pan =  _panning;
			}
			
			if (applyToInstances)
			{
				var soundInstance:CitrusSoundInstance;
				for each (soundInstance in soundInstances)
					soundInstance.resetSoundTransform(false);
			}
			
			return _soundTransform;
		}
		
		public function set sound(val:Object):void
		{
			if (_sound)
			{
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			
			if (val is String)
			{
				_urlReq = new URLRequest(val as String);
				_sound = new Sound();
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
				_urlReq = val as URLRequest;
				_sound = new Sound();
			}
			else
				throw new Error("CitrusSound, " + val + "is not a valid sound paramater");
		}
		
		public function get sound():Object
		{
			return _sound;
		}
		
		public function get isPlaying():Boolean
		{
			var soundInstance:CitrusSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.isPlaying)
					return true;
			return false;
		}
		
		public function get isPaused():Boolean
		{
			var soundInstance:CitrusSoundInstance;
			for each (soundInstance in soundInstances)
				if (soundInstance.isPaused)
					return true;
			return false;
		}
		
		public function get group():*
		{
			return _group;
		}
		
		public function set volume(val:Number):void
		{
			if (_volume != val)
			{
				_volume = val;
				resetSoundTransform(true);
			}
		}
		
		public function set panning(val:Number):void
		{
			if (_panning != val)
			{
				_panning = val;
				resetSoundTransform(true);
			}
		}
		
		public function set mute(val:Boolean):void
		{
			if (_mute != val)
			{
				_mute = val;
				resetSoundTransform(true);
			}
		}
		
		public function set group(val:*):void
		{
			_group = CitrusEngine.getInstance().sound.getGroup(val);
			if (_group)
				_group.addSound(this);
		}
		
		public function setGroup(val:CitrusSoundGroup):void
		{
			_group = val;
		}
		
		internal function destroy():void
		{
			if (_sound)
			{
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			if (_group)
				_group.removeSound(this);
			_soundTransform = null;
			_sound = null;
			
			var soundInstance:CitrusSoundInstance;
			for each (soundInstance in soundInstances)
				soundInstance.stop();
				
			removeEventListeners();
			_ce.sound.removeDispatchChild(this);
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
		
		public function get name():String
		{
			return _name;
		}
		
		public function get soundTransform():SoundTransform
		{
			return _soundTransform;
		}
		
		public function get ready():Boolean
		{
			if (_sound)
			{
				if (_sound.isURLInaccessible)
					return false;
				if (_sound.isBuffering || _loadedRatio > 0)
					return true;
			}
			return false;
		}
		
		public function get instances():Vector.<CitrusSoundInstance>
		{
			return soundInstances.slice();
		}
		
		public function getInstance(index:int):CitrusSoundInstance
		{
			if (soundInstances.length > index + 1)
				return soundInstances[index];
			return null;
		}
		
		protected function setParams(params:Object):void
		{
			for (var param:String in params)
			{
				try
				{
					if (params[param] == "true")
						this[param] = true;
					else if (params[param] == "false")
						this[param] = false;
					else
						this[param] = params[param];
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