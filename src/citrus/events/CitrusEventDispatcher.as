package citrus.events 
{
	import flash.utils.Dictionary;
	import citrus.core.citrus_internal;

	/**
	 * experimental event dispatcher (wip)
	 * TODO: 
	 * - check consistency of bubbling/capturing
	 * - propagation stop ?
	 */
	
	public class CitrusEventDispatcher 
	{
		use namespace citrus_internal;
		
		protected var listeners:Dictionary;
		
		protected var dispatchParent:CitrusEventDispatcher;
		protected var dispatchChildren:Vector.<CitrusEventDispatcher>;
		
		public function CitrusEventDispatcher() 
		{
			listeners = new Dictionary();
		}
		
		citrus_internal function addDispatchChild(child:CitrusEventDispatcher):CitrusEventDispatcher
		{
			if (!dispatchChildren)
				dispatchChildren = new Vector.<CitrusEventDispatcher>();
				
			child.dispatchParent = this;
			dispatchChildren.push(child);
			return child;
		}
		
		citrus_internal function removeDispatchChild(child:CitrusEventDispatcher):void
		{
			var index:int = dispatchChildren.indexOf(child);
			if (index < 0)
				return;
			child.dispatchParent = null;
			dispatchChildren.splice(index, 1);
			
			if (dispatchChildren.length == 0)
				dispatchChildren = null;
		}
		
		citrus_internal function removeDispatchChildren():void
		{
			var child:CitrusEventDispatcher;
			for each(child in dispatchChildren)
				removeDispatchChild(child);
		}
		
		/**
		 * Warning: all references to the listener will be strong and you need to remove them explicitly.
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (type in listeners)
				listeners[type].push({func:listener,useCapture:useCapture});
			else
			{
				listeners[type] = new Vector.<Object>();
				listeners[type].push({func:listener,useCapture:useCapture});
			}
				
		}
		
		public function removeEventListener(type:String, listener:Function):void
		{
			if (type in listeners)
			{
				var index:String;
				var list:Vector.<Object> = listeners[type];
				for (index in list)
					if (list[index].func == listener)
						list.splice(int(index), 1)
			}
		}
		
		public function willTrigger(func:Function):Boolean
		{
			var i:String;
			var list:Vector.<Function>;
			var o:Object;
			for (i in listeners)
			{
				list = listeners[i];
				for each(o in list)
					if (o.func == func)
						return true;
			}
			return false;
		}
		
		public function dispatchEvent(event:CitrusEvent):void
		{
			if (!event._target)
				event._target = this;
				
			event._currentTarget = this;
			
			var phase:int = event._phase;
			var foundTarget:Boolean = false;
			
			if (this == event._target)
				event._phase = CitrusEvent.AT_TARGET;
			
			var o:Object;
			if (event._type in listeners)
			{
				var list:Vector.<Object> = listeners[event.type];
				for each(o in list)
				{
						event._currentListener = o.func;
						
							if (o.func.length == 0)
								o.func.apply();
							else
								o.func.apply(null, [event]);
								
							foundTarget = true;
				}
			}
			
			if (event._phase == CitrusEvent.AT_TARGET && event._bubbles)
				phase = event._phase = CitrusEvent.BUBBLE_PHASE;
				
			if (dispatchChildren && phase == CitrusEvent.CAPTURE_PHASE)
			{
				var child:CitrusEventDispatcher;
				for each(child in dispatchChildren)
				{
					child.dispatchEvent(event);
				}
			}
			
			if (dispatchParent && phase == CitrusEvent.BUBBLE_PHASE)
			{
				dispatchParent.dispatchEvent(event);
			}
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return type in listeners;
		}
		
		/**
		 * remove all listeners of event
		 */
		public function removeListenersOf(type:String):void
		{
			if (type in listeners)
				delete listeners[type];
		}
		
		/**
		 * remove listener from all events
		 */
		public function removeListener(listener:Function):void
		{
			var i:String;
			var j:String;
			var list:Vector.<Object>;
			for (i in listeners)
			{
				list = listeners[i];
				for (j in list)
					if (listener == list[j].func)
						list.splice(int(j), 1);
			}
		}
		
		/**
		 * remove all event listeners (clears lists)
		 */
		public function removeEventListeners():void
		{
			listeners = new Dictionary();
		}
		
	}

}