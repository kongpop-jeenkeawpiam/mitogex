#!/bin/bash

# Specify the directory you want to loop through
BASE_DIR="$1"
TARGET_DIR="$1/Results/Haplogroup"
LOGO_DIR="$1/Software/scripts/Web"
DATA_FILE="$BASE_DIR/Results/exported_haplogroup_data.txt"
TREE_FILE="$BASE_DIR/Software/haplogrep3/trees/phylotree-fu-rcrs/1.2/tree.yaml"


# Extract population colors
declare -A population_colors
while IFS="=" read -r key value; do
    population_colors["$key"]="$value"
done < <(yq -r '.populations[] | "\(.id)=\(.color)"' "$TREE_FILE")

# Extract cluster colors
declare -A cluster_colors
while IFS="=" read -r label color; do
    cluster_colors["$label"]="$color"
done < <(yq -r '.clusters[] | "\(.label)=\(.color)"' "$TREE_FILE")

# Extract cluster frequencies
declare -A cluster_frequencies
while IFS="=" read -r key value; do
    cluster_frequencies["$key"]+="$value "  # Append frequencies with space to handle multiple
done < <(yq -r '.clusters[] | select(.frequencies != null) | .label as $l | .frequencies | to_entries | map("\($l),\(.key)=\(.value)") | .[]' "$TREE_FILE")

# Output CSV file
CSV_FILE="population_data.csv"
echo "Cluster,Population,Frequency,Color" > "$CSV_FILE"

# Write the results to CSV (handling multiple frequencies)
for key in "${!cluster_frequencies[@]}"; do
    IFS=',' read -r cluster_label pop <<< "$key"
    for freq in ${cluster_frequencies[$key]}; do  # Loop through multiple frequencies
        color="${population_colors[$pop]:-N/A}"
        echo "$cluster_label,$pop,$freq,$color" >> "$CSV_FILE"
    done
done



# Start creating the HTML file
cat <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MitoGEx: Mitochondria Genome Explorer</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.datatables.net/2.1.7/css/dataTables.bootstrap5.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/3.1.2/css/buttons.bootstrap5.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body {
            font-family: Arial, sans-serif;
        }
        .content {
            padding: 20px;
        }
        .progress {
            height: 18px;
            border-radius: 10px;
        }
        .progress-bar {
            font-size: 14px;
            font-weight: bold;
            text-align: center;
            border-radius: 10px;
        }
        .freq-bar { 
        height: 12px; 
        border-radius: 5px; 
        display: inline-block; 
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>

<!-- Navigation Tabs -->
<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link active" id="summary-tab" href="#">Summary</a>
    </li>
    <li class="nav-item">
        <a class="nav-link" id="samples-tab" href="#">Samples</a>
    </li>
</ul>

<!-- Summary Content -->
<div id="summary-content">
    <div class="container mt-3">
        <div class="row">
            <div class="col-md-6">
                <h4>Haplogroups</h4>
                <select id="viewType" class="form-select mb-3">
                    <option value="clusters">Clusters</option>
                    <option value="haplogroups">Haplogroups</option>
                </select>
                <canvas id="haplogroupChart"></canvas>
            </div>
            <div class="col-md-6">
                <h4>Clusters</h4>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Cluster</th>
                            <th>Count</th>
                            <th>Percentage</th>
                            <th>Population Frequencies</th>
                        </tr>
                    </thead>
                    <tbody id="clusterTable"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>



<!-- Samples Content (Initially Hidden) -->
<div id="samples-content" class="hidden">
    <div class="container-fluid mt-3">
    
        <!-- Data Table -->
        <table id="sample_haplogroup" class="table table-striped" style="width:100%">
            <thead>
                <tr>
                    <th>Sample Name</th>
                    <th>Haplogroup</th>
                    <th>Quality</th>
                    <th>Coverage</th>
                    <th>Missing Mutations</th>
                    <th>Global Private Mutations</th>
                </tr>
            </thead>
            <tbody>
EOL

# Define output file
OUTPUT_FILE="$BASE_DIR/Results/exported_haplogroup_data.txt"

# Check if the output file already exists and remove it before creating a new one
if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
fi

# Create a new file with headers
echo -e "Sample_Name\tHaplogroup\tQuality\tCoverage\tMissing_Mutations\tGlobal_Private_Mutations" > "$OUTPUT_FILE"


# Loop through haplogroup result files
for FILE in "$TARGET_DIR"/*.txt; do
    BASENAME=$(basename "$FILE" .txt)
    if [[ "$FILE" != *"qc"* ]]; then
        # Extract relevant data from the files
        HAPLOGROUP=$(awk -F'\t' 'NR==2 {print $2}' "$BASE_DIR/Results/Haplogroup/$BASENAME.txt" | sed 's/"//g')
        Quality=$(awk -F'\t' 'NR==2 {print $4}' "$BASE_DIR/Results/Haplogroup/$BASENAME.txt" | sed 's/"//g')
        RangeHap=$(awk -F'\t' 'NR==2 {print $5}' "$BASE_DIR/Results/Haplogroup/$BASENAME.txt" | sed 's/"//g' | sed 's/^1-//')
        MissMutation=$(sed -n '2p' "$BASE_DIR/Results/Haplogroup/$BASENAME.qc.txt" | awk -F'"\t"' '{print $5}' | sed 's/"//g')
        GlobalMutation=$(sed -n '2p' "$BASE_DIR/Results/Haplogroup/$BASENAME.qc.txt" | awk -F'"\t"' '{print $6}' | sed 's/"//g')
        
        # Calculate quality percentage
        QualityPercentage=$(echo "$Quality * 100" | bc)

        # Append extracted data to output file
        echo -e "$BASENAME\t$HAPLOGROUP\t$QualityPercentage\t$RangeHap\t$MissMutation\t$GlobalMutation" >> "$OUTPUT_FILE"

        # Append a row for each sample
        cat <<EOL
                <tr>
                    <td>$BASENAME</td>
                    <td>$HAPLOGROUP</td>
                    <td>
                        <div class="progress">
                            <div class="progress-bar bg-primary" role="progressbar" style="width: ${QualityPercentage}%" aria-valuenow="${QualityPercentage}" aria-valuemin="0" aria-valuemax="100">
                                $Quality
                            </div>
                        </div>
                    </td>
                    <td>$RangeHap</td>
                    <td>$MissMutation</td>
                    <td>$GlobalMutation</td>
                </tr>
EOL
    fi
done

# Initialize cluster and haplogroup data collection
declare -A haplogroup_counts
declare -A cluster_counts
haplogroup_json="["
cluster_json="["
total_samples=0

# Loop through haplogroup result files
while IFS=$'\t' read -r sample haplogroup quality coverage missing global_mutations; do
    if [[ "$haplogroup" != "Haplogroup" ]]; then
        safe_haplogroup=$(echo "$haplogroup" | sed "s/'/./g" | tr -d "\" ")
        original_haplogroup=$(echo "$haplogroup" | tr -d "\" ")

        ((haplogroup_counts["$safe_haplogroup"]++))

        if [[ "$haplogroup" =~ ^L[123] ]]; then
            cluster_name="${haplogroup:0:2}"
        else
            cluster_name="${haplogroup:0:1}"
        fi

        ((cluster_counts["$cluster_name"]++))
        ((total_samples++))

        haplogroup_json+="{\"label\": \"$original_haplogroup\", \"count\": ${haplogroup_counts[$safe_haplogroup]}},"
    fi
done < "$DATA_FILE"

# Convert Cluster counts to JSON
for cluster in "${!cluster_counts[@]}"; do
    percentage=$((cluster_counts[$cluster] * 100 / total_samples))
    cluster_json+="{\"label\": \"$cluster\", \"count\": ${cluster_counts[$cluster]}, \"percentage\": ${percentage}},"
done

haplogroup_json="${haplogroup_json%,}]"
cluster_json="${cluster_json%,}]"



# Close table and scripts
cat <<EOL
            </tbody>
        </table>
    </div>
</div>

<!-- Bootstrap & DataTables Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
<script src="https://cdn.datatables.net/2.1.7/js/dataTables.js"></script>
<script src="https://cdn.datatables.net/2.1.7/js/dataTables.bootstrap5.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.2/js/dataTables.buttons.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.bootstrap5.js"></script>

<!-- DataTables Extensions -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.print.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.2/js/buttons.colVis.min.js"></script>

<!-- Initialize DataTable -->
<script>
 document.addEventListener("DOMContentLoaded", function () {
    //
    // 1) Define your population array
    //
    const populations = [
      { id: "afr", label: "African/African American", color: "#941494" },
      { id: "nfe", label: "European (non-Finnish)", color: "#6aa5cd" },
      { id: "fin", label: "European (Finnish)", color: "#002f6c" },
      { id: "ami", label: "Amish", color: "#6ab8cd" },
      { id: "asj", label: "Ashkenazi Jewish", color: "#6a8bcd" },
      { id: "mid", label: "Middle Eastern", color: "#b5960b" },
      { id: "sas", label: "South Asian", color: "#ff9912" },
      { id: "eas", label: "East Asian", color: "#108c44" },
      { id: "amr", label: "Latino/Admixed American", color: "#ed1e24" },
      { id: "oth", label: "Other", color: "#abb9b9" }
    ];

    // Build a quick lookup map: e.g. popMap["eas"] => { label: "East Asian", color: "#108c44" }
    const popMap = {};
    populations.forEach(pop => {
        popMap[pop.id] = pop;
    });

    // Also record the desired order of populations (based on the array above)
    const populationOrder = populations.map(p => p.id);

    // 2) Haplogroup and Cluster data from Bash
    const haplogroupData = $haplogroup_json;
    const clusterData = $cluster_json;

    // 3) Read CSV Data from Bash (Population Frequencies)
    //    Expecting columns: cluster, populationID, frequency, color
    const csvPopulationData = \`
$(cat "$CSV_FILE")
    \`.trim().split("\\n").slice(1).map(row => row.split(","));

    // 4) Process Population Frequencies into an object
    let populationFrequenciesData = {};
    csvPopulationData.forEach(([cluster, populationID, frequency, csvColor]) => {
        if (!populationFrequenciesData[cluster]) {
            populationFrequenciesData[cluster] = [];
        }
        // Look up the label & color from popMap if it exists
        let popLabel = populationID;
        let popColor = csvColor;
        if (popMap[populationID]) {
            popLabel = popMap[populationID].label;     // e.g. "East Asian"
            popColor = popMap[populationID].color;     // e.g. "#108c44"
        }

        populationFrequenciesData[cluster].push({
            populationID,  // short ID
            label: popLabel,  // e.g. "East Asian"
            frequency: parseFloat(frequency),
            color: popColor
        });
    });

    // 4a) Sort the population frequencies for each cluster
    //     according to the order in 'populationOrder' array
    Object.keys(populationFrequenciesData).forEach(clusterKey => {
        populationFrequenciesData[clusterKey].sort((a, b) =>
            populationOrder.indexOf(a.populationID) - populationOrder.indexOf(b.populationID)
        );
    });

    //
    // 5) Create the stacked bar chart DOM (tooltips)
    //
    function createStackedBar(clusterLabel) {
        let totalWidth = 100;
        let barContainer = document.createElement("div");
        barContainer.className = "stacked-bar";
        barContainer.style.display = "flex";
        barContainer.style.width = "100%";
        barContainer.style.height = "15px";
        barContainer.style.borderRadius = "5px";
        barContainer.style.overflow = "visible"; // ensure tooltips are not clipped

        if (populationFrequenciesData[clusterLabel]) {
            populationFrequenciesData[clusterLabel].forEach(freqObj => {
                let segment = document.createElement("div");
                segment.className = "bar-segment";
                segment.style.width = (freqObj.frequency * totalWidth) + "%";
                segment.style.backgroundColor = freqObj.color || "#ccc";
                segment.style.position = "relative";
                segment.style.cursor = "pointer";



                // Tooltip container
                let tooltip = document.createElement("div");
                tooltip.className = "tooltip";
                tooltip.innerText = \`\${freqObj.label} (\${(freqObj.frequency * 100).toFixed(1)}%)\`;
                tooltip.style.position = "absolute";
                tooltip.style.bottom = "120%";
                tooltip.style.left = "50%";
                tooltip.style.transform = "translateX(-50%)";
                tooltip.style.padding = "6px";
                tooltip.style.fontSize = "12px";
                tooltip.style.color = "#fff";
                tooltip.style.background = "rgba(0, 0, 0, 0.8)";
                tooltip.style.borderRadius = "5px";
                tooltip.style.visibility = "hidden";
                tooltip.style.opacity = "0";
                tooltip.style.transition = "opacity 0.3s ease-in-out";
                tooltip.style.whiteSpace = "nowrap";

                segment.addEventListener("mouseenter", function () {
                    tooltip.style.visibility = "visible";
                    tooltip.style.opacity = "1";
                });
                segment.addEventListener("mouseleave", function () {
                    tooltip.style.visibility = "hidden";
                    tooltip.style.opacity = "0";
                });

                segment.appendChild(tooltip);
                barContainer.appendChild(segment);
            });
        }
        return barContainer;
    }

    //
    // 6) Populate Cluster Table
    //
    const clusterTable = document.getElementById("clusterTable");

    // Sort clusters by ascending count
    clusterData.sort((a, b) => b.count - a.count);

    clusterData.forEach(cluster => {
        let row = document.createElement("tr");

        let labelTd = document.createElement("td");
        labelTd.innerHTML = \`<strong>\${cluster.label}</strong>\`;

        let countTd = document.createElement("td");
        countTd.textContent = cluster.count;

        let percTd = document.createElement("td");
        percTd.textContent = \`\${cluster.percentage}%\`;

        let barTd = document.createElement("td");
        barTd.appendChild(createStackedBar(cluster.label));

        row.appendChild(labelTd);
        row.appendChild(countTd);
        row.appendChild(percTd);
        row.appendChild(barTd);

        clusterTable.appendChild(row);
    });

    //
    // 7) Chart Setup (doughnut charts, etc.)
    //
    function getRandomColors(count) {
        const colors = new Set();
        const goldenRatio = 0.618033988749895;
        let hue = Math.random() * 360;
        while (colors.size < count) {
            hue += goldenRatio * 360;
            hue %= 360;
            let color = \`hsl(\${Math.floor(hue)}, 70%, 60%)\`;
            colors.add(color);
        }
        return Array.from(colors);
    }

    const ctx = document.getElementById("haplogroupChart").getContext("2d");
    let dynamicChart;

    function createChart(labels, counts, colors) {
        if (dynamicChart) {
            dynamicChart.destroy();
        }
        dynamicChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Samples',
                    data: counts,
                    backgroundColor: colors,
                }]
            }
        });
    }

    // Build the cluster-based chart (in ascending order)
    document.getElementById("viewType").value = "clusters";
    document.getElementById("haplogroupChart").style.display = "block";

    const clusterLabels = clusterData.map(item => item.label);
    const clusterCounts = clusterData.map(item => item.count);
    const clusterColors = getRandomColors(clusterLabels.length);
    createChart(clusterLabels, clusterCounts, clusterColors);

    // Haplogroup data
    const haploLabels = haplogroupData.map(item => item.label);
    const haploCounts = haplogroupData.map(item => item.count);
    const haploColors = getRandomColors(haploLabels.length);

    // Switch between charts
    document.getElementById("viewType").addEventListener("change", function () {
        if (this.value === "haplogroups") {
            document.getElementById("haplogroupChart").style.display = "block";
            createChart(haploLabels, haploCounts, haploColors);
        } else if (this.value === "clusters") {
            document.getElementById("haplogroupChart").style.display = "block";
            createChart(clusterLabels, clusterCounts, clusterColors);
        } else {
            document.getElementById("haplogroupChart").style.display = "none";
        }
    });

    // DataTable
    new DataTable('#sample_haplogroup', {
        layout: {
            topStart: {
                buttons: ['copy', 'excel', 'csv', 'pdf', 'print']
            }
        },
        dom: 'Bfrtip',
        language: {
            search: 'Search:',
            searchPlaceholder: 'Search samples'
        },
    });

    // Simple tab switching
    \$("#summary-tab").on("click", function () {
        \$("#summary-content").show();
        \$("#samples-content").hide();
        \$("#summary-tab").addClass("active");
        \$("#samples-tab").removeClass("active");
    });

    \$("#samples-tab").on("click", function () {
        \$("#samples-content").show();
        \$("#summary-content").hide();
        \$("#samples-tab").addClass("active");
        \$("#summary-tab").removeClass("active");
    });
});
</script>

</body>
</html>
EOL
