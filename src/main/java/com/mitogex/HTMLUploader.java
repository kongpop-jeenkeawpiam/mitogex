/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mitogex;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import javax.swing.JOptionPane;
/**
 *
 * @author mitogex
 */
public class HTMLUploader {
    public static String uploadReport(File htmlFile, String projectTitle, String sessionId, String relativePath) throws Exception {
        String boundary = Long.toHexString(System.currentTimeMillis());
        String CRLF = "\r\n";
        String token = "bf83079f-7262-4f2e-9ea4-fd0ab19c222b";

        URL url = new URL("https://mitogex.com/upload.php");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setDoOutput(true);
        connection.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

        try (
            OutputStream output = connection.getOutputStream();
            PrintWriter writer = new PrintWriter(new OutputStreamWriter(output, "UTF-8"), true)
        ) {
            // Token
            writer.append("--").append(boundary).append(CRLF);
            writer.append("Content-Disposition: form-data; name=\"token\"").append(CRLF);
            writer.append(CRLF).append(token).append(CRLF).flush();

            // Project title
            writer.append("--").append(boundary).append(CRLF);
            writer.append("Content-Disposition: form-data; name=\"project\"").append(CRLF);
            writer.append(CRLF).append(projectTitle).append(CRLF).flush();

            // Add session ID
writer.append("--").append(boundary).append(CRLF);
writer.append("Content-Disposition: form-data; name=\"session\"").append(CRLF);
writer.append(CRLF).append(sessionId).append(CRLF).flush();

// Add relative path for placing into subfolders on server
writer.append("--").append(boundary).append(CRLF);
writer.append("Content-Disposition: form-data; name=\"path\"").append(CRLF);
writer.append(CRLF).append(relativePath).append(CRLF).flush();


            // File
            writer.append("--").append(boundary).append(CRLF);
            writer.append("Content-Disposition: form-data; name=\"file\"; filename=\"" + htmlFile.getName() + "\"").append(CRLF);
            writer.append("Content-Type: text/html").append(CRLF);
            writer.append(CRLF).flush();
            try (InputStream input = new FileInputStream(htmlFile)) {
                input.transferTo(output);
            }
            output.flush();
            writer.append(CRLF).flush();

            // End boundary
            writer.append("--").append(boundary).append("--").append(CRLF).flush();
        }

        int responseCode = connection.getResponseCode();
        StringBuilder response = new StringBuilder();

        try (BufferedReader in = new BufferedReader(new InputStreamReader(
                responseCode == 200 ? connection.getInputStream() : connection.getErrorStream()))) {
            String line;
            while ((line = in.readLine()) != null) {
                response.append(line).append("\n");
            }
        }

     String full = response.toString().trim();
        if (responseCode == 200 && full.contains("https://")) {
            int urlStart = full.indexOf("https://");
            if (urlStart != -1) {
                return full.substring(urlStart).trim();  // ✅ Success URL
            }
        }

        // ❌ Show error to user if upload failed
        JOptionPane.showMessageDialog(null,
                response.toString(),
                "Upload Failed",
                JOptionPane.ERROR_MESSAGE);

        return null;
    }
}
