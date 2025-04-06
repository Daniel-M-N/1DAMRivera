✅ PRIMER PASO: Crear el repositorio en GitHub (si no lo has hecho)
1.	Ve a https://github.com/new.
2.	Nombre del repositorio: por ejemplo, PracticaJavaFXSQLite
3.	Selecciona:
o	Público o Privado según prefieras.
o	Sin README (para evitar conflictos si ya tienes archivos locales).
4.	Haz clic en Create repository.
Esto te dará una URL parecida a esta:
arduino
CopiarEditar
https://github.com/Daniel-M-N/PracticaJavaFXSQLite.git
Guárdala, que la usaremos en IntelliJ.
________________________________________
🧩 SEGUNDO PASO: Abrir y preparar tu proyecto en IntelliJ
1.	Abre IntelliJ IDEA
2.	Ve a File > Open y selecciona la carpeta donde descomprimiste el .zip.
3.	Espera a que el proyecto cargue (puede tardar un poco si es Maven y descarga dependencias).
________________________________________
🧪 TERCER PASO: Probar que funciona
Antes de subirlo:
•	Ejecuta MainApp.java para asegurarte de que todo está correcto.
________________________________________
⬆️ CUARTO PASO: Subir el proyecto a GitHub
1.	Ve a VCS > Enable Version Control Integration...
o	Selecciona Git y haz clic en OK.
2.	Ve a VCS > Commit...
o	Asegúrate de que todos los archivos están marcados.
o	Escribe un mensaje de commit como "Primer commit del proyecto JavaFX".
o	Haz clic en Commit (o Commit and Push si ya tienes el repo remoto).
3.	Si no hiciste el Push directamente:
o	Ve a Git > Manage Remotes
o	Añade un nuevo remoto con:
	Name: origin
	URL: https://github.com/Daniel-M-N/PracticaJavaFXSQLite.git
4.	Finalmente, haz el Push:
o	Ve a Git > Push
o	Verifica la rama y haz clic en Push
________________________________________
🏁 ¡Listo!
Tu proyecto ya estará disponible en GitHub en la URL del repositorio.

