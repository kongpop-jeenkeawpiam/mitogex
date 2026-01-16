/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

package com.mitogex;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.util.concurrent.TimeUnit;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JWindow;
import javax.swing.SwingConstants;


/**
 *
 * @author mitogex
 */
public class MitoGEx {

    
    private static ImageIcon icon = null;
    public static void main(String[] args) throws MalformedURLException {
        
        
        
     // Trigger the update process
        boolean updateApplied = runUpdateScript();

        // If an update was applied, exit to allow the application to restart
        if (updateApplied) {
            System.out.println("Apllication is up to date.");
//            System.exit(0);
        }

        // Show splash screen
        showSplashScreen();

        // Launch the main application window
        JFrame main = new Main_windows();
        main.setVisible(true);
       
        
     
    }

     // Method to display the splash screen
    private static void showSplashScreen() {
        JWindow window = new JWindow();
        icon = new ImageIcon(MitoGEx.class.getResource("/images/mitogex.png"));
        window.getContentPane().add(new JLabel("", icon, SwingConstants.CENTER));
        window.setBounds(500, 150, 900, 675);
        window.setVisible(true);
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        window.setVisible(false);
        window.dispose();
    }

    // Method to run the update shell script
    private static boolean runUpdateScript() {
        String workingDir = System.getProperty("user.dir");
        String new_workingDir = workingDir.replaceAll("target", "");
        String concat = new_workingDir.concat("/Results/Fasta");
        String path_Update = new_workingDir.concat("/Software/scripts/./update.sh");
        try {
        // Run the shell script
        String[] updateCommand = {path_Update, new_workingDir};
        ProcessBuilder processBuilder = new ProcessBuilder(updateCommand);

        // Redirect the error stream to the standard output stream for easier handling
        processBuilder.redirectErrorStream(true);

        // Start the process
        Process process = processBuilder.start();

        // Create a thread to read the output
            Thread outputThread = new Thread(() -> {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        System.out.println(line); // Print the script's output to the console
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
            outputThread.start();

            // Wait for the script to complete, with a timeout of 15 seconds
            if (!process.waitFor(30, TimeUnit.SECONDS)) {
                System.out.println("Update script timed out. Proceeding with the program.");
                process.destroy(); // Terminate the process forcefully
                return false;
            }

            // Get exit code to check if the update was successful
            int exitCode = process.exitValue();
            if (exitCode == 0) {
                System.out.println("Update applied successfully.");
                return true;
            } else {
                System.out.println("No update was applied or script failed.");
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
//    public static boolean isUpdateAvailable() {
//    try {
//        URL url = new URL(VERSION_URL);
//        BufferedReader reader = new BufferedReader(new InputStreamReader(url.openStream()));
//        String latestVersion = reader.readLine().trim();
//        reader.close();
//        
//        // Compare the latest version with the current version
//        return latestVersion.compareTo(CURRENT_VERSION) > 0;
//        
//    } catch (Exception e) {
//        e.printStackTrace();
//        return false;
//    }
//}
//
//    public static void downloadUpdate() {
//    String updateUrl = "https://www.mitogex.whf.bz/MitoGEx_update.jar";
//    String tempFilePath = "MitoGEx_update.jar"; // Temporary file path for the update
//
//    try (InputStream in = new URL(updateUrl).openStream()) {
//        Files.copy(in, Paths.get(tempFilePath), StandardCopyOption.REPLACE_EXISTING);
//        System.out.println("Update downloaded successfully.");
//    } catch (Exception e) {
//        e.printStackTrace();
//    }
//}
//    // Method to apply the update using the shell script
//public static void applyUpdate() {
//    try {
//        // Run the update.sh script on Ubuntu
//        ProcessBuilder processBuilder = new ProcessBuilder("./update.sh");
//        processBuilder.start();
//        System.exit(0); // Exit the current application to allow the update to proceed
//    } catch (Exception e) {
//        e.printStackTrace();
//    }
//}
}
