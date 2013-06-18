package citrus.sounds {

	import aze.motion.eaze;
	
	import citrus.core.citrus_internal;
	import citrus.sounds.groups.BGMGroup;
	import citrus.sounds.groups.SFXGroup;

	import flash.events.EventDispatcher;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;

	public class SoundManager extends EventDispatcher {
		
		use namespace citrus_internal;
		
		private static var _instance:SoundManager;

		protected var soundsDic:Dictionary;
		protected var soundGroups:Vector.<CitrusSoundGroup>;
		
		protected var _masterVolume:Number = 1;
		protected var _masterMute:Boolean = false;

		public function SoundManager() {
			
			soundsDic = new Dictionary();
			soundGroups = new Vector.<CitrusSoundGroup>();
			
			//default groups
			soundGroups.push(new BGMGroup());
			soundGroups.push(new SFXGroup());
			
			CitrusSound._sm = this;
		}

		public static function getInstance():SoundManager {
			if (!_instance)
				_instance = new SoundManager();

			return _instance;
		}

		public function destroy():void {

			var csg:CitrusSoundGroup;
			for each(csg in soundGroups)
				csg.destroy();
				
			var s:CitrusSound;
			for each(s in soundsDic)
				s.destroy();
				
			soundsDic = null;
			_instance = null;
		}
		
		/**
		 * Register a new sound an initialize its values with the params objects. Accepted parameters are:
		 * <ul><li>sound : a url, a class or a Sound object.</li>
		 * <li>volume : the initial volume. the real final volume is calculated like so : volume x group volume x master volume.</li>
		 * <li>panning : value between -1 and 1 - unaffected by group or master.</li>
		 * <li>mute : default false, whether to start of muted or not.</li>
		 * <li>timesToPlay : default 1 (plays once) . 0 or a negative number will make the sound loop infinitely.</li>
		 * <li>group : the groupID of a group, no groups are set by default. default groups ID's are CitrusSoundGroup.SFX (sound effects) and CitrusSoundGroup.BGM (background music)</li>
		 * <li>triggerSoundComplete : whether to dispatch a CitrusSoundEvent on each loop of type CitrusSoundEvent.SOUND_COMPLETE .</li>
		 * <li>triggerRepeatComplete : whether to dispatch a CitrusSoundEvent of type CitrusSoundEvent.REPEAT_COMPLETE when a sounds has played 'timesToPlay' times.</li></ul>
		 */
		public function addSound(id:String, params:Object = null):void {
			if (!params.hasOwnProperty("sound"))
				throw new Error("SoundManager addSound() sound:"+id+"can't be added with no sound definition in the params.");
			if (id in soundsDic)
				trace(this, id, "already exists.");
			else
				soundsDic[id] = new CitrusSound(id, params);
		}
		
		/**
		 * add your own custom CitrusSoundGroup here.
		 */
		public function addGroup(group:CitrusSoundGroup):void
		{
			soundGroups.push(group);
		}
		
		/**
		 * removes a group and detaches all its sounds - they will now have their default volume modulated only by masterVolume
		 */
		public function removeGroup(groupID:String):void
		{
			var g:CitrusSoundGroup = getGroup(groupID);
			var i:int = soundGroups.lastIndexOf(g);
			if ( i > -1)
			{
				soundGroups.splice(i, 1);
				g.destroy();
			}
			else
				trace("Sound Manager : group", groupID, "not found for removal.");
		}
		
		/**
		 * moves a sound to a group - if groupID is null, sound is simply removed from any groups
		 * @param	soundName 
		 * @param	groupID ("BGM", "SFX" or custom group id's)
		 */
		public function moveSoundToGroup(soundName:String, groupID:String = null):void
		{
			var s:CitrusSound;
			var g:CitrusSoundGroup;
			if (soundName in soundsDic)
			{
				s = soundsDic[soundName];
				if (s.citrus_internal::group != null)
					s.citrus_internal::group.removeSound(s);
				if(groupID != null)
				g = getGroup(groupID)
				if (g)
					g.addSound(s);
			}
			else
				trace(this,"moveSoundToGroup() : sound",soundName,"doesn't exist.");
		}
		
		/**
		 * return group of id 'name' , defaults would be SFX or BGM
		 * @param	name
		 * @return CitrusSoundGroup
		 */
		public function getGroup(name:String):CitrusSoundGroup
		{
			var sg:CitrusSoundGroup;
			for each(sg in soundGroups)
			{
				if (sg.groupID == name)
					return sg;
			}
			trace(this,"getGroup() : group",name,"doesn't exist.");
			return null;
		}
		
		/**
		 * returns a CitrusSound object. you can use this reference to change volume/panning/mute or play/pause/resume/stop sounds without going through SoundManager's methods.
		 */
		public function getSound(name:String):CitrusSound
		{
			if (name in soundsDic)
				return soundsDic[name];
			else
				trace(this,"getSound() : sound",name,"doesn't exist.");
			return null;
		}
		
		/**
		 * helper method to play a sound by its id
		 */
		public function playSound(id:String):void {
			if (id in soundsDic)
				CitrusSound(soundsDic[id]).play();
			else
				trace(this,"playSound() : sound",id,"doesn't exist.");
		}
		
		/**
		 * helper method to pause a sound by its id
		 */
		public function pauseSound(id:String):void {
			if (id in soundsDic)
				CitrusSound(soundsDic[id]).pause();
			else
				trace(this,"pauseSound() : sound",id,"doesn't exist.");
		}
		
		/**
		 * helper method to resume a sound by its id
		 */
		public function resumeSound(id:String):void {
			if (id in soundsDic)
				CitrusSound(soundsDic[id]).pause();
			else
				trace(this,"resumeSound() : sound",id,"doesn't exist.");
		}
		
		/**
		 * pauses all playing sounds
		 */
		public function pauseAll():void
		{
			var s:CitrusSound;
			for each(s in soundsDic)
				if (s.isPlaying)
					s.pause();
		}
		
		/**
		 * resumes all paused sounds
		 */
		public function resumeAll():void
		{
			var s:CitrusSound;
			for each(s in soundsDic)
				if (s.isPaused)
					s.resume();
		}
		
		public function stopSound(id:String):void {
			if (id in soundsDic)
				CitrusSound(soundsDic[id]).stop();
			else
				trace(this,"stopSound() : sound",id,"doesn't exist.");
		}
		
		public function removeSound(id:String):void {
			stopSound(id);
			if (id in soundsDic)
			{
				CitrusSound(soundsDic[id]).destroy();
				soundsDic[id] = null;
				delete soundsDic[id];
			}
			else
				trace(this,"removeSound() : sound",id,"doesn't exist.");
		}
		
		public function removeAllSounds():void {
			var cs:CitrusSound;
			for each(cs in soundsDic)
				removeSound(cs.name);
		}
		
		public function get masterVolume():Number
		{
			return _masterVolume;
		}
		
		public function get masterMute():Boolean
		{
			return _masterMute;
		}
		
		/**
		 * sets the master volume : resets all sound transforms to masterVolume*groupVolume*soundVolume
		 */
		public function set masterVolume(val:Number):void
		{
			var tm:Number = _masterVolume;
			if (val >= 0 && val <= 1)
				_masterVolume = val;
			else
				_masterVolume = 1;
			
			if (tm != _masterVolume)
			{
				var s:String;
				for (s in soundsDic)
					soundsDic[s].refreshSoundTransform();
			}
		}
		
		/**
		 * sets the master mute : resets all sound transforms to volume 0 if true, or 
		 * returns to normal volue if false : normal volume is masterVolume*groupVolume*soundVolume
		 */
		public function set masterMute(val:Boolean):void
		{
			if (val != _masterMute)
			{
				_masterMute = val;
				var s:String;
				for (s in soundsDic)
					soundsDic[s].refreshSoundTransform();
			}
		}

		/**
		 * tells if the sound is added in the list.
		 * @param	id
		 * @return
		 */
		public function soundIsAdded(id:String):Boolean {
			return (id in soundsDic);
		}
		
		/**
		 * tells you if a sound is playing or false if sound is not identified.
		 */
		public function soundIsPlaying(id:String):Boolean {
			return (id in soundsDic) ? CitrusSound(soundsDic[id]).isPlaying :
				trace(this,"soundIsPlaying() : sound",id,"doesn't exist.");
		}
		
		/**
		 * tells you if a sound is paused or false if sound is not identified.
		 */
		public function soundIsPaused(id:String):* {
			return (id in soundsDic) ? CitrusSound(soundsDic[id]).isPaused :
				trace(this,"soundIsPaused() : sound",id,"doesn't exist.");
		}
		
		/**
		 * Cut the SoundMixer. No sound will be heard.
		 */
		public function muteFlashSound(mute:Boolean = true):void {
			
			var s:SoundTransform = SoundMixer.soundTransform;
			s.volume = mute ? 0 : 1;
			SoundMixer.soundTransform = s;
		}

		/**
		 * set volume of an individual sound (its group volume and the master volume will be multiplied to it to get the final volume)
		 */
		public function setVolume(id:String, volume:Number):void {
			if (id in soundsDic)
				soundsDic[id].citrus_internal::volume = volume;
			else
				trace(this, "setVolume() : sound", id, "doesn't exist.");
		}
		
		/**
		 * set pan of an individual sound (not affected by group or master
		 */
		public function setPanning(id:String, panning:Number):void {
			if (id in soundsDic)
				soundsDic[id].citrus_internal::panning = panning;
			else
				trace(this, "setPanning() : sound", id, "doesn't exist.");
		}
		
		/**
		 * set mute of a sound : if set to mute, neither the group nor the master volume will affect this sound of course.
		 */
		public function setMute(id:String, mute:Boolean):void {
			if (id in soundsDic)
				soundsDic[id].citrus_internal::mute = mute;
			else
				trace(this, "setMute() : sound", id, "doesn't exist.");
		}
		
		/**
		 * Stop playing all the current sounds.
		 * @param except an array of soundIDs you want to preserve.
		 */		
		public function stopAllPlayingSounds(...except):void {
			
			var killSound:Boolean;
			var cs:CitrusSound;
			loop1:for each(cs in soundsDic) {
					
				for each (var soundToPreserve:String in except)
					if (soundToPreserve == cs.name)
						break loop1;
				
				if (soundIsPlaying(cs.name))
					stopSound(cs.name);
			}
		}

		public function tweenVolume(id:String, volume:Number = 0, tweenDuration:Number = 2):void {
			if (soundIsPlaying(id)) {
				var tweenvolObject:Object = {volume:CitrusSound(soundsDic[id]).public::volume};
				
				eaze(tweenvolObject).to(tweenDuration, {volume:volume})
					.onUpdate(function():void {
					CitrusSound(soundsDic[id]).citrus_internal::volume = tweenvolObject.volume;
				});
			} else 
				trace("the sound " + id + " is not playing");
		}

		public function crossFade(fadeOutId:String, fadeInId:String, tweenDuration:Number = 2):void {

			// if the fade-in sound is not already playing, start playing it
			if (!soundIsPlaying(fadeInId))
				playSound(fadeInId);

			tweenVolume(fadeOutId, 0, tweenDuration);
			tweenVolume(fadeInId, 1, tweenDuration);
		}
		
		citrus_internal function soundLoaded(s:CitrusSound):void
		{
			dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_LOADED, s));
			var cs:CitrusSound;
			for each(cs in soundsDic)
				if (!cs.loaded)
					return;
			dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.ALL_SOUNDS_LOADED, s));
		}
	}
}
