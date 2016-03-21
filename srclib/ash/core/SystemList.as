package ash.core
{
	/**
	 * Used internally, this is an ordered list of Systems for use by the engine update loop.
	 */
	internal class SystemList
	{
		internal var head : System;
		internal var tail : System;
		
		internal function add( system : System ) : void
		{
			if( ! head )
			{
				head = tail = system;
				system.next = system.previous = null;
			}
			else
			{
				for( var node : System = tail; node; node = node.previous )
				{
					if( node.priority <= system.priority )
					{
						break;
					}
				}
				if( node == tail )
				{
					tail.next = system;
					system.previous = tail;
					system.next = null;
					tail = system;
				}
				else if( !node )
				{
					system.next = head;
					system.previous = null;
					head.previous = system;
					head = system;
				}
				else
				{
					system.next = node.next;
					system.previous = node;
					node.next.previous = system;
					node.next = system;
				}
			}
		}
		
		internal function remove( system : System ) : void
		{
			if ( head == system)
			{
				head = head.next;
			}
			if ( tail == system)
			{
				tail = tail.previous;
			}
			
			if (system.previous)
			{
				system.previous.next = system.next;
			}
			
			if (system.next)
			{
				system.next.previous = system.previous;
			}
			// N.B. Don't set system.next and system.previous to null because that will break the list iteration if node is the current node in the iteration.
		}
		
		internal function removeAll() : void
		{
			while( head )
			{
				var system : System = head;
				head = head.next;
				system.previous = null;
				system.next = null;
			}
			tail = null;
		}
		
		internal function get( type : Class ) : System
		{
			for( var system : System = head; system; system = system.next )
			{
				if ( system is type )
				{
					return system;
				}
			}
			return null;
		}
	}
}
