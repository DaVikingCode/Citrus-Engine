package ash.core
{
	/**
	 * The interface for classes that are used to manage NodeLists (set as the familyClass property 
	 * in the Engine object). Most developers don't need to use this since the default implementation
	 * is used by default and suits most needs.
	 */
	public interface IFamily
	{
		/**
		 * Returns the NodeList managed by this class. This should be a reference that remains valid always
		 * since it is retained and reused by Systems that use the list. i.e. never recreate the list,
		 * always modify it in place.
		 */
		function get nodeList() : NodeList;
		/**
		 * An entity has been added to the engine. It may already have components so test the entity
		 * for inclusion in this family's NodeList.
		 */
		function newEntity( entity : Entity ) : void;
		/**
		 * An entity has been removed from the engine. If it's in this family's NodeList it should be removed.
		 */
		function removeEntity( entity : Entity ) : void;
		/**
		 * A component has been added to an entity. Test whether the entity's inclusion in this family's
		 * NodeList should be modified.
		 */
		function componentAddedToEntity( entity : Entity, componentClass : Class ) : void;
		/**
		 * A component has been removed from an entity. Test whether the entity's inclusion in this family's
		 * NodeList should be modified.
		 */
		function componentRemovedFromEntity( entity : Entity, componentClass : Class ) : void;
		/**
		 * The family is about to be discarded. Clean up all properties as necessary. Usually, you will
		 * want to empty the NodeList at this time.
		 */
		function cleanUp() : void;
	}
}
