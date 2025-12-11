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
    <script src="https://unpkg.com/phylocanvas@2.8.1/dist/phylocanvas.js"></script>
    <title>Phylogenetic Tree</title>
    <style>
      body { margin: 0; padding: 0; width: 100vw; height: 100vh; overflow: hidden; font-family: sans-serif; }
      
      #controls {
        position: absolute;
        top: 10px;
        left: 10px;
        z-index: 100;
        background: rgba(255, 255, 255, 0.95);
        padding: 10px 15px;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        align-items: center;
        max-width: 95%;
      }
      
      select, button, input[type="text"] { 
        padding: 6px 10px; 
        font-size: 14px; 
        border: 1px solid #ccc; 
        border-radius: 4px; 
      }
      
      button { cursor: pointer; }
      button:hover { background-color: #f0f0f0; }
      
      #search-box {
        width: 120px;
        border: 1px solid #007bff;
      }

      .toggle-label {
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: 5px;
        cursor: pointer;
        user-select: none;
      }
      
      button#download-btn {
        background-color: #007bff;
        color: white;
        border: none;
      }
      button#download-btn:hover { background-color: #0056b3; }
      
      #demo { width: 100%; height: 100%; }
    </style>
  </head>
  <body>
  
    <div id="controls">
      <input type="text" id="search-box" placeholder="Search Node..." onkeyup="searchTree()" />

      <div>
        <select id="style-select" onchange="changeStyle(this.value)">
          <option value="radial">Radial</option>
          <option value="rectangular">Rectangular</option>
          <option value="circular">Circular</option>
          <option value="diagonal">Diagonal</option>
        </select>
      </div>

      <label class="toggle-label">
        <input type="checkbox" id="toggle-boot" checked onclick="toggleBootstrap()"> 
        Bootstraps
      </label>

      <button id="download-btn" onclick="downloadImage()">⬇ Image</button>
      <button onclick="resetTree()">⟲ Reset</button>
    </div>

    <div id="demo"></div>
    
    <script>
      const tree = new Phylocanvas.Tree('demo', {
        header: false,
        showBootstrap: true,     
        showInternalNodeLabels: true,
        textSize: 20, // Standard readable start size
        treeType: 'radial', 
      });

      // --- INITIAL STYLE SETUP ---
      tree.on('beforeDrawing', function () {
          // Use Object.values() for safety against crashes
          const branches = Object.values(tree.branches);
          
          branches.forEach(function (branch) {
              if (!branch.labelStyle) branch.labelStyle = {};

              // Handle Red Bootstraps (Internal Nodes)
              if (branch.children.length > 0 && branch.label) {
                  branch.labelStyle.colour = 'red'; 
                  // We let the library handle font size/position naturally here
                  branch.labelStyle.textSize = 20; 
                  branch.labelStyle.font = 'bold 20px Arial';
              }
          });
      });

      tree.load(\`$tree\`);

      function toggleBootstrap() {
        const checkbox = document.getElementById('toggle-boot');
        tree.showInternalNodeLabels = checkbox.checked;
        tree.draw(); 
      }

      function searchTree() {
        const query = document.getElementById('search-box').value.toLowerCase();
        // Use Object.values() for safety
        const leaves = Object.values(tree.leaves);

        leaves.forEach(function (leaf) {
          if (!leaf.nodeStyle) leaf.nodeStyle = {}; 
          if (!leaf.labelStyle) leaf.labelStyle = {};

          const name = (leaf.label || leaf.id || "").toLowerCase();

          if (query !== "" && name.includes(query)) {
            // HIGHLIGHT MATCH
            leaf.highlighted = true;
            leaf.labelStyle.colour = 'blue';
            // Make match clearly visible (30px)
            leaf.labelStyle.textSize = 30;
            leaf.labelStyle.font = 'bold 30px Arial';
            leaf.nodeStyle.fillClassName = 'highlighted-node';
            leaf.nodeStyle.fillStyle = 'blue';
            leaf.nodeStyle.r = 10; 
          } else {
            // RESET NON-MATCH
            leaf.highlighted = false;
            leaf.labelStyle.colour = 'black'; 
            // Return to standard size
            leaf.labelStyle.textSize = 20;
            leaf.labelStyle.font = '20px Arial';
            leaf.nodeStyle.fillStyle = 'black';
            leaf.nodeStyle.r = 5;
          }
        });
        
        tree.draw(); 
      }

      function changeStyle(newType) {
        tree.setTreeType(newType);
      }
      
      function downloadImage() {
        const canvasElement = document.querySelector('#demo canvas');
        if (canvasElement) {
            const imageURI = canvasElement.toDataURL("image/png");
            const link = document.createElement('a');
            link.href = imageURI;
            link.download = 'tree_view.png';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } else {
            alert("Error: Canvas not found.");
        }
      }

      function resetTree() {
         document.getElementById('search-box').value = "";
         searchTree(); // Clear search highlights
         tree.fitInPanel(); // Reset Zoom/Pan
      }

      // Sync UI on Load
      const dropdown = document.getElementById('style-select');
      dropdown.value = tree.treeType; 
      
      const checkbox = document.getElementById('toggle-boot');
      checkbox.checked = true;
      tree.showInternalNodeLabels = true;

      tree.draw();
    </script>
  </body>
</html>
EOF

else
  echo "Error: File '$tree_file' not found."
fi