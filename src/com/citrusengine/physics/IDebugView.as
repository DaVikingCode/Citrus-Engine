package com.citrusengine.physics {
	
	/**
	 * Interface for all the debug views
	 */
	public interface IDebugView {
		
		/**
		 * update the debug view
		 */
		function update():void
		
		/**
		 * change the debug mode when available, e.g. show only joints, or raycasts...
		 */
		function debugMode(mode:uint):void
	}
}
