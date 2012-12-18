package citrus.core {

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
		public function addSound(id:String, url:String = "", embeddedClass:Class = null):void {
			
			if (url != "")
				sounds[id] = url;
			else
				sounds[id] = embeddedClass;
		}

		public function removeSound(id:String):void {
			
			var currID:String;

			for (currID in currPlayingSounds) {
				if (currID == id) {
					delete currPlayingSounds[id];
					break;
				}
			}

			for (currID in sounds) {
				if (currID == id) {
					delete sounds[id];
					break;
				}
			}
		}

		public function hasSound(id:String):Boolean {
			return Boolean(sounds[id]);
		}

		public function playSound(id:String, volume:Number = 1.0, timesToRepeat:int = 999):void {
			
			// Check for an existing sound, and play it.
			var t:SoundTransform;
			for (var currID:String in currPlayingSounds) {
				if (currID == id) {
					var c:SoundChannel = currPlayingSounds[id].channel as SoundChannel;
					var s:Sound = currPlayingSounds[id].sound as Sound;
					t = new SoundTransform(volume);
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

			t = new SoundTransform(volume);
			channel.soundTransform = t;

			currPlayingSounds[id] = {channel:channel, sound:soundFactory, volume:volume};
		}

		public function stopSound(id:String):void {
			
			for (var currID:String in currPlayingSounds) {
				if (currID == id)
					SoundChannel(currPlayingSounds[id].channel).stop();
			}
		}

		public function setGlobalVolume(volume:Number):void {
			
			for (var currID:String in currPlayingSounds) {
				var s:SoundTransform = new SoundTransform(volume);
				SoundChannel(currPlayingSounds[currID].channel).soundTransform = s;
				currPlayingSounds[currID].volume = volume;
			}
		}

		public function muteAll(mute:Boolean = true):void {
			
			if (mute) {
				setGlobalVolume(0);
			} else {
				for (var currID:String in currPlayingSounds) {
					var s:SoundTransform = new SoundTransform(currPlayingSounds[currID].volume);
					SoundChannel(currPlayingSounds[currID].channel).soundTransform = s;
				}
			}
		}

		public function setVolume(id:String, volume:Number):void {
			
			for (var currID:String in currPlayingSounds) {
				if ( currID == id ) {
					var s:SoundTransform = new SoundTransform(volume);
					SoundChannel(currPlayingSounds[id].channel).soundTransform = s;
					currPlayingSounds[id].volume = volume;
				}
			}
		}

		public function getSoundChannel(id:String):SoundChannel {
			
			for (var currID:String in currPlayingSounds) {
				if (currID == id)
					return SoundChannel(currPlayingSounds[id].channel);
			}
			throw Error("You are trying to get a non-existent soundChannel. Play it first in order to assign a channel");
		}

		public function getSoundTransform(id:String):SoundTransform {
			
			for (var currID:String in currPlayingSounds) {
				if (currID == id)
					return SoundChannel(currPlayingSounds[id].channel).soundTransform;
			}
			throw Error("You are trying to get a non-existent soundTransform. Play it first in order to assign a transform");
		}

		public function getSoundVolume(id:String):Number {
			
			for (var currID:String in currPlayingSounds) {
				if (currID == id)
					return currPlayingSounds[id].volume;
			}
			throw Error("You are trying to get a non-existent volume. Play it first in order to assign a volume.");
		}

		private function handleLoadError(e:IOErrorEvent):void {
			
			trace("Sound manager failed to load a sound: " + e.text);
		}
	}
}