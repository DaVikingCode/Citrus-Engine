/**
 * User: Makai Media Inc.
 * Date: 12/5/12
 * Time: 1:16 PM
 */
package citrus.ui.inventory.core {

	public interface IGameObject {
		function init():GameObject;
		function changeState(state:*):void;
	}
}
