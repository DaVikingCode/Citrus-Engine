package com.citrusengine.objects.platformer.awayphysics {

	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	
	/**
	 * Used in the Away3DArt class to make a correct art rotation on a platformer object
	 */
	public interface IPlatformer {
		
		/**
		 * The character. 
		 */	
		function get character():AWPKinematicCharacterController;
		
		/**
		 * The ghostobject. 
		 */
		function get ghostObject():AWPGhostObject;
	}
}
