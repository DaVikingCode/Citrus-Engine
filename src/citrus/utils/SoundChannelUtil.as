package citrus.utils 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	public class SoundChannelUtil 
	{
		private static var _soundCheck:Sound;
		private static var soundChannel:SoundChannel;
		
		private static var _silentSound:Sound;
		private static var silentChannel:SoundChannel;
		
		private static var _silentSoundTransform:SoundTransform = new SoundTransform(0, 0);

		public static function hasAvailableChannel():Boolean
		{
			soundChannel = soundCheck.play(0, 0, silentST);
			
			if (soundChannel != null)
			{
				soundChannel.stop();
				soundChannel = null;
				return true;
			}
			else
				return false;
		}
		
		public static function maxAvailableChannels():uint
		{
			var channels:Vector.<SoundChannel> = new Vector.<SoundChannel>();
			var len:uint = 0;
			
			while ((soundChannel = soundCheck.play(0, 0, silentST)) != null)
				channels.push(soundChannel);
				
			len = channels.length;
			
			while ((soundChannel = channels.pop()) != null)
				soundChannel.stop();
				
			channels.length = 0;
			
			return len;
			
		}
		
		public static function get silentST():SoundTransform
		{
			return _silentSoundTransform;
		}
		
		public static function get soundCheck():Sound
		{
			if (!_soundCheck)
				_soundCheck = generateSound();
			return _soundCheck;
		}
		
		public static function get silentSound():Sound
		{
			if (!_silentSound)
				_silentSound = generateSound(2048,0);
			return _silentSound;
		}
		
		public static function playSilentSound():Boolean
		{
			if (silentChannel)
				return false;
			silentChannel = silentSound.play(0, int.MAX_VALUE, silentST);
			if (silentChannel)
			{
				silentChannel.addEventListener(Event.SOUND_COMPLETE, silentComplete);
				return true;
			}
			else
				return false;
		}
		
		public static function stopSilentSound():void
		{
			if (silentChannel)
			{
				silentChannel.stop();
				silentChannel.removeEventListener(Event.SOUND_COMPLETE, silentComplete);
				silentChannel = null;
			}
		}
		
		private static function generateSound(length:int = 1,val:Number = 1.0):Sound
		{
			var sound:Sound = new Sound();
			var soundBA:ByteArray = new ByteArray();
			var i:int = 0;
			for (; i < length; i++)
				soundBA.writeFloat(val);
			soundBA.position = 0;
			sound.loadPCMFromByteArray(soundBA, 1, "float", false, 44100);
			return sound;
		}
		
		private static function silentComplete(e:Event):void
		{
			silentChannel = silentSound.play(0, int.MAX_VALUE, silentST);
		}
		
	}

}