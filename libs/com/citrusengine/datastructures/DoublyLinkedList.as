package com.citrusengine.datastructures {

	/**
	 * @author Aymeric
	 */
	public class DoublyLinkedList {

		public var head:DoublyLinkedListNode;
		public var tail:DoublyLinkedListNode;

		protected var _count:uint;

		public function DoublyLinkedList() {

			head = tail = null;
			_count = 0;
		}

		/**
		 * Append an object to the list.
		 * @param data an object of any type added at the end of the list.
		 * @return returns the tail.
		 */
		public function append(data:*):DoublyLinkedListNode {

			var node:DoublyLinkedListNode = new DoublyLinkedListNode(data);

			if (tail != null) {

				tail.next = node;
				node.prev = tail;
				tail = node;

			} else {
				head = tail = node;
			}

			++_count;

			return tail;
		}

		/**
		 * Append a node to the list.
		 * @param node a DoublyLinkedListNode object of any type added at the end of the list.
		 * @return returns the doublyLinkedList.
		 */
		public function appendNode(node:DoublyLinkedListNode):DoublyLinkedList {

			if (head != null) {

				tail.next = node;
				node.prev = tail;
				tail = node;

			} else {
				head = tail = node;
			}


			++_count;

			return this;
		}

		/**
		 * Prepend an object to the list.
		 * @param data an object of any type added at the beginning of the list.
		 * @return returns the head.
		 */
		public function prepend(data:*):DoublyLinkedListNode {

			var node:DoublyLinkedListNode = new DoublyLinkedListNode(data);

			if (head != null) {

				head.prev = node;
				node.next = head;
				head = node;

			} else {
				head = tail = node;
			}

			++_count;

			return head;
		}

		/**
		 * Prepend a node to the list.
		 * @param data an object of any type added at the beginning of the list.
		 * @return returns the doublyLinkedList.
		 */
		public function prependNode(node:DoublyLinkedListNode):DoublyLinkedList {

			if (head != null) {

				head.prev = node;
				node.next = head;
				head = node;

			} else {
				head = tail = node;
			}

			++_count;

			return this;
		}

		/**
		 * Remove a node from the list and return its data.
		 * @param node the node to remove from the list.
		 * @return returns the removed node data.
		 */

		public function removeNode(node:DoublyLinkedListNode):* {

			var data:* = node.data;

			if (node == head) {

				removeHead();

			} else {
				node.prev.next = node.next;
			}

			if (node == tail) {

				removeTail();

			} else {
				node.next.prev = node.prev;
			}

			--_count;

			return data;

		}

		public function removeHead():* {

			var node:DoublyLinkedListNode = head;

			if (head != null) {

				var data:* = node.data;

				head = head.next;

				if (head != null) {
					head.prev = null ;
				}

				--_count;

				return data;
			}
		}

		public function removeTail():* {

			var node:DoublyLinkedListNode = tail;

			if (tail != null) {

				var data:* = node.data;

				tail = tail.prev;

				if (tail != null) {
					tail.next = null;
				}

				--_count;

				return data;
			}
		}

		/**
		 * Get the lengh of the list.
		 * @return the list length.
		 */
		public function get length():uint {
			return _count;
		}

		public function content():String {

			var tmpHead:DoublyLinkedListNode = head;
			var text:String = '';

			while (tmpHead != null) {
				text += String(tmpHead.data) + " ";
				tmpHead = tmpHead.next;
			}

			return text;
		}
	}
}
