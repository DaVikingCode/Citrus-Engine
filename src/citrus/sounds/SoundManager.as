package citrus.sounds {

	import aze.motion.eaze;
	
	import citrus.core.citrus_internal;

	import citrus.events.CitrusEventDispatcher;
	import citrus.events.CitrusSoundEvent;

	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;

	public class SoundManager extends CitrusEventDispatcher {
		
		internal static var _instance:SoundManager;

		protected var soundsDic:Dictionary;
		protected var soundGroups:Vector.<CitrusSoundGroup>;
		
		protected var _masterVolume:Number = 1;
		protected var _masterMute:Boolean = false;

		public function SoundManager() {
			
			soundsDic = new Dictionary();
			soundGroups = new Vector.<CitrusSoundGroup>();
			
			//default groups
			createGroup(CitrusSoundGroup.BGM);
			createGroup(CitrusSoundGroup.SFX);
			createGroup(CitrusSoundGroup.UI);
			
			addEventListener(CitrusSoundEvent.SOUND_LOADED, handleSoundLoaded);
			
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
			
			removeEventListeners();
		}
		
		/**
		 * Register a new sound an initialize its values with the params objects. Accepted parameters are:
		 * <ul><li>sound : a url, a class or a Sound object.</li>
		 * <li>volume : the initial volume. the real final volume is calculated like so : volume x group volume x master volume.</li>
		 * <li>panning : value between -1 and 1 - unaffected by group or master.</li>
		 * <li>mute : default false, whether to start of muted or not.</li>
		 * <li>loops : default 0 (plays once) . -1 will loop infinitely using Sound.play(0,int.MAX_VALUE) and a positive value will use an event based looping system and events will be triggered from CitrusSoundInstance when sound complete and loops back</li>
		 * <li>permanent : by default set to false. if set to true, this sound cannot be forced to be stopped to leave room for other sounds (if for example flash soundChannels are not available) and cannot be played more than once . By default sounds can be forced to stop, that's good for sound effects. You would want your background music to be set as permanent.</li>
		 * <li>group : the groupID of a group, no groups are set by default. default groups ID's are CitrusSoundGroup.SFX (sound effects) and CitrusSoundGroup.BGM (background music)</li>
		 * </ul>
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
		public function addGroup(group:CitrusSoundGroup):CitrusSoundGroup
		{
			soundGroups.push(group);
			return group;
		}
		
		/**
		 * create a CitrusSoundGroup with a group id.
		 */
		public function createGroup(groupID:String):CitrusSoundGroup
		{
			var group:CitrusSoundGroup;
			
			for each(var sg:CitrusSoundGroup in soundGroups)
				if (sg.groupID == groupID)
					group = sg;
			
			if (group != null)
			{
				trace("Sound Manager : trying to create group ", groupID, " but it already exists.");
				return group;
			}
			
			group = new CitrusSoundGroup();
			group.citrus_internal::setGroupID(groupID);
			soundGroups.push(group);
			return group;
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
				if (s.group != null)
					s.group.removeSound(s);
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
		
		public function preloadAllSounds():void
		{
			var cs:CitrusSound;
			for each (cs in soundsDic)
				cs.load();
		}
		
		/**
		 * pauses all playing sounds
		 * @param except list of sound names to not pause.
		 */
		public function pauseAll(...except):void
		{
			loop1:for each(var cs:CitrusSound in soundsDic) {
					for each (var soundToPreserve:String in except)
						if (soundToPreserve == cs.name)
							continue loop1;
					cs.pause();
			}	
		}
		
		/**
		 * resumes all paused sounds
		 * @param except list of sound names to not resume.
		 */
		public function resumeAll(...except):void
		{
			loop1:for each(var cs:CitrusSound in soundsDic) {
					for each (var soundToPreserve:String in except)
						if (soundToPreserve == cs.name)
							continue loop1;
					cs.resume();
			}	
		}
		
		public function playSound(id:String):CitrusSoundInstance {
			if (id in soundsDic)
				return CitrusSound(soundsDic[id]).play();
			else
				trace(this, "playSound() : sound", id, "doesn't exist.");
			return null;
		}
		
		public function pauseSound(id:String):void {
			if (id in soundsDic)
				CitrusSound(soundsDic[id]).pause();
			else
				trace(this,"pauseSound() : sound",id,"doesn't exist.");
		}
		
		public function resumeSound(id:String):void {
			if (id in soundsDic)
				CitrusSound(soundsDic[id]).resume();
			else
				trace(this,"resumeSound() : sound",id,"doesn't exist.");
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
		
		public function soundIsPlaying(sound:String):Boolean
		{
			if (sound in soundsDic)
					return CitrusSound(soundsDic[sound]).isPlaying;
			else
				trace(this, "soundIsPlaying() : sound", sound, "doesn't exist.");
			return false;
		}
		
		public function soundIsPaused(sound:String):Boolean
		{
			if (sound in soundsDic)
					return CitrusSound(soundsDic[sound]).isPaused;
			else
				trace(this, "soundIsPaused() : sound", sound, "doesn't exist.");
			return false;
		}
		
		public function removeAllSounds(...except):void {
			
			loop1:for each(var cs:CitrusSound in soundsDic) {
					for each (var soundToPreserve:String in except)
						if (soundToPreserve == cs.name)
							continue loop1;
					removeSound(cs.name);
			}
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
					soundsDic[s].resetSoundTransform(true);
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
					soundsDic[s].resetSoundTransform(true);
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
		 * Mute/unmute Flash' SoundMixer. No sound will be heard but they're still playing.
		 */
		public function muteFlashSound(mute:Boolean = true):void {
			
			var s:SoundTransform = SoundMixer.soundTransform;
			s.volume = mute ? 0 : 1;
			SoundMixer.soundTransform = s;
		}
		
		/**
		 * Return true if Flash' SoundMixer is muted.
		 */
		public function isFlashSoundMuted():Boolean {
			
			return SoundMixer.soundTransform.volume == 0;
		}

		/**
		 * set volume of an individual sound (its group volume and the master volume will be multiplied to it to get the final volume)
		 */
		public function setVolume(id:String, volume:Number):void {
			if (id in soundsDic)
				soundsDic[id].volume = volume;
			else
				trace(this, "setVolume() : sound", id, "doesn't exist.");
		}
		
		/**
		 * set pan of an individual sound (not affected by group or master
		 */
		public function setPanning(id:String, panning:Number):void {
			if (id in soundsDic)
				soundsDic[id].panning = panning;
			else
				trace(this, "setPanning() : sound", id, "doesn't exist.");
		}
		
		/**
		 * set mute of a sound : if set to mute, neither the group nor the master volume will affect this sound of course.
		 */
		public function setMute(id:String, mute:Boolean):void {
			if (id in soundsDic)
				soundsDic[id].mute = mute;
			else
				trace(this, "setMute() : sound", id, "doesn't exist.");
		}
		
		/**
		 * Stop playing all the current sounds.
		 * @param except an array of soundIDs you want to preserve.
		 */		
		public function stopAllPlayingSounds(...except):void {
			
			loop1:for each(var cs:CitrusSound in soundsDic) {
					for each (var soundToPreserve:String in except)
						if (soundToPreserve == cs.name)
							continue loop1;
					stopSound(cs.name);
			}
		}

		/**
		 * tween the volume of a CitrusSound. If callback is defined, its optional argument will be the CitrusSound.
		 * @param	id
		 * @param	volume
		 * @param	tweenDuration
		 * @param	callback
		 */
		public function tweenVolume(id:String, volume:Number = 0, tweenDuration:Number = 2, callback:Function = null):void {
			if (soundIsPlaying(id)) {
				
				var citrusSound:CitrusSound = CitrusSound(soundsDic[id]);
				var tweenvolObject:Object = {volume:citrusSound.volume};
				
				eaze(tweenvolObject).to(tweenDuration, {volume:volume})
					.onUpdate(function():void {
					citrusSound.volume = tweenvolObject.volume;
				}).onComplete(function():void
				{
					
					if (callback != null)
						if (callback.length == 0)
							callback();
						else
							callback(citrusSound);
				});
			} else 
				trace("the sound " + id + " is not playing");
		}

		public function crossFade(fadeOutId:String, fadeInId:String, tweenDuration:Number = 2):void {

			tweenVolume(fadeOutId, 0, tweenDuration);
			tweenVolume(fadeInId, 1, tweenDuration);
		}
		
		protected function handleSoundLoaded(e:CitrusSoundEvent):void
		{
			var cs:CitrusSound;
			for each(cs in soundsDic)
				if (!cs.loaded)
					return;
			dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.ALL_SOUNDS_LOADED, e.sound,null));
		}
	}
}
