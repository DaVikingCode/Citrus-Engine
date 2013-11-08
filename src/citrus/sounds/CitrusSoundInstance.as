package citrus.sounds
{
	import citrus.core.CitrusEngine;
	import citrus.events.CitrusEvent;
	import citrus.events.CitrusEventDispatcher;
	import citrus.utils.SoundChannelUtil;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * CitrusSoundInstance
	 * this class represents an existing sound (playing, paused or stopped)
	 * it holds a reference to the CitrusSound it was created from and
	 * a sound channel. through a CitrusSoundInstance you can tweak volumes and panning
	 * individually instead of CitrusSound wide.
	 * 
	 * a paused sound is still considered active, and keeps a soundChannel alive to be able to resume later.
	 */
	public class CitrusSoundInstance extends CitrusEventDispatcher
	{
		public var data:Object = { };
		
		protected var _ID:uint = 0;
		protected static var last_id:uint = 0;
		
		protected var _name:String;
		protected var _parentsound:CitrusSound;
		protected var _soundTransform:SoundTransform;
		
		protected var _permanent:Boolean = false;
		
		protected var _volume:Number = 1;
		protected var _panning:Number = 0;
		
		protected var _soundChannel:SoundChannel;
		
		protected var _isPlaying:Boolean = false;
		protected var _isPaused:Boolean = false;
		protected var _loops:int = 0;
		protected var _loopCount:int = 0;
		protected var _last_position:Number = 0;
		protected var _destroyed:Boolean = false;
		
		protected var _ce:CitrusEngine;
		
		/**
		 * if autodestroy is true, when the sound ends, destroy will be called instead of just stop().
		 */
		protected var _autodestroy:Boolean;
		
		/**
		 * list of active sound instances
		 */
		protected static var _list:Vector.<CitrusSoundInstance> = new Vector.<CitrusSoundInstance>();
		
		/**
		 * list of active non permanent sound instances
		 */
		protected static var _nonPermanent:Vector.<CitrusSoundInstance> = new Vector.<CitrusSoundInstance>();
		
		/**
		 * What to do when no new sound channel is available?
		 * remove the first played instance, the last, or simply don't play the sound.
		 * @see REMOVE_FIRST_PLAYED
		 * @see REMOVE_LAST_PLAYED
		 * @see DONT_PLAY
		 */
		public static var onNewChannelsUnavailable:String = REMOVE_FIRST_PLAYED;
		
		/**
		 * offset to use on all sounds in Sound.play().
		 */
		public static var startPositionOffset:Number = 0;
		
		/**
		 * trace all events dispatched from CitrusSoundInstances
		 */
		public static var eventVerbose:Boolean = false;
		
		public function CitrusSoundInstance(parentsound:CitrusSound, autoplay:Boolean = true, autodestroy:Boolean = true)
		{
			_parentsound = parentsound;
			_permanent = _parentsound.permanent;
			_soundTransform = _parentsound.refreshSoundTransform();
			
			_ID = last_id++;
			
			_parentsound.addDispatchChild(this);
			
			_ce = CitrusEngine.getInstance();
			
			_name = _parentsound.name;
			_loops = _parentsound.loops;
			_autodestroy = autodestroy;
			
			if (autoplay)
				play();
		}
		
		public function play():void
		{
			if (_destroyed)
				return;
			
			if (!_isPaused || !_isPlaying)
				playAt(0);
		}
		
		public function playAt(position:Number):void
		{
			if (_destroyed)
				return;
				
			var soundInstance:CitrusSoundInstance;
			
			//check if the same CitrusSound is already playing and is permanent (if so, no need to play a second one)
			if (_permanent && _parentsound.isPlaying)
			{
				dispatcher(CitrusSoundEvent.NO_CHANNEL_AVAILABLE);
				return;
			}
			
			//check if channels are available, if not, free some up (as long as instances are not permanent)
			if (!SoundChannelUtil.hasAvailableChannel() && _nonPermanent.length > 0)
			{
				switch (onNewChannelsUnavailable)
				{
					case REMOVE_FIRST_PLAYED: 
						if (_nonPermanent.length > 0)
							do
							{
								soundInstance = _nonPermanent.pop();
								if (soundInstance)
									if (!soundInstance.isPaused)
										continue;
									else
										soundInstance.stop(true);
								
								if (_nonPermanent.length == 0)
									break;
							} while (!SoundChannelUtil.hasAvailableChannel())
						break;
					case REMOVE_LAST_PLAYED: 
						if (_nonPermanent.length > 0)
							do
							{
								soundInstance = _nonPermanent.shift();
								if (soundInstance)
									if (!soundInstance.isPaused)
										continue;
									else
										soundInstance.stop(true);
								
								if (_nonPermanent.length == 0)
									break;
							} while (!SoundChannelUtil.hasAvailableChannel())
						break;
					case DONT_PLAY: 
						return;
				}
			}
			
			//up to now, we've done everything we could - so someone else stole all available SoundChannels
			if (!SoundChannelUtil.hasAvailableChannel())
			{
				dispatcher(CitrusSoundEvent.NO_CHANNEL_AVAILABLE);
				return;
			}
			
			if (!_parentsound.ready)
			{
				dispatcher(CitrusSoundEvent.SOUND_NOT_READY);
				_parentsound.load();
			}
			
			_isPlaying = true;
			_isPaused = false;
			
			soundChannel = (_parentsound.sound as Sound).play(position, (_loops < 0) ? int.MAX_VALUE : 0, null);
			resetSoundTransform();
			
			if (!_soundChannel)
				return;
			
			_list.unshift(this);
			
			if (!_permanent)
				_nonPermanent.unshift(this);
			
			_parentsound.soundInstances.unshift(this);
			
			if (position == 0 && _loopCount == 0)
				dispatcher(CitrusSoundEvent.SOUND_START);
		}
		
		public function pause():void
		{
			if (_destroyed || !_isPlaying || _isPaused)
				return;
			
			_last_position = _soundChannel.position;
			
			_isPlaying = false;
			_isPaused = true;
			
			_soundChannel.stop();
			soundChannel = SoundChannelUtil.silentSound.play(startPositionOffset, int.MAX_VALUE, SoundChannelUtil.silentST);
			
			dispatcher(CitrusSoundEvent.SOUND_PAUSE);
		}
		
		public function resume():void
		{
			if (_destroyed)
				return;
				
			_isPlaying = true;
			_isPaused = false;
			
			_soundChannel.stop();
			soundChannel = (_parentsound.sound as Sound).play(_last_position, 0, _soundTransform = resetSoundTransform());
			dispatcher(CitrusSoundEvent.SOUND_RESUME);
		}
		
		public function stop(forced:Boolean = false):void
		{
			if (_destroyed)
				return;
				
			_soundChannel.stop();
			soundChannel = null;
			
			_isPlaying = false;
			_isPaused = false;
			
			_loopCount = 0;
			
			removeSelfFromVector(_list);
			removeSelfFromVector(_nonPermanent);
			removeSelfFromVector(_parentsound.soundInstances);
			
			if (forced)
				dispatcher(CitrusSoundEvent.FORCE_STOP);
			
			dispatcher(CitrusSoundEvent.SOUND_END);
			
			if (_autodestroy && !_isPlaying)
				destroy();
		}
		
		public function destroy(forced:Boolean = false):void
		{
			if (_isPlaying || _isPaused)
				stop(forced);
			
			_parentsound.removeDispatchChild(this);
			
			_parentsound = null;
			_soundTransform = null;
			data = null;
			
			removeAllEventListeners();
			
			_destroyed = true;
		}
		
		
		protected function onComplete(e:Event):void
		{
			
			if (_isPaused)
			{
				soundChannel = SoundChannelUtil.silentSound.play(startPositionOffset, int.MAX_VALUE, SoundChannelUtil.silentST);
				return;
			}
			
			_soundTransform = resetSoundTransform();
			_loopCount++;
			
			if (_loops < 0)
			{
				_soundChannel.stop();
				soundChannel = (_parentsound.sound as Sound).play(startPositionOffset, int.MAX_VALUE, _soundTransform);
			}
			else if (_loopCount > _loops)
				stop();
			else
			{
				_soundChannel.stop();
				soundChannel = (_parentsound.sound as Sound).play(startPositionOffset, 0, _soundTransform);
				dispatcher(CitrusSoundEvent.SOUND_LOOP);
			}
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
			if (_soundChannel)
				_soundTransform = resetSoundTransform();
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set panning(value:Number):void
		{
			_panning = value;
			if (_soundChannel)
				_soundTransform = resetSoundTransform();
		}
		
		public function get panning():Number
		{
			return _panning;
		}
		
		public function setVolumePanning(volume:Number = 1, panning:Number = 0):CitrusSoundInstance
		{
			_volume = volume;
			_panning = panning;
			resetSoundTransform();
			return this;
		}
		
		/**
		 * removes self from given vector.
		 * @param	list Vector.&lt;CitrusSoundInstance&gt;
		 */
		public function removeSelfFromVector(list:Vector.<CitrusSoundInstance>):void
		{
			var i:String;
			for (i in list)
				if (list[i] == this)
				{
					list[i] = null;
					list.splice(int(i), 1);
					return;
				}
		}
		
		/**
		 * a vector of all currently playing CitrusSoundIntance objects
		 */
		public static function get activeSoundInstances():Vector.<CitrusSoundInstance>
		{
			return _list.slice();
		}
		
		/**
		 * use this setter when creating a new soundChannel
		 * it will automaticaly add/remove event listeners from the protected _soundChannel
		 */
		internal function set soundChannel(channel:SoundChannel):void
		{
			if (_soundChannel)
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			if (channel)
				channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			
			_soundChannel = channel;
		}
		
		internal function get soundChannel():SoundChannel
		{
			return _soundChannel;
		}
		
		public function get leftPeak():Number
		{
			if (_soundChannel)
				return _soundChannel.leftPeak;
			return 0;
		}
		
		public function get rightPeak():Number
		{
			if (_soundChannel)
				return _soundChannel.rightPeak;
			return 0;
		}
		
		public function get parentsound():CitrusSound
		{
			return _parentsound;
		}
		
		public function get ID():uint
		{
			return _ID;
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
		
		public function get loopCount():uint
		{
			return _loopCount;
		}
		
		public function get loops():int
		{
			return _loops;
		}
		
		/**
		 * dispatches CitrusSoundInstance
		 */
		internal function dispatcher(type:String):void
		{
			var event:CitrusEvent = new CitrusSoundEvent(type, _parentsound, this, ID) as CitrusEvent;
			dispatchEvent(event);
			if (eventVerbose)
				trace(event);
		}
		
		internal function resetSoundTransform():SoundTransform
		{
			var st:SoundTransform = _parentsound.refreshSoundTransform();
			st.volume *= _volume;
			st.pan = _panning;
			if (_soundChannel)
				return _soundTransform = _soundChannel.soundTransform = st;
			else
				return _soundTransform = st;
		}
		
		public function toString():String
		{
			return "CitrusSoundInstance name:" + _name + " id:" + _ID + " playing:" + _isPlaying + " paused:" + _isPaused + "\n";
		}
		
		public static const REMOVE_LAST_PLAYED:String = "REMOVE_LAST_PLAYED";
		public static const REMOVE_FIRST_PLAYED:String = "REMOVE_FIRST_PLAYED";
		public static const DONT_PLAY:String = "DONT_PLAY";
	}

}