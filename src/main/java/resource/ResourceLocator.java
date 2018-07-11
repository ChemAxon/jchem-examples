package resource;

import java.net.URL;

/**
 * Helper class to load resources placed in the package directory of this class.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class ResourceLocator {

    private static final String DEFAULT_INPUT_FILE = "nci1000.smiles";

    /**
     * Gets the path of the given resource.
     * 
     * @param resourceFileName the name of the requested resource file (more precisely, a file
     *            path that is relative to the package directory of this class).
     * @return the full path of the requested resource file
     * @throws IllegalArgumentException if the resource is not found
     */
    public static String getPath(String resourceFileName) throws IllegalArgumentException {
        URL resource = ResourceLocator.class.getResource(resourceFileName);
        if (resource == null) {
            throw new IllegalArgumentException("Resource not found: " + resourceFileName);
        }
        return resource.getPath();
    }

    /**
     * Gets the path of the default molecule input file (nci1000.smiles).
     * 
     * @return the full path of the default input file
     */
    public static String getDefaultInputPath() {
        return getPath(DEFAULT_INPUT_FILE);
    }

}
