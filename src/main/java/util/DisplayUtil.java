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
import chemaxon.marvin.beans.MViewPane;
import chemaxon.search.hitdisplay.HitDisplayOptions;
import chemaxon.struc.Molecule;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;

/**
 * Various utility functions used in the example codes for displaying molecules.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DisplayUtil {

    private static final int DEFAULT_FRAME_SIZE = 300;

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

        // Create an MViewPane
        final MViewPane mvpane = new MViewPane();
        mvpane.setM(0, mol);

        // Display the result in a JFrame window
        final JFrame frame = new JFrame();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.getContentPane().add(mvpane);
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

}
