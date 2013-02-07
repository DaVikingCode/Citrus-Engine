/**
 * User: Makai Media Inc.
 * Date: 12/5/12
 * Time: 1:16 PM
 */
package citrus.utils.inventory.core {

	public interface iGameObject {
		function init():GameObject;
		function changeState(state:*):void;
	}
}
