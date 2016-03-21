package ash.core
{
	/**
	 * The base class for a system.
	 * 
	 * <p>A system is part of the core functionality of the game. After a system is added to the engine, its
	 * update method will be called on every frame of the engine. When the system is removed from the engine, 
	 * the update method is no longer called.</p>
	 * 
	 * <p>The aggregate of all systems in the engine is the functionality of the game, with the update
	 * methods of those systems collectively constituting the engine update loop. Systems generally operate on
	 * node lists - collections of nodes. Each node contains the components from an entity in the engine
	 * that match the node.</p>
	 */
	public class System
	{
		/**
		 * Used internally to manage the list of systems within the engine. The previous system in the list.
		 */
		internal var previous : System;
		/**
		 * Used internally to manage the list of systems within the engine. The next system in the list.
		 */
		internal var next : System;
		/**
		 * Used internally to hold the priority of this system within the system list. This is 
		 * used to order the systems so they are updated in the correct order.
		 */
		internal var priority : int = 0;
		
		/**
		 * Called just after the system is added to the engine, before any calls to the update method.
		 * Override this method to add your own functionality.
		 * 
		 * @param engine The engine the system was added to.
		 */
		public function addToEngine( engine : Engine ) : void
		{
			
		}
		
		/**
		 * Called just after the system is removed from the engine, after all calls to the update method.
		 * Override this method to add your own functionality.
		 * 
		 * @param engine The engine the system was removed from.
		 */
		public function removeFromEngine( engine : Engine ) : void
		{
			
		}
		
		/**
		 * After the system is added to the engine, this method is called every frame until the system
		 * is removed from the engine. Override this method to add your own functionality.
		 * 
		 * <p>If you need to perform an action outside of the update loop (e.g. you need to change the
		 * systems in the engine and you don't want to do it while they're updating) add a listener to
		 * the engine's updateComplete signal to be notified when the update loop completes.</p>
		 * 
		 * @param time The duration, in seconds, of the frame.
		 */
		public function update( time : Number ) : void
		{
			
		}
	}
}
