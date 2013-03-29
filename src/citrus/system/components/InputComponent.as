package citrus.system.components {

	import citrus.system.Component;

	/**
	 * An input component, it will inform if the key is down, just pressed or just released.
	 */
	public class InputComponent extends Component {
		
		public var rightKeyIsDown:Boolean = false;
		public var leftKeyIsDown:Boolean = false;
		public var downKeyIsDown:Boolean = false;
		public var spaceKeyIsDown:Boolean = false;
		public var spaceKeyJustPressed:Boolean = false;

		public function InputComponent(name:String, params:Object = null) {
			super(name, params);
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			rightKeyIsDown = _ce.input.isDoing("right");
			leftKeyIsDown = _ce.input.isDoing("left");
			downKeyIsDown = _ce.input.isDoing("duck");
			spaceKeyIsDown = _ce.input.isDoing("jump");
			spaceKeyJustPressed = _ce.input.justDid("jump");
		}
	}
}
