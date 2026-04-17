/*  Copyright 2018 ChemAxon Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package util;

import chemaxon.formats.MolExporter;
import chemaxon.search.hitdisplay.HitDisplayOptions;
import chemaxon.struc.Molecule;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;
import java.lang.reflect.Method;

/**
 * Various utility functions used in the example codes for displaying molecules.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DisplayUtil {

    private static final int DEFAULT_FRAME_SIZE = 300;

    private DisplayUtil() throws IllegalAccessException {
        throw new IllegalAccessException("Utility class cannot be instantiated");
    }

    /**
     * Returns the SMILES representation of the given molecule.
     *
     * @param molecule input molecule
     * @return SMILES representation
     * @throws IllegalArgumentException if SMILES export failed
     */
    public static String toSmiles(final Molecule molecule) {
        try {
            return MolExporter.exportToFormat(molecule, "smiles");
        } catch (final IOException e) {
            throw new IllegalArgumentException("SMILES export error", e);
        }
    }

    /**
     * Shows the given molecule on the screen in a JFrame window.
     *
     * @param mol molecule to show
     * @param pos position number of the JFrame window on the screen
     */
    public static void showMolecule(final Molecule mol, final int pos, final String title) {
        showMolecule(mol, pos, DEFAULT_FRAME_SIZE, title);
    }

    /**
     * Shows the molecule on the screen in a JFrame window of the given size.
     *
     * @param mol  molecule to show
     * @param pos  position number of the JFrame window on the screen
     * @param size size of the JFrame window
     */
    public static void showMolecule(final Molecule mol, final int pos, final int size, final String title) {

        final ResultView resultView = new ResultView();
        resultView.setM(0, mol);

        // Display the result in a JFrame window
        final JFrame frame = new JFrame();
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        frame.getContentPane().add(resultView.getViewComponent());
        frame.pack();
        frame.setBounds((pos % 4) * size, (pos / 4) * size, size, size);
        frame.setTitle(title);
        frame.setVisible(true);
    }

    /**
     * Creates a {@link HitDisplayOptions} object with custom coloring options.
     *
     * @return coloring options object
     */
    public static HitDisplayOptions createColoringOptions() {

        // Create options object
        final HitDisplayOptions coloringOptions = new HitDisplayOptions();

        // Hit should be colored in target
        coloringOptions.setColoringEnabled(true);

        // Use custom colors for hit and non-hit parts of the target
        coloringOptions.setHitColor(Color.RED);
        coloringOptions.setNonHitColor(Color.GREEN);

        return coloringOptions;
    }

    private static class ResultView {

        private final JComponent mviewPane;
        private final Method setParamsMethod;
        private final Method setMMethod;

        ResultView() {
            try {
                final Class<?> clazz = Class.forName("chemaxon.marvin.beans.MViewPane");
                mviewPane = (JComponent) clazz.getConstructor().newInstance();
                setParamsMethod = clazz.getMethod("setParams", String.class);
                setMMethod = clazz.getMethod("setM", int.class, Molecule[].class);
            } catch (final Exception e) {
                throw new RuntimeException("Cannot open MarvinView for displaying results. "
                        + "Make sure that 'marvin-classic-gui' library is on the classpath.", e);
            }
        }

        void setParams(final String params) {
            try {
                setParamsMethod.invoke(mviewPane, params);
            } catch (final Exception e) {
                throw new RuntimeException("Error setting parameters for MViewPane.", e);
            }
        }

        void setM(final int pos, final Molecule mol) {
            try {
                setMMethod.invoke(mviewPane, pos, new Molecule[]{mol});
            } catch (final Exception e) {
                throw new RuntimeException("Error setting molecule for MViewPane.", e);
            }
        }

        JComponent getViewComponent() {
            return mviewPane;
        }

    }

}
