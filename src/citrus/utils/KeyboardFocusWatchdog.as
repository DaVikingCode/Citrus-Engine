package citrus.utils {
	import flash.display.*;
	import flash.events.*;

/**
 * credits to henke37 
 */
	public class KeyboardFocusWatchdog {
		private var active : Boolean;
		private var stage : Stage;
		private var trapee : InteractiveObject;

		public function KeyboardFocusWatchdog(stage : Stage) {
			this.stage = stage;
			activate();
		}

		public function activate() : void {
			if (active) return;

			stage.addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			stage.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			trapee = stage.focus;

			registerTrap();

			active = true;
		}

		public function deactivate() : void {
			if (!active) return;

			deregisterTrap();
			stage.removeEventListener(FocusEvent.FOCUS_IN, focusIn);
			stage.removeEventListener(FocusEvent.FOCUS_OUT, focusOut);
			trapee = null;

			active = false;
		}

		private function focusIn(e : FocusEvent) : void {
			trapee = InteractiveObject(e.target);
			registerTrap();
		}

		private function focusOut(e : FocusEvent) : void {
			deregisterTrap();
			trapee = null;
		}

		private function deregisterTrap() : void {
			if (!trapee) return;
			trapee.removeEventListener(Event.REMOVED_FROM_STAGE, removed);
		}

		private function registerTrap() : void {
			if (!trapee) return;
			trapee.addEventListener(Event.REMOVED_FROM_STAGE, removed);
		}

		private function removed(e : Event) : void {
			//trace("Focused object leaving the display tree, reclaiming focus.");
			stage.focus = stage;
		}
	}
}