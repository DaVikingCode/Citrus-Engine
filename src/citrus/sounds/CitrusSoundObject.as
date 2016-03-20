package citrus.sounds 
{
	import citrus.core.CitrusEngine;
	import citrus.events.CitrusSoundEvent;
	import citrus.math.MathUtils;
	import citrus.math.MathVector;
	import citrus.view.ISpriteView;
	import flash.geom.Rectangle;
	
	/**
	 * sound object in a CitrusSoundSpace
	 */
	public class CitrusSoundObject 
	{
		protected var _ce:CitrusEngine;
		protected var _space:CitrusSoundSpace;
		protected var _citrusObject:ISpriteView;
		protected var _sounds:Vector.<CitrusSoundInstance> = new Vector.<CitrusSoundInstance>();
		protected var _enabled:Boolean = true;
		
		public static var panAdjust:Function = MathUtils.easeInCubic;
		public static var volAdjust:Function = MathUtils.easeOutQuad;
		
		protected var _camVec:MathVector = new MathVector();
		protected var _rect:Rectangle = new Rectangle();
		
		protected var _volume:Number = 1;
		
		/**
		 * radius or this sound object. this determines at what distance will the sound start to get heard.
		 */
		public var radius:Number = 600;
		
		public function CitrusSoundObject(citrusObject:ISpriteView) 
		{
			_ce = CitrusEngine.getInstance();
			_space = _ce.state.getFirstObjectByType(CitrusSoundSpace) as CitrusSoundSpace;
			if (!_space)
				throw new Error("[CitrusSoundObject] for " + citrusObject["name"] + " couldn't find a CitrusSoundSpace.");
				
			_citrusObject = citrusObject;
			_space.add(this);
		}
		
		public function initialize():void
		{
			
		}
		
		/**
		 * play a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
		public function play(sound:*):CitrusSoundInstance
		{
			var citrusSound:CitrusSound;
			var soundInstance:CitrusSoundInstance;
			
			if (sound is String)
				citrusSound = _space.soundManager.getSound(sound);
			else if (sound is CitrusSound)
				citrusSound = sound;
				
			if (citrusSound != null)
			{
				soundInstance = citrusSound.createInstance(false, true);
				if (soundInstance)
					{
						soundInstance.addEventListener(CitrusSoundEvent.SOUND_START, onSoundStart);
						soundInstance.addEventListener(CitrusSoundEvent.SOUND_END, onSoundEnd);
						soundInstance.play();
						updateSoundInstance(soundInstance, _camVec.length);
					}
			}
			
			return soundInstance;
		}
		
		/**
		 * pause a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
		public function pause(sound:*):void
		{
			var citrusSound:CitrusSound;
			var soundInstance:CitrusSoundInstance;
			
			if (sound is String)
				citrusSound = _space.soundManager.getSound(sound);
			else if (sound is CitrusSound)
				citrusSound = sound;
				
			if(citrusSound)
				citrusSound.pause();
		}
		
		/**
		 * resume a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
		public function resume(sound:*):void
		{
			var citrusSound:CitrusSound;
			var soundInstance:CitrusSoundInstance;
			
			if (sound is String)
				citrusSound = _space.soundManager.getSound(sound);
			else if (sound is CitrusSound)
				citrusSound = sound;
				
			if (citrusSound)
			{
				citrusSound.resume();
				updateSoundInstance(soundInstance, _camVec.length);
			}
		}
		
		
		/**
		 * stop a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
		public function stop(sound:*):void
		{
			var citrusSound:CitrusSound;
			var soundInstance:CitrusSoundInstance;
			
			if (sound is String)
				citrusSound = _space.soundManager.getSound(sound);
			else if (sound is CitrusSound)
				citrusSound = sound;
				
			if(citrusSound)
				citrusSound.stop();
		}
		
		public function pauseAll():void
		{
			var soundInstance:CitrusSoundInstance;
			for each(soundInstance in _sounds)
				soundInstance.pause();
		}
		
		public function resumeAll():void
		{
			var soundInstance:CitrusSoundInstance;
			for each(soundInstance in _sounds)
				soundInstance.resume();
		}
		
		public function stopAll():void
		{
			var s:CitrusSoundInstance;
			for each (s in _sounds)
				s.stop();
		}
		
		protected function onSoundStart(e:CitrusSoundEvent):void
		{
			_sounds.push(e.soundInstance);
		}
		
		protected function onSoundEnd(e:CitrusSoundEvent):void
		{
			e.soundInstance.removeEventListener(CitrusSoundEvent.SOUND_START, onSoundStart);
			e.soundInstance.removeEventListener(CitrusSoundEvent.SOUND_END, onSoundEnd);
			e.soundInstance.removeSelfFromVector(_sounds);
		}
		
		public function update():void
		{
			if (_enabled)
				updateSounds();
		}
		
		protected function updateSounds():void
		{
			var distance:Number = _camVec.length;
			var soundInstance:CitrusSoundInstance;
			
			for each (soundInstance in _sounds)
			{
				if (!soundInstance.isPlaying)
					return;
				updateSoundInstance(soundInstance, distance);
			}
		}
		
		protected function updateSoundInstance(soundInstance:CitrusSoundInstance,distance:Number = 0):void
		{
			var volume:Number = distance > radius ? 0 : 1 - distance / radius;
				soundInstance.volume = adjustVolume(volume) * _volume;
				
			var panning:Number = (Math.cos(_camVec.angle) * distance) / 
			( (_rect.width /_rect.height) * 0.5 );
			soundInstance.panning = adjustPanning(panning);
		}
		
		public function adjustPanning(value:Number):Number
		{
			if (value <= -1)
				return -1;
			else if (value >= 1)
				return 1;
			
			if (value < 0)
				return -panAdjust(-value, 0, 1, 1);
			else if (value > 0)
				return panAdjust(value, 0, 1, 1);
			return value;
		}
		
		public function adjustVolume(value:Number):Number
		{
			if (value <= 0)
				return 0;
			else if (value >= 1)
				return 1;
				
			return volAdjust(value, 0, 1, 1);
		}
		
		public function destroy():void
		{
			_space.remove(this);
			
			var soundInstance:CitrusSoundInstance;
			for each(soundInstance in _sounds)
				soundInstance.stop(true);
			
			_sounds.length = 0;
			_ce = null;
			_camVec = null;
			_citrusObject = null;
			_space = null;
		}
		
		public function get citrusObject():ISpriteView
		{
			return _citrusObject;
		}
		
		public function get totalVolume():Number
		{
			var soundInstance:CitrusSoundInstance;
			var total:Number = 0;
			for each(soundInstance in _sounds)
				total += soundInstance.leftPeak + soundInstance.rightPeak;
			if(_sounds.length>0)
				total /= _sounds.length * 2;
			return total;
		}
		
		public function get rect():Rectangle
		{
			return _rect;
		}
		
		public function get camVec():MathVector
		{
			return _camVec;
		}
		
		/**
		 * volume multiplier for this CitrusSoundObject
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			_volume = value;
		}
		
		public function get activeSoundInstances():Vector.<CitrusSoundInstance>
		{
			return _sounds.slice();
		}
		
	}

}