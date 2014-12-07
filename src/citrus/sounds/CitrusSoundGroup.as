package citrus.sounds 
{
	import citrus.events.CitrusEventDispatcher;
	import citrus.events.CitrusSoundEvent;
	import citrus.math.MathUtils;
	/**
	 * CitrusSoundGroup represents a volume group with its groupID and has mute control as well.
	 */
	public class CitrusSoundGroup extends CitrusEventDispatcher
	{
		
		public static const BGM:String = "BGM";
		public static const SFX:String = "SFX";
		public static const UI:String = "UI";
		
		protected var _groupID:String;
		
		internal var _volume:Number = 1;
		internal var _mute:Boolean = false;
		
		protected var _sounds:Vector.<CitrusSound>;
		
		public var polyphonic:Boolean = true;
		
		public function CitrusSoundGroup() 
		{
			_sounds = new Vector.<CitrusSound>();
		}
		
		protected function applyChanges():void
		{
			var s:CitrusSound;
			for each(s in _sounds)
				s.resetSoundTransform(true);
		}
		
		internal function addSound(s:CitrusSound):void
		{
			if (s.group && s.group.isadded(s))
				(s.group as CitrusSoundGroup).removeSound(s);
			s.setGroup(this);
			_sounds.push(s);
			s.addEventListener(CitrusSoundEvent.SOUND_LOADED, handleSoundLoaded);
		}
		
		internal function isadded(sound:CitrusSound):Boolean
		{
			var s:CitrusSound;
			for each(s in _sounds)
				if (sound == s)
					return true;
			return false;
		}
		
		public function getAllSounds():Vector.<CitrusSound>
		{
			return _sounds.slice();
		}
		
		public function preloadSounds():void
		{
			var s:CitrusSound;
			for each(s in _sounds)
				if(!s.loaded)	
					s.load();
		}
		
		public function stopAllSounds():void
		{
			var s:CitrusSound;
			for each(s in _sounds)
				s.stop();
		}
		
		internal function removeSound(s:CitrusSound):void
		{
			var si:String;
			var cs:CitrusSound;
			for (si in _sounds)
			{
				if (_sounds[si] == s)
				{
					cs = _sounds[si];
					cs.setGroup(null);
					cs.resetSoundTransform(true);
					cs.removeEventListener(CitrusSoundEvent.SOUND_LOADED, handleSoundLoaded);
					_sounds.splice(uint(si), 1);
					break;
				}
			}
		}
		
		public function getSound(name:String):CitrusSound
		{
			var s:CitrusSound;
			for each(s in _sounds)
				if (s.name == name)
					return s;
			return null;
		}
		
		public function getRandomSound():CitrusSound
		{
			var index:uint = MathUtils.randomInt(0, _sounds.length - 1);
			return _sounds[index];
		}
		
		protected function handleSoundLoaded(e:CitrusSoundEvent):void
		{
			var cs:CitrusSound;
			for each(cs in _sounds)
			{
				if (!cs.loaded)
					return;
			}
			dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.ALL_SOUNDS_LOADED, e.sound, null));
		}
		
		public function set mute(val:Boolean):void
		{
			_mute = val;
			applyChanges();
		}
		
		public function get mute():Boolean
		{
			return _mute;
		}
		
		public function set volume(val:Number):void
		{
			_volume = val;
			applyChanges();
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function get isPlaying():Boolean
		{
			for each(var s:CitrusSound in _sounds)
				if(s.isPlaying)
					return true;
					
			return false;
		}
		
		public function get groupID():String
		{
			return _groupID;
		}
		
		internal function destroy():void
		{
			var s:CitrusSound;
			for each(s in _sounds)
				removeSound(s);
			_sounds.length = 0;
			removeEventListeners();
		}
		
	}

}