package citrus.datastructures {

	import citrus.core.CitrusObject;
	import citrus.view.ACitrusView;

	import org.osflash.signals.Signal;

	/**
	 * Object pooling is a data structure based on a simple observation : the ‘new’ operator is costly, 
	 * memory allocation necessary for the object creation is a slow process. And Garbage Collection too!
	 * So object pooling idea is really simple :
	 * - create lots of object at the beginning of your level, if there is FPS reduction it shouldn't be a big problem.
	 * - if you need more objects during the game create many of them that can be use later. 
	 * - destroy your object if you don’t need it anymore, but keep a link to it! So it will be reassign!
	 * - destroy all your objects and set them to null at the end of your level (garbage collector will work).
	 */
	public class PoolObject extends DoublyLinkedList {

		protected var _poolType:Class;
		protected var _defaultParams:Object;
		protected var _poolSize:uint = 0;
		protected var _poolGrowthRate:uint = 0;
		protected var _isCitrusObjectPool:Boolean;
		
		/**
		 * dispatches a Signal with a newly created object of type _pooType.
		 */
		public var onCreate:Signal;
		/**
		 * dispatches a Signal with the disposed object of type _pooType.
		 */
		public var onDispose:Signal;
		/**
		 * dispatches a Signal with a recycled object of type _pooType.
		 */
		public var onRecycle:Signal;
		/**
		 * dispatches a Signal with an object of type _pooType before its destruction.
		 */
		public var onDestroy:Signal;

		// Start of the list of free objects
		protected var _freeListHead:DoublyLinkedListNode = null;
		protected var _freeCount:uint = 0;
		
		protected var gc:Vector.<DoublyLinkedListNode>;

		/**
		 * An implementation of an object Pool to limit instantiation for better performances.
		 * Though you pass the Class as a parameter at the pool creation, there's no way for it to send you back your object correctly typed
		 * If you want that, reimplement the Pool class and the DoublyLinkedListNode for each of your pool or port these files to Haxe with Generics !
		 * WARNING : Be sure to design your pooled objects with NO constructor parameters and an 'init' method of some kind that will reinitialized 
		 * all necessary properties each time your objects are 'recycled'.
		 * WARNING : Remember to cast your objects in the correct type before using them each time you get one from a DoublyLinkedListNode.data !!!
		 * 
		 * @param pooledType the Class Object of the type you want to store in this pool
		 * @param defaultParams default params applied to newly created objects (important for physics)
		 * @param poolGrowthRate the number of object to instantiate each time a new one is needed and the free list is empty
		 * @param isCitrusObjectPool a boolean, set it to true if the Pool is composed of Physics/CitrusSprite, set it to false for SpriteArt/StarlingArt
		 */
		public function PoolObject(pooledType:Class,defaultParams:Object, poolGrowthRate:uint, isCitrusObjectPool:Boolean):void {

			super();

			_poolType = pooledType;
			_defaultParams = defaultParams;
			_poolGrowthRate = poolGrowthRate;
			_isCitrusObjectPool = isCitrusObjectPool;
			
			onCreate = new Signal(_poolType);
			onDispose = new Signal(_poolType);
			onRecycle = new Signal(_poolType);
			onDestroy = new Signal(_poolType);
			
			gc = new Vector.<DoublyLinkedListNode>;
			
		}
		
		/**
		 * Call initializePool to create a pool of size _poolSize.
		 * all objects will instantly be created and disposed, ready to be recycled with get().
		 * you have the option of not initializing the pool in which case the first get will return a new object
		 * and will grow the pool size according to the growth rate.
		 */
		public function initializePool(poolSize:uint = 1):void
		{
			_poolSize = poolSize;
			increasePoolSize(_poolSize);
		}

		/**
		 * Create new objects of the _poolType type and dispose them instantly in the free list for future needs.
		 * Called once at the pool creation with _poolSize as a parameter, and once with _poolGrowthRate
		 * each time a new Object is needed and the free list is empty.
		 * 
		 * @param	sizeIncrease the number of objects to instantiate and store in the free list
		 */
		protected function increasePoolSize(sizeIncrease:uint,params:Object = null):void {

			params = mergeParams(params);
			
			for (var i:int = 0; i < sizeIncrease; ++i) {
				var node:DoublyLinkedListNode = new DoublyLinkedListNode();
					
				_create(node, params);
				_dispose(node);

				if (_freeListHead) {
					_freeListHead.prev = node;
					node.next = _freeListHead;
					_freeListHead = node;
				} else {
					_freeListHead = node;
				}
				
				++_freeCount;

			}

		}

		/** Get an object from the free list and returns the node holding it in its data property.
		 * It will be reinitialize inside this function. You may need to cast it.
		 * @param params It calls an <code>initialize</code> method. If the pool <code>_isCitrusObjectPool</code> is true, it calls the CitrusObject <code>initialize</code> method.
		 * @return A node holding the newly 'recycled' object
		 */
		public function get(params:Object = null):DoublyLinkedListNode {
			
			var node:DoublyLinkedListNode;

			// if no object is available in the freelist, make some more !
			if (!_freeListHead) increasePoolSize(_poolGrowthRate,params);

			// get the first free object
			node = _freeListHead;

			// extract it from the free list
			if (node.next) {
				_freeListHead = node.next;
				_freeListHead.prev = null;
				node.next = null;
			} else
				_freeListHead = null;


			// append it to the list of the pool
			if (head != null) {
				tail.next = node;
				node.prev = tail;
				tail = node;
			} else
				head = tail = node;

			++_count;
			--_freeCount;
			
			_recycle(node, params);
			
			return node;
		}
		
		/**
		 * override to create your custom pooled object differently.
		 * @param	node
		 * @param	params
		 */
		protected function _create(node:DoublyLinkedListNode, params:Object = null):void {
			onCreate.dispatch((node.data as _poolType),params);
		}
		
		/**
		 * override to recycle your custom pooled object differently.
		 * @param	node
		 * @param	params
		 */
		protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void {
			onRecycle.dispatch((node.data as _poolType),params)
		}
		
		/**
		 * override to dispose your custom pooled object differently.
		 * @param	node
		 * @param	params
		 */
		protected function _dispose(node:DoublyLinkedListNode):void {	
			onDispose.dispatch((node.data as _poolType));
			(node.data as _poolType).kill = false;
		}
		
		/**
		 * override to destroy your custom pooled object differently.
		 * @param	node
		 * @param	params
		 */
		protected function _destroy(node:DoublyLinkedListNode):void {	
			onDestroy.dispatch((node.data as _poolType));
		}
		
		/**
		 * returns a new params object where newParams adds or overwrites parameters to the default params object defined in the constructor.
		 * @param	newParams
		 * @return Object
		 */
		protected function mergeParams(newParams:Object):Object
		{
			var p:Object = {};
			var k:String;
			
			for (k in _defaultParams)
				p[k] = _defaultParams[k];
			
			for (k in newParams)
				p[k] = newParams[k];
			
			return p;
		}
		
		public function updatePhysics(timeDelta:Number):void {

			var tmpHead:DoublyLinkedListNode = head;

			while (tmpHead != null && (tmpHead.data as _poolType).updateCallEnabled) {
				(tmpHead.data as _poolType).update(timeDelta);
				
				//since updatePhysics is always called, we can dispose objects set to kill here.
				if ("kill" in (tmpHead.data as _poolType) && (tmpHead.data as _poolType).kill)
					gc.push(tmpHead);
				tmpHead = tmpHead.next;
			}
			
			if (gc && gc.length > 0)
			{
				for each(tmpHead in gc)
					disposeFromData(tmpHead.data);
				gc.length = 0;
			}

		}
		
		public function updateArt(stateView:ACitrusView):void {

			var tmpHead:DoublyLinkedListNode = head;

			while (tmpHead != null) {
				(tmpHead.data as _poolType).update(stateView);
				tmpHead = tmpHead.next;
			}

		}
		
		/** Get a node from its data
		 * @param data node's data
		 * @return the node
		 */
		public function getNodeFromData(data:*):DoublyLinkedListNode {

			var tmpHead:DoublyLinkedListNode = head;
			while (tmpHead != null) {	
				if (tmpHead.data == data)	
					return tmpHead;
					
				tmpHead = tmpHead.next;
			}
			
			return null;
		}

		/**
		 * Discard a now useless object to be stored in the free list.
		 * @param node the node holding the object to discard
		 */
		public function disposeNode(node:DoublyLinkedListNode):DoublyLinkedListNode {
			
			// Extract the node from the list
			if (node == head) {
				head = node.next;
				if (head != null) head.prev = null;
			} else {
				node.prev.next = node.next;
			}

			if (node == tail) {
				tail = node.prev;
				if (tail != null) tail.next = null;
			} else {
				node.next.prev = node.prev;
			}

			node.prev = null;

			// Store the discarded object in the free list
			if (_freeListHead) {
				_freeListHead.prev = node;
				node.next = _freeListHead;
				_freeListHead = node;
			} else {
				_freeListHead = node;
				node.next = null;
			}

			--_count;
			++_freeCount;
			
			_dispose(node);
			
			return node;
		}
		
		/**
		 * dispose of data object to the pool.
		 * @param	data
		 */
		public function disposeFromData(data:*):DoublyLinkedListNode
		{
			var n:DoublyLinkedListNode = getNodeFromData(data as _poolType);
			if(n)
				return disposeNode(n);
			else
				return null;
				//throw new Error("This data is already disposed");
		}

		/**
		 * Discard all currently used objects and send them all back to the free list
		 */
		public function disposeAll():void {
			while (head) {
				disposeNode(head);
			}
		}
		
		public function killAll():void
		{
			var node:DoublyLinkedListNode = head;
			while (node) {
				(node.data as CitrusObject).kill = true;
				node = node.next;
			}
		}
		
		/**
		 * loops through all disposed nodes and applies callback (only free objects will be affected)
		 * @param callback gets node.data for argument.
		 */
		public function foreachDisposed(callback:Function):Boolean
		{
			var node:DoublyLinkedListNode = _freeListHead;
			while (node) {
				if (callback(node.data as _poolType))
					return true;
				node = node.next;
			}
			return false;
		}
		
		/**
		 * loops through all recycled nodes and applies callback (only objects currently in use will be affected)
		 * @param callback gets node.data for argument.
		 */
		public function foreachRecycled(callback:Function):Boolean
		{
			var node:DoublyLinkedListNode = head;
			while (node) {
				if (callback(node.data as _poolType))
					return true;
				node = node.next;
			}
			return false;
		}
		
		/**
		 * loops through all nodes and applies callback (both recycled and free objects will be affected)
		 * @param callback gets node.data for argument.
		 */
		public function foreach(callback:Function):Boolean
		{
			var node:DoublyLinkedListNode = head;
			while (node) {
				if (callback(node.data as _poolType))
					return true;
				node = node.next;
			}
			node = _freeListHead;
			while (node) {
				if (callback(node.data as _poolType))
					return true;
				node = node.next;
			}
			return false;
		}
		
		/**
		 * Completely destroy all the content of the pool (the free objects)
		 * and "unlink" from recycled object. (called automatically by the state)
		 */
		public function clear():void {
			
			disposeAll();

			var node:DoublyLinkedListNode;

			while (_freeListHead) {
				node = _freeListHead;
				
				_destroy(node);
				
				node.data = null;
				
				_freeListHead = node.next;
				if (_freeListHead) _freeListHead.prev = null;
				node.next = null;
			}
			
			destroy();

		}
		
		/**
		 * after clearing, just get rid of signals etc...
		 */
		protected function destroy():void
		{
			
			onCreate.removeAll();
			onDestroy.removeAll();
			onDispose.removeAll();
			onRecycle.removeAll();
			
			_defaultParams = null;
			
			_freeListHead = null;
			head = null;
			
			gc.length = 0;
			gc = null;
		}
		
		/**
		 * returns the amount of objects currently in use.
		 */
		override public function get length():uint
		{
			return _count;
		}
		
		/**
		 * returns the amount of objects currently in use.
		 */
		public function get recycledSize():uint
		{
			return _count;
		}
		
		/**
		 * returns the amount of free objects.
		 */
		public function get poolSize():uint
		{
			return _freeCount;
		}
		
		/**
		 * returns the amount of free objects and objects in use.
		 */
		public function get allSize():uint
		{
			return _freeCount + _count;
		}
		
		/**
		 * return true if the Pool is composed of Physics/CitrusSprite, false for SpriteArt/StarlingArt
		 */
		public function get isCitrusObjectPool():Boolean {
			return _isCitrusObjectPool;
		}

	}
}