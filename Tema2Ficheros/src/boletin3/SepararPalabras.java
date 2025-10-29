package boletin3;

import java.io.*;

public class SepararPalabras {
    public static void main(String[] args) {
    	File ficheroEntrada = new File("src/boletin3/palabras.txt");
    	File ficheroSalida = new File("src/boletin3/palabras_separadas.txt");

        try (BufferedReader br = new BufferedReader(new FileReader(ficheroEntrada));
             BufferedWriter bw = new BufferedWriter(new FileWriter(ficheroSalida))) {

            StringBuilder contenido = new StringBuilder();
            String linea;

            // Leer todo el contenido del fichero original
            while ((linea = br.readLine()) != null) {
                contenido.append(linea);
            }

            // Dividir el texto cada 5 caracteres
            String texto = contenido.toString();
            for (int i = 0; i < texto.length(); i += 5) {
                int fin = Math.min(i + 5, texto.length());
                String palabra = texto.substring(i, fin);
                bw.write(palabra);
                bw.newLine();
            }

            System.out.println("Fichero generado correctamente: " + ficheroSalida.getName());

        } catch (IOException e) {
            System.err.println("Error al procesar los ficheros: " + e.getMessage());
        }
    }
}
