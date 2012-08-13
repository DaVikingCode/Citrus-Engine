package com.citrusengine.datastructures {
	
	/**
	 * Each node is composed of a data and references (in other words, links) to the next and previous node in the sequence.
	 * This structure allows for efficient insertion or removal of elements from any position in the sequence.
	 */
	public class DoublyLinkedListNode {
		
		public var data:*;
		public var next:DoublyLinkedListNode;
		public var prev:DoublyLinkedListNode;
		
		/**
		 * A simple data node used for DoubleLinkedList and Pool
		 * @param obj untyped data stored in the node
		 */
		public function DoublyLinkedListNode(obj:* = null) {
			
			next = prev = null;
			data = obj;
		}
	}
}
