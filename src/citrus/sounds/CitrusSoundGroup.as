package citrus.sounds 
{
	import citrus.math.MathUtils;
	/**
	 * CitrusSoundGroup represents a volume group with its groupID and has mute control as well.
	 */
	public class CitrusSoundGroup 
	{
		
		public static const BGM:String = "BGM";
		public static const SFX:String = "SFX";
		public static const UI:String = "UI";
		
		protected var _groupID:String;
		
		internal var _volume:Number = 1;
		internal var _mute:Boolean = false;
		
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
		
		internal function addSound(s:CitrusSound):void
		{
			if (s.group && s.group.isadded(s))
				(s.group as CitrusSoundGroup).removeSound(s);
			s.setGroup(this);
			_sounds.push(s);
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
		
		internal function removeSound(s:CitrusSound):void
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
				if (s.name == name)
					return s;
			return null;
		}
		
		public function getRandomSound():CitrusSound
		{
			var index:uint = MathUtils.randomInt(0, _sounds.length - 1);
			return _sounds[index];
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
		
		internal function destroy():void
		{
			var s:CitrusSound;
			for each(s in _sounds)
				removeSound(s);
			_sounds.length = 0;
		}
		
	}

}