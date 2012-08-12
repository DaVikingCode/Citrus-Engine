package com.citrusengine.datastructures {
	
	/**
	 * @author Aymeric
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
