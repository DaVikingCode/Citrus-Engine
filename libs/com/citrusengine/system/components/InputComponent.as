package com.citrusengine.system.components {

	import com.citrusengine.system.Component;

	import flash.ui.Keyboard;

	/**
	 * @author Aymeric
	 */
	public class InputComponent extends Component {
		
		public var rightKeyIsDown:Boolean = false;
		public var leftKeyIsDown:Boolean = false;
		public var spaceKeyIsDown:Boolean = false;
		public var spaceKeyJustPressed:Boolean = false;

		public function InputComponent(name:String, params:Object = null) {
			super(name, params);
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			rightKeyIsDown = _ce.input.isDown(Keyboard.RIGHT);
			leftKeyIsDown = _ce.input.isDown(Keyboard.LEFT);
			spaceKeyIsDown = _ce.input.isDown(Keyboard.SPACE);
			spaceKeyJustPressed = _ce.input.justPressed(Keyboard.SPACE);
		}
	}
}
