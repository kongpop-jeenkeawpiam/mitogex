#!/bin/bash

# Specify the directory you want to loop through
BASE_DIR="$1"
TARGET_DIR="$1/Results/ANNOVAR"
# Start creating the HTML file
cat <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MitoGEx: Mitochondria Genome Explorer</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.datatables.net/2.1.7/css/dataTables.bootstrap5.css" />
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/3.1.2/css/buttons.bootstrap5.css" />
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/1.6.5/css/buttons.dataTables.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
        }

        .content {
            padding: 20px;
        }
    </style>
</head>
<body>
   <!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
  <div class="container-fluid">
      <a class="navbar-brand" href="#">Mitochondrial Genome Explorer</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
          <ul class="navbar-nav ms-auto">
              <li class="nav-item">
                  <a class="nav-link active" aria-current="page" href="#">Home</a>
              </li>
              <li class="nav-item">
                  <a class="nav-link" href="https://mitogex.com">Contact</a>
              </li>
          </ul>
      </div>
  </div>
</nav>

EOL

# # Loop through all files in the specified directory
# for FILE in "$TARGET_DIR"/*; do
#     # Get the base name of the file (without the directory path)
#     BASENAME=$(basename "$FILE")
    
#     # Add each file name as a list item in the HTML file
#     echo "            <li><a href=\"$FILE\">$BASENAME</a></li>" >> "$OUTPUT_FILE"
# done

# TABLE
cat <<EOL
        <!-- Main Container -->
    <div class="container-fluid">
        <div class="row">
            <!-- Content -->
            <div id="mainContent" class="col content">
                <table id="example" class="table table-striped" style="width:100%">
                    <thead>
                        <tr>
                            <th>Sample Name</th>
                            <th>Haplogroup</th>
                            <th>Total variants</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
EOL
                      # Loop through files in the specified directory and extract file names
for FILE in "$TARGET_DIR"/*.hg38_multianno.txt; do
    # Get the base name of the file without the path and extension
    BASENAME=$(basename "$FILE" .hg38_multianno.txt)

    # Dummy values for demonstration (Replace with actual data extraction if needed)
    HAPLOGROUP=$(awk -F'\t' 'NR==2 {print $2}' "$BASE_DIR/Results/Haplogroup/$BASENAME.txt" | sed 's/"//g')
    TOTAL_VARIANTS=$(wc -l < "$FILE") # Example: count the number of lines as total variants

    # Append a row for each file into the HTML table
    cat <<EOL 
                        <tr>
                            <td>$BASENAME</td>
                            <td>$HAPLOGROUP</td>
                            <td>$TOTAL_VARIANTS</td>
                            <td><a href="sample_${BASENAME}.html" class="btn btn-outline-primary btn-sm">Details</a></td>
                        </tr>
EOL
done


   cat <<EOL
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Sample Name</th>
                            <th>Haplogroup</th>
                            <th>Total variants</th>
                            <th>Details</th>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>

     <!-- Bootstrap JS and Popper.js -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
    <!-- Load DataTables -->
    <script src="https://cdn.datatables.net/2.1.7/js/dataTables.js"></script>
    <script src="https://cdn.datatables.net/2.1.7/js/dataTables.bootstrap5.js"></script>
    <!-- Load Buttons extension -->
    <script src="https://cdn.datatables.net/buttons/3.1.2/js/dataTables.buttons.js"></script>
    <script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.bootstrap5.js"></script>

    <!-- Load dependencies for Buttons extension -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js"></script>

    <!-- Load additional scripts for Buttons extension -->
    <script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.html5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.print.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.colVis.min.js"></script>
    <script>
        // Initialize DataTable
        \$(document).ready(function() {
            new DataTable('#example', {
                layout: {
                    topStart: {
                        buttons: ['copy', 'excel', 'pdf', 'colvis']
                    }
                },
                dom: 'Bfrtip',
                language: {
                    search: 'Search:',
                    searchPlaceholder: 'Search samples'
                },
            });
        });
    </script>
</body>
</html>
EOL



