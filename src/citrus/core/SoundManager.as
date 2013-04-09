package citrus.core {

	import aze.motion.eaze;

	import org.osflash.signals.Signal;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class SoundManager {

		private static var _instance:SoundManager;

		public var sounds:Dictionary;
		public var readySounds:Dictionary;
		public var loadingQueue:Vector.<Object>;
		
		public var onAllLoaded:Signal;
		public var onSoundComplete:Signal;

		public function SoundManager() {
			sounds = new Dictionary();
			readySounds = new Dictionary();
			loadingQueue = new Vector.<Object>();
			onAllLoaded = new Signal();
			onSoundComplete = new Signal(String);
		}

		public static function getInstance():SoundManager {
			if (!_instance)
				_instance = new SoundManager();

			return _instance;
		}

		public function destroy():void {

			sounds = null;
			readySounds = null;
			loadingQueue.length = 0;
			loadingQueue = null;
			
			onAllLoaded.removeAll();
			onSoundComplete.removeAll();
		}

		/*
		 * The sound is a path to a file or an embedded sound 
		 */
		public function addSound(id:String, sound:*):void {

			if (sound is String && sound != "")
				sounds[id] = sound;
			else if (sound is Sound)
			{
				sounds[id] = sound;
				readySounds[id] = {channel:null, sound:sound, volume:1, playing:false, timesToRepeat:0};
			}
			else if (sound is Class)
				sounds[id] = sound;
			else
				throw new Error("Sound Manager doesn't know how to add the " + id + " sound: " + sound);
		}

		public function removeSound(id:String):void {

			if (soundIsAdded(id)) {
				delete sounds[id];

				if (soundIsReady(id))
					delete readySounds[id];
			} else {
				throw Error("The sound you are trying to remove is not in the sound manager");
			}
		}
		
		/**
		 * pre load / instanciate all added sounds that are not yet sound objects.
		 */
		public function preLoadSounds():void {
			var s:String;
			for (s in sounds)
			{
				if (sounds[s] is Class) {
					sounds[s] = new sounds[s]() as Sound;
					readySounds[s] = {channel:null, sound:sounds[s], volume:1, playing:false, timesToRepeat:0};
				} else if (sounds[s] is String) {
					var soundFactory:Sound;
					soundFactory = new Sound();
					soundFactory.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
					soundFactory.addEventListener(Event.COMPLETE, handleLoadCompleteOnly);
					soundFactory.load(new URLRequest(sounds[s]));
					loadingQueue.push({id:s,sound:soundFactory});
				}
			}
		}

		/**
		 * tells if the sound is added in the list - but not if its ready to be played.
		 * @param	id
		 * @return
		 */
		public function soundIsAdded(id:String):Boolean {
			return (id in sounds);
		}
		
		/**
		 * Tells if a sound is ready to be played from the list of added sounds
		 * @param	id
		 * @return
		 */
		public function soundIsReady(id:String):Boolean {
			return (id in readySounds);
		}
		
		/**
		 * works only for non looping sounds.
		 * @param	id
		 * @return
		 */
		public function soundIsPlaying(id:String):Boolean {
			if (id in readySounds)
				return readySounds[id].playing;
			else
			return false;
		}

		public function playSound(id:String, volume:Number = 1.0, timesToRepeat:int = 999, panning:Number = 0):void {

			// Check for an existing sound, and play it.
			var t:SoundTransform;
			
				ifsoundexists: if (id in readySounds)
				{
					var s:Sound = readySounds[id].sound as Sound;
						
					if (s.isBuffering)
						break ifsoundexists;
							
					var c:SoundChannel = readySounds[id].channel as SoundChannel;
							
					t = new SoundTransform(volume, panning);

					c = s.play(0, timesToRepeat);
					c.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
					c.soundTransform = t;
					readySounds[id] = {channel:c, sound:s, volume:volume,playing:true, timesToRepeat:timesToRepeat};
					return;
				}

			// Create a new sound
			var soundFactory:Sound;
			if (sounds[id] is Class) {
				sounds[id] = soundFactory = new sounds[id]() as Sound;
			} else if (sounds[id] is Sound) {
				soundFactory = sounds[id];	
			} else if(sounds[id] is String){
				soundFactory = new Sound();
				soundFactory.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
				soundFactory.addEventListener(Event.COMPLETE, handleLoadCompleteAndPlay);
				soundFactory.load(new URLRequest(sounds[id]));
				loadingQueue.push({id:id,sound:soundFactory,volume:volume,timesToRepeat:timesToRepeat,panning:panning});
				return;
			} else if (!(id in sounds))
			{
				trace("SoundManager: trying to play a sound not added to the list:",id);
				return;
			}
			else
				return;

			var channel:SoundChannel = new SoundChannel();
			channel = soundFactory.play(0, timesToRepeat);
			channel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
			if (!channel)
				return;

			t = new SoundTransform(volume, panning);
			channel.soundTransform = t;
			
			readySounds[id] = {channel:channel, sound:soundFactory, volume:volume, playing:true, timesToRepeat:timesToRepeat};
		}

		public function stopSound(id:String):void {

			if (soundIsReady(id))
			{
				SoundChannel(readySounds[id].channel).stop();
			}
		}

		public function setGlobalVolume(volume:Number):void {

			for (var currID:String in readySounds) {

				var s:SoundTransform = new SoundTransform(volume);
				SoundChannel(readySounds[currID].channel).soundTransform = s;
				readySounds[currID].volume = volume;
			}
		}

		public function muteAll(mute:Boolean = true):void {

			var s:SoundTransform;
			var currID:String;

			for (currID in readySounds) {

				s = new SoundTransform(mute ? 0 : readySounds[currID].volume);
				SoundChannel(readySounds[currID].channel).soundTransform = s;
			}
		}
		
		/**
		 * Cut the SoundMixer. No sound will be hear.
		 */
		public function muteFlashSound(mute:Boolean = true):void {
			
			var s:SoundTransform = SoundMixer.soundTransform;
			s.volume = mute ? 0 : 1;

			SoundMixer.soundTransform = s;
		}

		public function setVolume(id:String, volume:Number):void {

			if (soundIsReady(id)) {

				var s:SoundTransform = new SoundTransform(volume);
				SoundChannel(readySounds[id].channel).soundTransform = s;
				readySounds[id].volume = volume;
			}
		}

		public function tweenVolume(id:String, volume:Number = 0, tweenDuration:Number = 2):void {

			var s:SoundTransform = new SoundTransform();
			
			if (soundIsPlaying(id)) {
				
				eaze(readySounds[id]).to(tweenDuration, {volume:volume})
					.onUpdate(function():void {
					s.volume = readySounds[id].volume;
					SoundChannel(readySounds[id].channel).soundTransform = s;
				});
				
			} else 
				trace("the sound " + id + " is not playing");
		}

		public function crossFade(fadeOutId:String, fadeInId:String, tweenDuration:Number = 2, fadeInRepetitions:int = 1):void {

			// if the fade-in sound is not already playing, start playing it
			if (!soundIsPlaying(fadeInId))
				playSound(fadeInId, 0, fadeInRepetitions);

			tweenVolume(fadeOutId, 0, tweenDuration);
			tweenVolume(fadeInId, 1, tweenDuration);

			/**
			// stop the fade-out sound when its volume is zero
			Starling.juggler.delayCall(stopSound, tweenDuration, fadeOutId);
			 */
		}

		public function getSoundChannel(id:String):SoundChannel {

			if (soundIsReady(id))
				return SoundChannel(readySounds[id].channel);

			throw Error("You are trying to get a non-existent soundChannel. Play it first in order to assign a channel");
		}

		public function getSoundTransform(id:String):SoundTransform {

			if (soundIsReady(id))
				return SoundChannel(readySounds[id].channel).soundTransform;

			throw Error("You are trying to get a non-existent soundTransform. Play it first in order to assign a transform");
		}

		public function getSoundVolume(id:String):Number {

			if (soundIsReady(id))
				return readySounds[id].volume;

			throw Error("You are trying to get a non-existent volume. Play it first in order to assign a volume.");
		}

		private function handleLoadError(e:IOErrorEvent):void {
			(e.target as Sound).removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);
			var s:String;
			for (s in loadingQueue)
					if (loadingQueue[s].sound == e.target)
						loadingQueue.splice(uint(s), 1);
			trace("Sound manager failed to load a sound: " + e.text);
		}
		
		private function handleSoundComplete(e:Event):void
		{
			var id:String;
			for (id in readySounds)
			{
				if (readySounds[id].channel == e.target)
				{
					(e.target as SoundChannel).removeEventListener(Event.SOUND_COMPLETE, arguments.callee);
					readySounds[id].playing = false;
					onSoundComplete.dispatch(id);
				}
			}
		}
		
		/**
		 * Called after playSound when sound is loaded if sound was a url.
		 */
		private function handleLoadCompleteAndPlay(e:Event):void
		{
			(e.target as Sound).removeEventListener(Event.COMPLETE, arguments.callee);
			var s:String;
			for (s in loadingQueue)
					if (loadingQueue[s].sound == e.target)
					{
						var o:Object = loadingQueue[s];
						sounds[o.id] = e.target as Sound;
						loadingQueue.splice(uint(s), 1);
						if (loadingQueue.length < 1)
							onAllLoaded.dispatch();
						
						var channel:SoundChannel = new SoundChannel();
						channel = o.sound.play(0, o.timesToRepeat);
						channel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
						if (channel == null)
							return;
							var t:SoundTransform = new SoundTransform(o.volume, o.panning);
							channel.soundTransform = t;
							readySounds[o.id] = { channel:channel, sound:o.sound, volume:o.volume ,playing:true ,timesToRepeat:o.timesToRepeat};
						return;
					}
					
			trace("SoundManager: complete loading of", e.target, "but couldn't play.");
		}
		
		private function handleLoadCompleteOnly(e:Event):void
		{
			(e.target as Sound).removeEventListener(Event.COMPLETE, arguments.callee);
			var s:String;
			for (s in loadingQueue)
					if (loadingQueue[s].sound == e.target)
					{
						var o:Object = loadingQueue[s];
						sounds[o.id] = e.target as Sound;
						loadingQueue.splice(uint(s), 1);
						readySounds[o.id] = { channel:new SoundChannel(), sound:o.sound, volume:1 , playing:false ,timesToRepeat:0};
						if (loadingQueue.length < 1)
							onAllLoaded.dispatch();
						return;
					}
					
			trace("SoundManager: complete loading of", e.target, "but couldn't add.");
		}
	}
}
