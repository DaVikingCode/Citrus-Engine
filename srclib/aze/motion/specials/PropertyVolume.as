package aze.motion.specials 
{
	import aze.motion.EazeTween;
	import aze.motion.specials.EazeSpecial;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	/**
	 * Volume tweening as a special property
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyVolume extends EazeSpecial
	{
		static public function register():void
		{
			EazeTween.specialProperties.volume = PropertyVolume;
		}
		
		private var start:Number;
		private var delta:Number;
		private var vvalue:Number;
		private var targetVolume:Boolean;
		
		public function PropertyVolume(target:Object, property:*, value:*, next:EazeSpecial)
		{
			super(target, property, value, next);
			vvalue = value;
		}
		
		override public function init(reverse:Boolean):void 
		{
			targetVolume = ("soundTransform" in target);// && (target.soundTransform != null);
			var st:SoundTransform = targetVolume ? target.soundTransform : SoundMixer.soundTransform;
			
			var end:Number;
			if (reverse) { start = vvalue; end = st.volume; }
			else { end = vvalue; start = st.volume; }
			
			delta = end - start;
		}
		
		override public function update(ke:Number, isComplete:Boolean):void 
		{
			var st:SoundTransform = targetVolume ? target.soundTransform : SoundMixer.soundTransform;
			
			st.volume = start + delta * ke;
			
			if (targetVolume) target.soundTransform = st;
			else SoundMixer.soundTransform = st;
		}
	}

}