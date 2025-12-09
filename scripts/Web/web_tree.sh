#!/bin/bash

tree_file=$3

if [[ -f "$tree_file" ]]; then
  tree=$(cat "$tree_file")

  cat <<EOF
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <script src="https://unpkg.com/@phylocanvas/phylocanvas.gl@latest/dist/bundle.min.js"></script>
      <title>Phylogenetic Tree</title>
    </head>
    <body>
      <div id="demo" class="demo" style="width: 100%; height: 100vh;"></div>
      <script>
        const tree = new phylocanvas.PhylocanvasGL(
          document.querySelector("#demo"),
          {
            size: { width: window.innerWidth, height: window.innerHeight },
            source: JSON.stringify(\`$tree\`),
            type: phylocanvas.TreeTypes.Rectangular,
            showLabels: true,
            showLeafLabels: true
          },
          [
    phylocanvas.plugins.scalebar,
  ],
        );
      </script>
    </body>
  </html>
EOF


else
  echo "File not found. Please check the filename."
fi
