package citrus.core {

	import aze.motion.eaze;

	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class SoundManager {

		private static var _instance:SoundManager;

		public var sounds:Dictionary;
		public var currPlayingSounds:Dictionary;

		public function SoundManager() {
			sounds = new Dictionary();
			currPlayingSounds = new Dictionary();
		}

		public static function getInstance():SoundManager {
			if (!_instance)
				_instance = new SoundManager();

			return _instance;
		}

		public function destroy():void {

			sounds = null;
			currPlayingSounds = null;
		}

		/*
		 * The sound is a path to a file or an embedded sound 
		 */
		public function addSound(id:String, sound:*):void {

			if (sound is String && sound != "")
				sounds[id] = sound;
			else if (sound is Class)
				sounds[id] = sound;
			else
				throw new Error("Sound Manager doesn't know how to add the " + id + " sound: " + sound);
		}

		public function removeSound(id:String):void {

			if (soundIsAdded(id)) {
				delete sounds[id];

				if (soundIsPlaying(id))
					delete currPlayingSounds[id];
			} else {
				throw Error("The sound you are trying to remove is not in the sound manager");
			}
		}

		public function soundIsAdded(id:String):Boolean {
			return Boolean(sounds[id]);
		}

		public function soundIsPlaying(id:String):Boolean {

			for (var currID:String in currPlayingSounds) {
				if ( currID == id )
					return true;
			}
			return false;
		}

		public function playSound(id:String, volume:Number = 1.0, timesToRepeat:int = 999, panning:Number = 0):void {

			// Check for an existing sound, and play it.
			var t:SoundTransform;

			for (var currID:String in currPlayingSounds) {
				if (currID == id) {
					var c:SoundChannel = currPlayingSounds[id].channel as SoundChannel;
					var s:Sound = currPlayingSounds[id].sound as Sound;
					t = new SoundTransform(volume, panning);

					if (s.isBuffering)
						break;

					c = s.play(0, timesToRepeat);
					c.soundTransform = t;
					currPlayingSounds[id] = {channel:c, sound:s, volume:volume};
					return;
				}
			}

			// Create a new sound
			var soundFactory:Sound;
			if (sounds[id] is Class) {
				soundFactory = new sounds[id]() as Sound;
			} else {
				soundFactory = new Sound();
				soundFactory.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
				soundFactory.load(new URLRequest(sounds[id]));
			}

			var channel:SoundChannel = new SoundChannel();
			channel = soundFactory.play(0, timesToRepeat);

			if (!channel)
				return;

			t = new SoundTransform(volume, panning);
			channel.soundTransform = t;

			currPlayingSounds[id] = {channel:channel, sound:soundFactory, volume:volume};
		}

		public function stopSound(id:String):void {

			if (soundIsPlaying(id))
				SoundChannel(currPlayingSounds[id].channel).stop();
		}

		public function setGlobalVolume(volume:Number):void {

			for (var currID:String in currPlayingSounds) {

				var s:SoundTransform = new SoundTransform(volume);
				SoundChannel(currPlayingSounds[currID].channel).soundTransform = s;
				currPlayingSounds[currID].volume = volume;
			}
		}

		public function muteAll(mute:Boolean = true):void {

			var s:SoundTransform;
			var currID:String;

			for (currID in currPlayingSounds) {

				s = new SoundTransform(mute ? 0 : currPlayingSounds[currID].volume);
				SoundChannel(currPlayingSounds[currID].channel).soundTransform = s;
			}
		}

		public function setVolume(id:String, volume:Number):void {

			if (soundIsPlaying(id)) {

				var s:SoundTransform = new SoundTransform(volume);
				SoundChannel(currPlayingSounds[id].channel).soundTransform = s;
				currPlayingSounds[id].volume = volume;
			}
		}

		public function tweenVolume(id:String, volume:Number = 0, tweenDuration:Number = 2):void {

			var s:SoundTransform = new SoundTransform();
			eaze(currPlayingSounds[id]).to(tweenDuration, {volume:volume})
				.onUpdate(function():void {
				s.volume = currPlayingSounds[id].volume;
				SoundChannel(currPlayingSounds[id].channel).soundTransform = s;
			});

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

			if (soundIsPlaying(id))
				return SoundChannel(currPlayingSounds[id].channel);

			throw Error("You are trying to get a non-existent soundChannel. Play it first in order to assign a channel");
		}

		public function getSoundTransform(id:String):SoundTransform {

			if (soundIsPlaying(id))
				return SoundChannel(currPlayingSounds[id].channel).soundTransform;

			throw Error("You are trying to get a non-existent soundTransform. Play it first in order to assign a transform");
		}

		public function getSoundVolume(id:String):Number {

			if (soundIsPlaying(id))
				return currPlayingSounds[id].volume;

			throw Error("You are trying to get a non-existent volume. Play it first in order to assign a volume.");
		}

		private function handleLoadError(e:IOErrorEvent):void {

			trace("Sound manager failed to load a sound: " + e.text);
		}
	}
}
