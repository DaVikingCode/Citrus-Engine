package citrus.sounds 
{
	import citrus.sounds.cesound;
	
	/**
	 * CitrusSoundGroup represents a volume group with its groupID
	 * and has mute control as well.
	 */
	public class CitrusSoundGroup 
	{
		use namespace cesound;
		
		public static const BGM:String = "BGM";
		public static const SFX:String = "SFX";
		
		protected var _groupID:String;
		
		cesound var _volume:Number = 1;
		cesound var _mute:Boolean = false;
		
		protected var _sounds:Vector.<CitrusSound>;
		
		public function CitrusSoundGroup() 
		{
			_sounds = new Vector.<CitrusSound>();
		}
		
		protected function applyChanges():void
		{
			var s:CitrusSound;
			for each(s in _sounds)
				s.refreshSoundTransform();
		}
		
		cesound function addSound(s:CitrusSound):void
		{
			if (s.cesound::group && s.cesound::group.isadded(s))
				(s.cesound::group as CitrusSoundGroup).removeSound(s);
			s.setGroup(this);
			_sounds.push(s);
		}
		
		cesound function isadded(sound:CitrusSound):Boolean
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
		
		cesound function removeSound(s:CitrusSound):void
		{
			var si:String;
			for (si in _sounds)
			{
				if (_sounds[si] == s)
				{
					CitrusSound(_sounds[si]).setGroup(null);
					CitrusSound(_sounds[si]).refreshSoundTransform();
					_sounds.splice(uint(si), 1);
					break;
				}
			}
		}
		
		public function getSound(name:String):CitrusSound
		{
			var s:CitrusSound;
			for each(s in _sounds)
				if (s.cesound::name == name)
					return s;
			return null;
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
		
		public function get groupID():String
		{
			return _groupID;
		}
		
		cesound function destroy():void
		{
			var s:CitrusSound;
			for each(s in _sounds)
				removeSound(s);
			_sounds.length = 0;
		}
		
	}

}