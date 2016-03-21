package ash.fsm
{
import ash.core.System;

/**
 * This System provider returns results of a method call. The method
 * is passed to the provider at initialisation.
 */
public class DynamicSystemProvider implements ISystemProvider
{
    private var method:Function;
    private var systemPriority:int = 0;


    /**
     * Constructor
     *
     * @param method The method that returns the System instance;
     */
    public function DynamicSystemProvider( method:Function )
    {
        this.method = method;
    }

    /**
     * Used to request a component from this provider
     *
     * @return The instance of the System
     */
    public function getSystem():System
    {
        return method();
    }

    /**
     * Used to compare this provider with others. Any provider that returns the same component
     * instance will be regarded as equivalent.
     *
     * @return The method used to call the System instances
     */
    public function get identifier():*
    {
        return method;
    }

    /**
     * The priority at which the System should be added to the Engine
     */
    public function get priority():int
    {
        return systemPriority;
    }

    public function set priority( value:int ):void
    {
        systemPriority = value;
    }
}
}
