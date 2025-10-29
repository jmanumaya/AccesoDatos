package boletin3;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Collections;

public class OrdenarPalabras {
    public static void main(String[] args) {
    	File ficheroEntrada = new File("src/boletin3/palabras_separadas.txt");
        File ficheroSalida = new File("src/boletin3/palabrasOrdenadas.txt");

        try {
            ArrayList<String> listaPalabras = new ArrayList<>();

            try (RandomAccessFile raf = new RandomAccessFile(ficheroEntrada, "r")) {
                String palabra;
                while ((palabra = raf.readLine()) != null) {
                    listaPalabras.add(palabra.trim());
                }
            }

            Collections.sort(listaPalabras);

            try (RandomAccessFile rafOut = new RandomAccessFile(ficheroSalida, "rw")) {
                rafOut.setLength(0);
                for (String palabra : listaPalabras) {
                    rafOut.writeBytes(palabra + System.lineSeparator());
                }
            }

            System.out.println("Fichero 'palabrasOrdenadas.txt' creado correctamente.");

        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
