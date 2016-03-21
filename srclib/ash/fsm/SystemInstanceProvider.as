package ash.fsm
{
import ash.core.System;

/**
 * This System provider always returns the same instance of the component. The system
 * is passed to the provider at initialisation.
 */
public class SystemInstanceProvider implements ISystemProvider
{
    private var instance:System;
    private var systemPriority:int = 0;

    /**
     * Constructor
     *
     * @param instance The instance to return whenever a System is requested.
     */
    public function SystemInstanceProvider( instance:System )
    {
        this.instance = instance;
    }

    /**
     * Used to request a component from this provider
     *
     * @return The instance of the System
     */
    public function getSystem():System
    {
        return instance;
    }

    /**
     * Used to compare this provider with others. Any provider that returns the same component
     * instance will be regarded as equivalent.
     *
     * @return The instance
     */
    public function get identifier():*
    {
        return instance;
    }

    /**
     * The priority at which the System should be added to the Engine
     */
    public function get priority():int
    {
        return systemPriority;
    }

    /**
     * @private
     */
    public function set priority( value:int ):void
    {
        systemPriority = value;
    }

}
}
