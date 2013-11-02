package citrus.events 
{
	import flash.utils.Dictionary;

	/**
	 * experimental event dispatcher (wip)
	 * TODO: 
	 * - check consistency of bubbling/capturing
	 * - propagation stop ?
	 */
	
	public class CitrusEventDispatcher 
	{
		protected var listeners:Dictionary;
		
		protected var dispatchParent:CitrusEventDispatcher;
		protected var dispatchChildren:Vector.<CitrusEventDispatcher>;
		
		public function CitrusEventDispatcher() 
		{
			listeners = new Dictionary();
		}
		
		public function addDispatchChild(child:CitrusEventDispatcher):CitrusEventDispatcher
		{
			if (!dispatchChildren)
				dispatchChildren = new Vector.<CitrusEventDispatcher>();
				
			child.dispatchParent = this;
			dispatchChildren.push(child);
			return child;
		}
		
		public function removeDispatchChild(child:CitrusEventDispatcher):void
		{
			var index:int = dispatchChildren.indexOf(child);
			if (index < 0)
				return;
			child.dispatchParent = null;
			dispatchChildren.splice(index, 1);
			
			if (dispatchChildren.length == 0)
				dispatchChildren = null;
		}
		
		public function addEventListener(type:String, listener:Function):void
		{
			if (type in listeners)
				listeners[type].push(listener);
			else
			{
				listeners[type] = new Vector.<Function>();
				listeners[type].push(listener);
			}
				
		}
		
		public function removeEventListener(type:String, listener:Function):void
		{
			if (type in listeners)
			{
				var index:String;
				var list:Vector.<Function> = listeners[type];
				for (index in list)
					if (list[index] == listener)
						list.splice(int(index), 1)
			}
		}
		
		public function willTrigger(func:Function):Boolean
		{
			var i:String;
			var list:Vector.<Function>;
			var f:Function;
			for (i in listeners)
			{
				list = listeners[i];
				for each(f in list)
					if (func == f)
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
			
			var f:Function;
			if (event._type in listeners)
			{
				var list:Vector.<Function> = listeners[event.type];
				for each(f in list)
				{
						event._currentListener = f;
						
						event._phase = CitrusEvent.AT_TARGET;
						
						if (phase != CitrusEvent.CAPTURE_PHASE && event._useCapture)
							continue;
						
						if (f.length == 0)
							f.apply();
						else
							f.apply(null, [event]);
							
						foundTarget = true;
						event._phase = phase;
				}
			}
				
			if (foundTarget && event._bubbles)
			{
				event._phase = CitrusEvent.BUBBLE_PHASE;
			}
				
			if (dispatchChildren && event._phase == CitrusEvent.CAPTURE_PHASE)
			{
				var child:CitrusEventDispatcher;
				for each(child in dispatchChildren)
				{
					child.dispatchEvent(event);
				}
			}
			
			if (dispatchParent && event._phase == CitrusEvent.BUBBLE_PHASE)
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
			var list:Vector.<Function>;
			for (i in listeners)
			{
				list = listeners[i];
				for (j in list)
					if (listener == list[j])
						list.splice(int(j), 1);
			}
		}
		
		/**
		 * remove all event listeners (clears lists)
		 */
		public function removeAllEventListeners():void
		{
			listeners = new Dictionary();
		}
		
	}

}