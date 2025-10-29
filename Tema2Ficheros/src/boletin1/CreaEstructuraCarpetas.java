package boletin1;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.File;

public class CreaEstructuraCarpetas {

    public static void main(String[] args) {
        
        String rutaArchivo = "C:\\Users\\jm.maya\\carpetas.txt";
        String rutaBase = "C:\\Users\\jm.maya\\";
        
        try (BufferedReader br = new BufferedReader(new FileReader(rutaArchivo))) {
            String linea;
            while ((linea = br.readLine()) != null) {
                linea = linea.trim();
                if (linea.isEmpty()) continue;

                String rutaCompleta = rutaBase + linea.replace("\\", File.separator);
                
                File carpeta = new File(rutaCompleta);
                if (!carpeta.exists()) {
                    boolean exito = carpeta.mkdirs();
                    if (exito) {
                        System.out.println("Carpeta creada: " + rutaCompleta);
                    } else {
                        System.out.println("No se pudo crear: " + rutaCompleta);
                    }
                } else {
                    System.out.println("Ya existe: " + rutaCompleta);
                }
            }
        } catch (IOException e) {
            System.out.println("Error al leer el archivo: " + e.getMessage());
        }
    }
}
