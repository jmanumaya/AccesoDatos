package boletin1;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class InsertaHTML {

    public static void main(String[] args) {
        
        String rutaBase = "C:\\Users\\jm.maya\\AD"; 
        String autor = "José Manuel";

        File base = new File(rutaBase);

        if (base.exists() && base.isDirectory()) {
            recorrerCarpetasYCrearHTML(base, autor);
            System.out.println("✅ Archivos HTML creados correctamente.");
        } else {
            System.out.println("❌ La ruta base no existe o no es un directorio.");
        }
    }

    private static void recorrerCarpetasYCrearHTML(File carpeta, String autor) {
        crearArchivoHTML(carpeta, autor);

        File[] archivos = carpeta.listFiles();
        if (archivos != null) {
            for (File f : archivos) {
                if (f.isDirectory()) {
                    recorrerCarpetasYCrearHTML(f, autor);
                }
            }
        }
    }

    private static void crearArchivoHTML(File carpeta, String autor) {
        String nombreCarpeta = carpeta.getName();
        String rutaCompleta = carpeta.getAbsolutePath();

        String contenido = """
                <html>
                   <head>
                      <title>%s</title>
                   </head>
                   <body>
                      <h1>%s</h1>
                      <h3>Autor: %s</h3>
                   </body>
                </html>
                """.formatted(nombreCarpeta, rutaCompleta, autor);

        File archivoHTML = new File(carpeta, nombreCarpeta + ".html");

        try (FileWriter fw = new FileWriter(archivoHTML)) {
            fw.write(contenido);
            System.out.println("✔ HTML creado en: " + archivoHTML.getAbsolutePath());
        } catch (IOException e) {
            System.err.println("Error al crear HTML en " + carpeta.getAbsolutePath() + ": " + e.getMessage());
        }
    }
}
