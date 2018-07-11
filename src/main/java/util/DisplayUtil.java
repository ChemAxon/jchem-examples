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

import java.awt.Color;
import java.io.IOException;

import javax.swing.JFrame;

import chemaxon.formats.MolExporter;
import chemaxon.marvin.beans.MViewPane;
import chemaxon.struc.Molecule;
import chemaxon.util.HitColoringAndAlignmentOptions;

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
    public static String toSmiles(Molecule molecule) {
        try {
            return MolExporter.exportToFormat(molecule, "smiles");
        } catch (IOException e) {
            throw new IllegalArgumentException("SMILES export error", e);
        }
    }

    /**
     * Shows the given molecule on the screen in a JFrame window.
     * 
     * @param mol molecule to show
     * @param pos position number of the JFrame window on the screen
     */
    public static void showMolecule(Molecule mol, int pos, String title) {
        showMolecule(mol, pos, DEFAULT_FRAME_SIZE, title);
    }

    /**
     * Shows the molecule on the screen in a JFrame window of the given size.
     * 
     * @param mol molecule to show
     * @param pos position number of the JFrame window on the screen
     * @param size size of the JFrame window
     */
    public static void showMolecule(Molecule mol, int pos, int size, String title) {

        // Create an MViewPane
        MViewPane mvpane = new MViewPane();
        mvpane.setM(0, mol);

        // Display the result in a JFrame window
        JFrame frame = new JFrame();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.getContentPane().add(mvpane);
        frame.pack();
        frame.setBounds((pos % 4) * size, (pos / 4) * size, size, size);
        frame.setTitle(title);
        frame.setVisible(true);
    }

    /**
     * Creates a {@link HitColoringAndAlignmentOptions} object with custom coloring options.
     * 
     * @return coloring options object
     */
    public static HitColoringAndAlignmentOptions createColoringOptions() {

        // Create options object
        HitColoringAndAlignmentOptions coloringOptions = new HitColoringAndAlignmentOptions();

        // Hit should be colored in target
        coloringOptions.setColoringEnabled(true);

        // Use custom colors for hit and non-hit parts of the target
        coloringOptions.setHitColor(Color.RED);
        coloringOptions.setNonHitColor(Color.GREEN);

        return coloringOptions;
    }

}
