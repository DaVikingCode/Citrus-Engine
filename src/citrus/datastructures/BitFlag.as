/**
 * A class for using bit flags in an object. <a href="http://divillysausages.com/blog/a_bitflag_class_for_as3">Explanations</a>.
 * @author Damian Connolly - http://divillysausages.com
 */
package citrus.datastructures {

	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class BitFlag {
		/*************************************************************************************************************/

		private static const MAX_INT:int    = 1 << 30; // the max value we can have if using ints
		private static const MAX_UINT:uint  = 1 << 31; // the max value we can have if using uints

		/*************************************************************************************************************/

		private static var m_cache:Dictionary = null; // our cache for flag classes

		/*************************************************************************************************************/

		/**
		 * Destroys the cache for the flag classes
		 */
		public static function destroyCache():void
		{
			// no cache, do nothing
			if ( BitFlag.m_cache == null )
				return;

			// go through and clear all our objects
			for ( var key:* in BitFlag.m_cache )
			{
				BitFlag.m_cache[key] = null;
				delete BitFlag.m_cache[key];
			}

			// kill our dictionary
			BitFlag.m_cache = null;
		}

		/*************************************************************************************************************/

		private var m_flagClass:Class   = null; // the class that we use to verify our flags
		private var m_flags:uint        = 0; // the flags that we have

		/*************************************************************************************************************/

		/**
		 * The class that we use to verify our flags. Setting this will clear any flags that we have
		 */
		public function get flagClass():Class { return this.m_flagClass; }
		public function set flagClass( c:Class ):void
		{
			// clear any flags that we have
			this.m_flags = 0;

			// set our class and read the flags from it
			this.m_flagClass = c;
			if ( this.m_flagClass != null )
				this._setupFlagClass();
		}

		/*************************************************************************************************************/

		/**
		 * Creates the bit flag object
		 * @param flagClass The class that we'll use for our constants if we want to check the flags passed
		 */
		public function BitFlag( flagClass:Class = null )
		{
			this.flagClass = flagClass;
		}

		/**
		 * Destroys the bit flag object and clears it for garbage collection
		 */
		public function destroy():void
		{
			this.flagClass = null;
		}

		/**
		 * Adds a flag to our object
		 * @param flag The flag that we want to add
		 */
		public function addFlag( flag:uint ):void
		{
			// clean our flags if needed
			this.m_flags |= ( this.m_flagClass != null ) ? this._cleanFlags( flag ) : flag;
		}

		/**
		 * Adds a list of flags to our object
		 * @param flags The list of flags that we want to add
		 */
		public function addFlags( ... flags ):void
		{
			// Add all the flags (clean if needed)
			var len:int = flags.length;
			for ( var i:int = 0; i < len; i++ )
				this.m_flags |= ( this.m_flagClass != null ) ? this._cleanFlags( flags[i] ) : flags[i];
		}

		/**
		 * Removes a flag from our object
		 * @param flag The flag that we want to remove
		 */
		public function removeFlag( flag:uint ):void
		{
			// clean our flags if needed
			this.m_flags &= ( this.m_flagClass != null ) ? ~this._cleanFlags( flag ) : ~flag;
		}

		/**
		 * Removes a list of flags from our object
		 * @param The list of flags that we want to remove
		 */
		public function removeFlags( ... flags ):void
		{
			// remove all the flags (clean if needed)
			var len:int = flags.length;
			for ( var i:int = 0; i < len; i++ )
				this.m_flags &= ( this.m_flagClass != null ) ? ~this._cleanFlags( flags[i] ) : ~flags[i];
		}
		
		/**
		 * Simple utility to remove all flags at once.
		 */
		public function removeAllFlags():void
		{
			this.m_flags = 0;
		}
		
		/**
		 * removes all previous flags and sets new flag/flags
		 * @param	flag a flag or a list of flags (piped).
		 */
		public function setFlags( flag:uint ):void
		{
			// clean the flags if needed
			this.m_flags = ( this.m_flagClass != null ) ? this._cleanFlags( flag ) : flag;
		}

		/**
		 * Toggles a specific flag. If the current flag is false, this will set
		 * it to true and vice versa
		 * @param flag The flag that we want to toggle
		 */
		public function toggleFlag( flag:uint ):void
		{
			// clean the flags if needed
			this.m_flags ^= ( this.m_flagClass != null ) ? this._cleanFlags( flag ) : flag;
		}

		/**
		 * Toggles a list of flags on our object. If a flag is currently false, this
		 * will set it to true and vice versa
		 * @param flags The list of flags that we want to toggle
		 */
		public function toggleFlags( ... flags ):void
		{
			// toggle all the flags (clean if needed)
			var len:int = flags.length;
			for ( var i:int = 0; i < len; i++ )
				this.m_flags ^= ( this.m_flagClass != null ) ? this._cleanFlags( flags[i] ) : flags[i];
		}

		/**
		 * Checks if we have a specific flag set for this class. If the flag passed in is multiple
		 * flags (i.e. Flag1 | Flag2 | Flag3), then this will return true only if we have all the flags
		 * @param flag The flag that we want to check
		 * @return True if we have the flag, false otherwise
		 */
		public function hasFlag( flag:uint ):Boolean
		{
			// check if we have the flag (clean if needed)
			flag = ( this.m_flagClass != null ) ? this._cleanFlags( flag ) : flag;
			return ( this.m_flags & flag ) == flag;
		}

		/**
		 * Checks if we have all the flags provided set
		 * @param flags The list of flags that we want to check
		 * @return True if all the flags are set, false otherwise
		 */
		public function hasFlags( ... flags ):Boolean
		{
			// concat up our flag to check
			var allFlags:int    = 0;
			var len:int         = flags.length;
			for ( var i:int = 0; i < len; i++ )
				allFlags |= flags[i];

			// clean the flags if needed
			if ( this.m_flagClass != null )
				allFlags = this._cleanFlags( allFlags );

			// now check if all of the flags are set
			return ( this.m_flags & allFlags ) == allFlags; // match all
		}

		/**
		 * Checks if we have a specific flag set for this class (or flags can be piped)
		 * @param flag The flag that we want to check
		 * @return True if we have any of the flag, false otherwise
		 */
		public function hasAnyFlag( flag:uint ):Boolean
		{
			// check if we have the flag (clean if needed)
			flag = ( this.m_flagClass != null ) ? this._cleanFlags( flag ) : flag;
			return ( this.m_flags & flag ) != 0;
		}

		/**
		 * Checks if we have any of the flags provided set
		 * @param flags The list of flags that we want to check
		 * @return True if any the flags are set, false otherwise
		 */
		public function hasAnyFlags( ... flags ):Boolean
		{
			// concat up our flag to check
			var allFlags:int    = 0;
			var len:int         = flags.length;
			for ( var i:int = 0; i < len; i++ )
				allFlags |= flags[i];

			// clean the flags if needed
			if ( this.m_flagClass != null )
				allFlags = this._cleanFlags( allFlags );

			// check if we have any of the flags
			return ( this.m_flags & allFlags ) != 0;
		}

		/**
		 * Returns a String representation of the object
		 */
		public function toString():String
		{
			return "[BitFlag flags:" + this.m_flags.toString( 2 ) + "]";
		}

		/*************************************************************************************************************/

			// cleans any flags passed in to make sure they come from our class
		private function _cleanFlags( flags:uint ):uint
		{
			// if we don't have a class, we're not verifying, so ignore
			if ( this.m_flagClass == null )
				return flags;

			// if we don't have our vector for some reason do nothing
			if ( BitFlag.m_cache == null || !( this.m_flagClass in BitFlag.m_cache ) )
				return flags;

			// get our vector
			var v:Vector.<uint> = BitFlag.m_cache[this.m_flagClass];

			// clean the flags
			var len:int         = v.length;
			var retFlags:uint   = 0;
			for ( var i:int = 0; i < len; i++ )
			{
				// if a flag in our class exists in this flag, remove it
				if ( ( flags & v[i] ) != 0 )
				{
					retFlags    |= v[i];
					flags       &= ~v[i];
				}
			}

			// if we have something left over, then there was a problem
			if ( flags != 0 )
				trace( "3:[BitFlag] While cleaning the flags, we found an unknown flag (" + flags + ") that doesn't exist in our flag class (" + this.m_flagClass + ")" );

			// return the cleaned flags
			return retFlags;
		}

		// takes a class and extracts all the flags from it so we can check any flags we get
		private function _setupFlagClass():void
		{
			// make sure we have a class
			if ( this.m_flagClass == null )
				return;

			// if we already have it in our cache, ignore
			if ( BitFlag.m_cache != null && ( this.m_flagClass in BitFlag.m_cache ) )
				return;

			// it's not there, describe the class
			var x:XML = describeType( this.m_flagClass );

			// get all the constants and take out any int and uints
			for each ( var cx:XML in x.constant )
			{
				// only take ints and uints
				var type:String = cx.@type;
				if ( type != "uint" && type != "int" )
				{
					trace( "0:[BitFlag] Ignoring '" + cx.@name + "' from class " + this.m_flagClass + " as it's not an int or an uint" );
					continue;
				}

				// if it's an int, make sure it's good
				if ( type == "int" )
				{
					var intFlag:int = this.m_flagClass[cx.@name];
					if ( intFlag < 0 || intFlag > BitFlag.MAX_INT ) // less than 0, or we've done something like (1<<31)
					{
						trace( "0:[BitFlag] Ignoring const '" + cx.@name + "' from class " + this.m_flagClass + " as out of range. The max possible flag for an int is (1 << 30)" );
						continue;
					}
				}

				// get our uint (convert ints)
				var flag:uint = this.m_flagClass[cx.@name];

				// make sure only one bit is set (i.e. it's a flag and not a number)
				// this check only works on numbers less than (1 << 30), so do a check for MAX_UINT
				if ( flag != ( flag & -flag ) && flag != BitFlag.MAX_UINT )
				{
					trace( "0:[BitFlag] Ignoring const '" + cx.@name + "' from class " + this.m_flagClass + " as it's not a flag" );
					continue;
				}

				// create our dictionary if needed
				if ( BitFlag.m_cache == null )
					BitFlag.m_cache = new Dictionary;

				// create our vector for this class if needed
				if ( !( this.m_flagClass in BitFlag.m_cache ) )
					BitFlag.m_cache[this.m_flagClass] = new Vector.<uint>;

				// add our const
				BitFlag.m_cache[this.m_flagClass].push( flag );
			}

			// dispose of the xml immediately
			System.disposeXML( x );
		}


	}
}
