package com.citrusengine.datastructures {

	import com.citrusengine.view.CitrusView;

	/**
	 * @author Aymeric based on the works of Alkemi (Mickael Mouillé & Alain Puget) <a href="http://www.alkemi-games.com/pages/tutorials/">Alkemi Games</a>. 
	 */
	public class PoolObject extends DoublyLinkedList {

		protected var _poolType:Class;
		protected var _poolSize:uint = 0;
		protected var _poolGrowthRate:uint = 0;
		protected var _physicsPool:Boolean;

		// Start of the list of free objects
		protected var _freeListHead:DoublyLinkedListNode = null;

		/**
		 * An implementation of an object Pool to limit instantiation for better performances.
		 * Though you pass the Class as a parameter at the pool creation, there's no way for it to send you back your object correctly typed
		 * If you want that, reimplement the Pool class and the DoublyLinkedListNode for each of your pool or port these files to Haxe with Generics !
		 * WARNING : Be sure to design your pooled objects with NO constructor parameters and an 'init' method of some kind that will reinitialized 
		 * all necessary properties each time your objects are 'recycled'.
		 * WARNING : Remember to cast your objects in the correct type before using them each time you get on from a DoublyLinkedListNode.data !!!
		 * 
		 * @param $pooledType the Class Object of the type you want to store in this pool
		 * @param $poolSize the initial size of your pool. Ideally you should never have to use more than this number.
		 * @param $poolGrowthRate the number of object to instantiate each time a new one is needed and the free list is empty
		 */
		public function PoolObject(pooledType:Class, poolSize:uint, poolGrowthRate:uint, physicsPool:Boolean):void {

			super();

			_poolType = pooledType;
			_poolSize = poolSize;
			_poolGrowthRate = poolGrowthRate;
			_physicsPool = physicsPool;

			increasePoolSize(_poolSize);
		}

		/**
		 * Create new objects of the _poolType type and store them in the free list for future needs.
		 * Called once at the pool creation with _poolSize as a parameter, and once with _poolGrowthRate
		 * each time a new Object is needed and the free list is empty.
		 * 
		 * @param	$sizeIncrease the number of objects to instantiate and store in the free list
		 */
		protected function increasePoolSize(sizeIncrease:uint):void {

			for (var i:int = 0; i < sizeIncrease; ++i) {
				var node:DoublyLinkedListNode = new DoublyLinkedListNode();
				
				if (_physicsPool)
					node.data = new _poolType("aPoolObject", {type:"poolObject"});
				else
					node.data = new _poolType();
				

				if (_freeListHead) {
					_freeListHead.prev = node;
					node.next = _freeListHead;
					_freeListHead = node;
				} else {
					_freeListHead = node;
				}

			}

		}

		/** Get an object from the free list and returns the node holding it in its data property
		 * Don't forget to cast and reinitialize it !!!
		 * @return a node holding the newly 'recycled' object
		 */
		public function create(params:Object):DoublyLinkedListNode {
			
			var node:DoublyLinkedListNode;

			// if no object is available in the freelist, make some more !
			if (!_freeListHead) increasePoolSize(_poolGrowthRate);

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

			(node.data as _poolType).initialize(params);

			++_count;
			
			return node;
		}
		
		public function updatePhysics(timeDelta:Number):void {

			var tmpHead:DoublyLinkedListNode = head;

			while (tmpHead != null) {
				(tmpHead.data as _poolType).update(timeDelta);
				tmpHead = tmpHead.next;
			}

		}
		
		public function updateArt(stateView:CitrusView):void {

			var tmpHead:DoublyLinkedListNode = head;

			while (tmpHead != null) {
				(tmpHead.data as _poolType).update(stateView);
				tmpHead = tmpHead.next;
			}

		}
		
		/** Get a node from its data, working with MouseEvent...
		 * @param node's data
		 * @return the node
		 */
		public function getNodeFromData(data:*):DoublyLinkedListNode {

			var tmpHead:DoublyLinkedListNode = head;

			while (tmpHead != null) {
				
				if (tmpHead.data == data) {
					
					return tmpHead;
				}
				
				tmpHead = tmpHead.next;
			}
			
			return null;
		}

		/**
		 * Discard a now useless object to be stored in the free list.
		 * @param	$node the node holding the object to discard
		 */
		public function disposeNode(node:DoublyLinkedListNode):DoublyLinkedListNode {
			
			(node.data as _poolType).destroy();
			
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
			
			return node;
		}

		/**
		 * Discard all currently used objects and send them all back to the free list
		 */
		public function disposeAll():void {
			while (head) {
				disposeNode(head);
			}
		}

		/**
		 * Completely destroy all the content of the pool
		 */
		public function clear():void {
			disposeAll();

			var node:DoublyLinkedListNode;

			while (_freeListHead) {
				node = _freeListHead;
				node.data = null;
				_freeListHead = node.next;
				if (_freeListHead) _freeListHead.prev = null;
				node.next = null;
			}

		}

	}
}