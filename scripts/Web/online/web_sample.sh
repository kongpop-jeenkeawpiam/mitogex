#!/bin/bash

#Online Version of MitoGEx
# This script generates an HTML report for a given sample using data from ANNOVAR and other sources.
# Get the sample parameter
SAMPLE="$2"
BASE_DIR="$1"
TARGET_DIR="$BASE_DIR/Results/ANNOVAR"
INPUT_FILE="$TARGET_DIR/${SAMPLE}.hg38_multianno.txt"
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
    .modal-section {
            margin-bottom: 20px;
        }
        .modal-section h5 {
            background-color: #28a745;
            color: white;
            padding: 5px;
            border-radius: 4px;
        }
        .modal-section-info h5 {
            background-color: #BDBDBD;
            color: white;
            padding: 5px;
            border-radius: 4px;
        }
        .modal-section.warning h5 {
            background-color: #ffc107;
            color: black;
        }
        .modal-section.danger h5 {
            background-color: #F95454;
            color: black;
        }
        .modal-section table {
            width: 100%;
        }
        .modal-section td {
            padding: 5px;
        }
        body {
            font-family: Arial, sans-serif;
        }

        .sidebar {
            position: fixed;
            top: 56px;
            left: 0;
            height: calc(100vh - 56px);
            width: 250px;
            background-color: #343a40;
            padding: 15px;
            transition: transform 0.3s ease; /* Slide effect */
            transform: translateX(0); /* Sidebar starts visible */
        }

        .sidebar.hide {
            transform: translateX(-250px); /* Hide sidebar */
        }

        .sidebar ul {
    list-style: none;
    padding: 0;
}

.sidebar ul li {
    margin-bottom: 10px;
    /* Remove background-color, padding, and border-radius from the li */
}

.sidebar ul li a {
    display: block;
    color: white;
    text-decoration: none;
    padding: 10px;  /* Ensure padding makes the link fill the rectangle */
    background-color: #495057;
    border-radius: 4px;
}

.sidebar ul li a:hover {
    background-color: #6c757d;
    color: #ddd;
}


        .content {
            padding: 20px;
            margin-left: 250px;
            transition: margin-left 0.3s ease; /* Match content move speed */
        }

        .content.collapsed {
            margin-left: 0; /* Adjust content when sidebar is hidden */
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
      <!-- Hamburger button to toggle sidebar -->
      <button class="btn btn-outline-light d-inline" id="sidebarToggle" aria-controls="sidebar" aria-label="Toggle sidebar">
          <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
          <ul class="navbar-nav ms-auto">
              <li class="nav-item">
                  <a class="nav-link active" aria-current="page" href="index.html">Home</a>
              </li>
              <li class="nav-item">
                  <a class="nav-link" href="https://mitogex.com">Contact</a>
              </li>
              
          </ul>
      </div>
  </div>
</nav>

EOL

cat <<EOL
        <!-- Main Container -->
    <div class="container-fluid">
        <div class="row">
         <!-- Sidebar -->
            <div id="sidebar" class="sidebar">
                <h4 class="text-white">All Results</h4>
    <ul>
                <li><a href="#" class="load-file" data-file="multiqc_report.html">MultiQC</a></li>
                <li><a href="#" class="load-file" data-file="MultiSample_QC/multisampleBamQcReport.html">Alignment quality</a></li>
                 <li><a href="#" class="load-file" data-file="haplogroup.html">Haplogroup</a></li>
                 <li><a href="#" class="load-file" data-file="tree.html">Phylogenetic tree</a></li>
                </ul>
                <h4 class="text-white">${SAMPLE}</h4>
                <ul>
EOL

# FastQC Forward
FASTQC1="${BASE_DIR}/Results/FastQC/${SAMPLE}/${SAMPLE}_1_fastqc.html"
if [[ -f "$FASTQC1" ]]; then
    echo "<li><a href=\"#\" class=\"load-file\" data-file=\"${SAMPLE}_1_fastqc.html\">Quality control #1 (FastQC)</a></li>"
fi

# FastQC Reverse
FASTQC2="${BASE_DIR}/Results/FastQC/${SAMPLE}/${SAMPLE}_2_fastqc.html"
if [[ -f "$FASTQC2" ]]; then
    echo "<li><a href=\"#\" class=\"load-file\" data-file=\"${SAMPLE}_2_fastqc.html\">Quality control #2 (FastQC)</a></li>"
fi

# Fastp
FASTP="${BASE_DIR}/Results/Fastp/${SAMPLE}/${SAMPLE}.html"
if [[ -f "$FASTP" ]]; then
    echo "<li><a href=\"#\" class=\"load-file\" data-file=\"${SAMPLE}.html\">Quality control (Fastp)</a></li>"
fi

cat <<EOL
                <li><a href="#" class="load-file" data-file="AlignmentQuality/${SAMPLE}/qualimapReport.html">Alignment quality</a></li>
                <li><a href="sample_${SAMPLE}.html">Variants</a></li>
            </ul>
            </div>
            <!-- Content -->
            <div id="mainContent" class="col content">
                <table id="example" class="table table-striped" style="width:100%">
                    <thead>
                <tr>
                    <th>No.</th>
                    <th>Position</th>
                    <th>Ref</th>
                    <th>Alt</th>
                    <th>Gene Symbol</th>
                    <th>Functional Effect</th>
                    <th>MITOMAP Disease Clinical Information</th>
                    <th>MITOMAP Disease Clinical Status</th>
                    <th>References</th>
                    <th>Details</th>
                </tr>
                    </thead>
                    <tbody>
EOL
 
counter=1
 # Read the input file for the sample and generate table rows
if [[ -f "$INPUT_FILE" ]]; then
    tail -n +2 "$INPUT_FILE" | while IFS=$'\t' read -r Chr Start End Ref Alt Molecule_type Gene_symbol Extended_annotation Gene_position Gene_start Gene_end Gene_strand Codon_substitution AA_ref AA_alt AA_pos Functional_effect_general Functional_effect_detailed OMIM_id HGVS HGNC_id Respiratory_Chain_complex Ensembl_protein_id Ensembl_transcript_id Ensembl_gene_id Uniprot_id Uniprot_name NCBI_gene_id NCBI_protein_id PolyPhen2 PolyPhen2_score SIFT SIFT_score SIFT4G SIFT4G_score VEST_pvalue VEST VEST_FDR Mitoclass1 SNPDryad_score SNPDryad MitoTip_count MutationTaster_score MutationTaster_converted_rankscore MutationTaster MutationTaster_model MutationTaster_AAE FATHMM_score FATHMM_converted_rankscore FATHMM AlphaMissense_score AlphaMissense CADD_score CADD_phred_score CADD PROVEAN_score PROVEAN MutationAssessor MutationAssessor_score EFIN_SP_score EFIN_SP EFIN_HD_score EFIN_HD MLC MLC_score PANTHER PANTHER_score PhD_SNP PhD_SNP_score APOGEE1_score APOGEE1 APOGEE2_score APOGEE2_probability APOGEE2 CAROL_score CAROL Condel_score Condel COVEC_WMV_score COVEC_WMV MtoolBox_DS MtoolBox DEOGEN2_score DEOGEN2_rankscore DEOGEN2 Meta_SNP Meta_SNP_score PhastCons_100V PhyloP_100V PhyloP_470Way PhastCons_470Way Clinvar_id Clinvar_ALLELEID Clinvar_CLNDISDB Clinvar_CLNDN Clinvar_CLNSIG MITOMAP_Disease_Hom_Het MITOMAP_Disease_Clinical_info MITOMAP_Disease_Status MITOMAP_General_GenBank_Freq MITOMAP_General_GenBank_Seqs MITOMAP_General_GenBank_Curated_refs MITOMAP_Variant_Class HelixMTdb_AC_hom HelixMTdb_AF_hom HelixMTdb_AC_het HelixMTdb_AF_het HelixMTdb_mean_ARF HelixMTdb_max_ARF ToMMo_54KJPN_AC ToMMo_54KJPN_AF ToMMo_54KJPN_AN Gnomad_AN Gnomad_AC_hom Gnomad_AC_het Gnomad_AF_hom Gnomad_AF_het Gnomad_filter GenBank_freq hpl_cnt_tot_frq Dloop_genbank_haplogroup_count COSMIC_90_id dbSNP_156 SIFT_transf_score SIFT_transf PolyPhen2_transf_score PolyPhen2_transf MutationAssessor_transf_score MutationAssessor_transf CHASM_pvalue CHASM_FDR CHASM CPD_Frequency CPD_AA_ref CPD_AA_alt CPD_Aln_pos CPD_RefSeq_protein_id CPD_Species_name CPD_Ncbi_taxon_id EVmutation Site_A_InterP Site_B_InterP Covariation_score_InterP Site_A_IntraP Site_B_IntraP Covariation_score_IntraP DDG_intra DDG_intra_interface DDG_inter homoplasmy heteroplasmy; do
        
        references_content="No References" # Default to "No References"
        current_refs_input="${MITOMAP_General_GenBank_Curated_refs}"

        if [[ "${current_refs_input}" != "N/A" ]] && [[ -n "${current_refs_input}" ]]; then
            actual_valid_entry_count=0
            valid_refs_for_data_attr=""
            first_valid_ref=true

            IFS=';' read -ra ADDR <<< "$current_refs_input"
            for id_val in "${ADDR[@]}"; do
                trimmed_id_val=$(echo "$id_val" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') # Trim whitespace robustly
                if [[ -n "$trimmed_id_val" ]] && [[ "$trimmed_id_val" =~ ^[0-9]+$ ]]; then # Check if non-empty AND purely numeric
                    ((actual_valid_entry_count++))
                    if [[ "$first_valid_ref" == true ]]; then
                        valid_refs_for_data_attr="$trimmed_id_val"
                        first_valid_ref=false
                    else
                        valid_refs_for_data_attr="${valid_refs_for_data_attr};${trimmed_id_val}"
                    fi
                fi
            done

            if [[ $actual_valid_entry_count -gt 0 ]]; then
                references_content="<a href=\"#\" class=\"references-btn\" data-refs=\"${valid_refs_for_data_attr}\">References (${actual_valid_entry_count})</a>"
            fi
        fi
        
        cat <<EOL
                    <tr>
                        <td>${counter}</td>
                        <td>${Start}</td>
                        <td>${Ref}</td>
                        <td>${Alt}</td>
                        <td>${Gene_symbol}</td>
                        <td>${Functional_effect_general}</td>
                        <td>${MITOMAP_Disease_Clinical_info}</td>
                        <td>${MITOMAP_Disease_Status}</td>
                        <td>
                            ${references_content}
                        </td>
                        <td><a href="#" class="btn btn-outline-primary btn-sm variant-details-btn" data-id="${counter}" data-position="${Start}" data-end="${End}" data-ref="${Ref}" data-alt="${Alt}" data-gene="${Gene_symbol}" data-effect="${Functional_effect_general}" data-polyphen2="${PolyPhen2}" data-sift="${SIFT}" data-molecule="${Molecule_type}" data-annotation="${Extended_annotation}" data-siftfour="${SIFT4G}" data-vest="${VEST}" data-mitoclass="${Mitoclass1}" data-snpdryad="${SNPDryad}" data-mutationtaster="${MutationTaster}" data-fathmm="${FATHMM}" data-alphamissense="${AlphaMissense}" data-provean="${PROVEAN}" data-mutationassessor="${MutationAssessor}" data-efinsp="${EFIN_SP}" data-efinhd="${EFIN_HD}" data-mlc="${MLC}" data-panther="${PANTHER}" data-phdsnp="${PhD_SNP}" data-apogee1="${APOGEE1}" data-apogee2="${APOGEE2}" data-carol="${CAROL}" data-cadd="${CADD}" data-condel="${Condel}" data-covecwmv="${COVEC_WMV}" data-mtoolbox="${MtoolBox}" data-deogen2="${DEOGEN2}" data-metasnp="${Meta_SNP}" data-mitomapdisease="${MITOMAP_Disease_Status}" data-sifttransf="${SIFT_transf}" data-polyphen2sf="${PolyPhen2_transf}" data-mutationassessortransf="${MutationAssessor_transf}" data-chasm="${CHASM}">Variant Details</a></td>
                    </tr>
EOL
     # Increment the counter for each row
        ((counter++))
    done
else
    echo "<tr><td colspan='9'>No data available for sample ${SAMPLE}</td></tr>"
fi


   cat <<EOL
                    </tbody>
                    <tfoot>
                        <tr>
                    <th>No.</th>
                    <th>Position</th>
                    <th>Ref</th>
                    <th>Alt</th>
                    <th>Gene Symbol</th>
                    <th>Functional Effect</th>
                    <th>MITOMAP Disease Clinical Information</th>
                    <th>MITOMAP Disease Clinical Status</th>
                    <th>References</th>
                    <th>Details</th>
                </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>

    <!-- Modal for displaying variant details -->
    <div class="modal fade" id="variantModal" tabindex="-1" aria-labelledby="variantModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="variantModalLabel">Variant Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                <div class="modal-section-info">
                        <h5>Variant Information</h5>
                        <table class="table table-bordered">
                            <tr>
                                <td><strong>Start:</strong></td>
                                <td id="modal-Start"></td>
                                <td><strong>End:</strong></td>
                                <td id="modal-End"></td>
                                <td><strong>Ref:</strong></td>
                                <td id="modal-Ref"></td>
                                <td><strong>Alt:</strong></td>
                                <td id="modal-Alt"></td>
                            </tr>
                            <tr>
                            <td><strong>Molecule type:</strong></td>
                                <td id="modal-Molecule_type"></td>
                                <td><strong>Gene:</strong></td>
                                <td id="modal-Gene_symbol"></td>
                                <td><strong>Annotation:</strong></td>
                                <td id="modal-Extended_annotation" colspan="3"></td>
                            </tr>
                        </table>
                    </div>
                    <div class="modal-section">
                        <h5>Pathogenicity Predictors</h5>
                        <table class="table table-bordered">
                            <tr>
                                <td><strong>PolyPhen2:</strong></td>
                                <td id="modal-polyphen2"></td>
                                <td><strong>SIFT:</strong></td>
                                <td id="modal-sift"></td>
                                <td><strong>SIFT4G:</strong></td>
                                <td id="modal-siftfour"></td>
                                <td><strong>VEST:</strong></td>
                                <td id="modal-vest"></td>
                            </tr>
                            <tr>
                            <td><strong>Mitoclass1:</strong></td>
                                <td id="modal-mitoclass"></td>
                                <td><strong>SNPDryad:</strong></td>
                                <td id="modal-snpdryad"></td>
                                <td><strong>MutationTaster:</strong></td>
                                <td id="modal-mutationtaster"></td>
                                <td><strong>FATHMM:</strong></td>
                                <td id="modal-fathmm"></td>
                            </tr>
                            <tr>
                            <td><strong>AlphaMissense:</strong></td>
                                <td id="modal-alphamissense"></td>
                                <td><strong>PROVEAN:</strong></td>
                                <td id="modal-provean"></td>
                                <td><strong>MutationAssessor:</strong></td>
                                <td id="modal-mutationassessor"></td>
                                <td><strong>MLC:</strong></td>
                                <td id="modal-mlc"></td>
                            </tr>
                            <tr>
                            <td><strong>PANTHER:</strong></td>
                                <td id="modal-panther"></td>
                                <td><strong>PhD-SNP:</strong></td>
                                <td id="modal-phdsnp"></td>
                                <td><strong>APOGEE1:</strong></td>
                                <td id="modal-apogee1"></td>
                                <td><strong>APOGEE2:</strong></td>
                                <td id="modal-apogee2"></td>
                            </tr>
                            <tr>
                            <td><strong>CAROL:</strong></td>
                                <td id="modal-carol"></td>
                                <td><strong>MToolBox:</strong></td>
                                <td id="modal-mtoolbox"></td>
                                <td><strong>DEOGEN2:</strong></td>
                                <td id="modal-deogen2"></td>
                                <td><strong>MITOMAP Disease Status:</strong></td>
                                <td id="modal-mitomapdisease" class="text-primary"></td>
                            </tr>
                        </table>
                    </div>
                    <div class="modal-section warning">
                        <h5>Pathogenicity Meta-Predictors</h5>
                        <table class="table table-bordered">
                            <tr>
                            <td><strong>CADD:</strong></td>
                                <td id="modal-cadd"></td>
                                <td><strong>Condel:</strong></td>
                                <td id="modal-condel"></td>
                                <td><strong>EFIN_SP:</strong></td>
                                <td id="modal-efinsp"></td>
                            </tr>
                            <tr>
                             <td><strong>EFIN_HD:</strong></td>
                                <td id="modal-efinhd"></td>
                                <td><strong>COVEC_WMV:</strong></td>
                                <td id="modal-covecwmv"></td>
                                <td><strong>Meta SNP:</strong></td>
                                <td id="modal-metasnp"></td>
                            </tr>
                        </table>
                    </div>
                    <div class="modal-section danger">
                        <h5>Cancer-Specific Predictors</h5>
                        <table class="table table-bordered">
                            <tr>
                            <td><strong>CHASM:</strong></td>
                                <td id="modal-chasm"></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

<!-- Add this after the variant modal -->
<div class="modal fade" id="referencesModal" tabindex="-1" aria-labelledby="referencesModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="referencesModalLabel">References</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th style="width: 5%;">No.</th>
                            <th style="width: 10%;">PubMed ID</th>
                            <th style="width: 30%;">Title</th>
                            <th style="width: 25%;">Authors</th>
                            <th style="width: 20%;">Journal</th>
                            <th style="width: 5%;">Year</th>
                            <th style="width: 10%;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="references-table-body">
                        <tr>
                            <td colspan="6" class="text-center">Loading references...</td> 
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer d-flex justify-content-between align-items-center">
                <div id="references-pagination-container">
                    <nav aria-label="References Page Navigation">
                        <ul class="pagination pagination-sm mb-0" id="references-page-list">
                            <!-- Page numbers will be dynamically inserted here by JavaScript -->
                        </ul>
                    </nav>
                </div>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
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

// Helper function to process promises in batches
async function processInBatches(items, batchSize, delayBetweenBatches, itemProcessor) {
    let results = [];
    for (let i = 0; i < items.length; i += batchSize) {
        const batchItems = items.slice(i, i + batchSize);
        const batchPromises = batchItems.map(item => itemProcessor(item));
        const batchResults = await Promise.all(batchPromises);
        results = results.concat(batchResults);
        if (i + batchSize < items.length) {
            await new Promise(resolve => setTimeout(resolve, delayBetweenBatches));
        }
    }
    return results;
}

// --- START: New variables for pagination ---
let allReferencesData = []; // To store all fetched PubMed IDs for the current variant
let currentPage = 1;
const itemsPerPage = 10; // Display 10 references per page
// --- END: New variables for pagination ---


// Function to get the severity color based on the value
function getSeverityColor(value) {
    // Ensure the value is a string, replace '.' with 'N/A', and convert to lowercase
    const stringValue = (value || '').toString().replace('.', 'N/A').toLowerCase();

    switch (stringValue) {
        case 'benign':
            return '#8BC34A'; // Light Green
        case 'likely benign':
        case 'likely-benign':
        case 'likely_benign':
            return '#A5D6A7'; // Light Green
        case 'neutral':
            return '#DCE775'; // Pale Green
        case 'tolerated':
            return '#C8E6C9'; // Pale Green
        case 'unknown':
        case 'n/a': // Handle N/A case
            return '#BDBDBD'; // Light Gray for N/A
        case 'vus-':
        case 'vus':
        case 'vus+':
            return '#FFEB3B'; // Light Yellow
        case 'uncertain significance':
        case 'uncertain_significance':
        case 'uncertain-significance':
        case 'ambiguous':
            return '#FFF176'; // Light Yellow
        case 'polymorphism':
            return '#C8E6C9'; // Pale green
        case 'possibly damaging':
        case 'possibly_damaging':
        case 'possibly-damaging':
            return '#FFA726'; // Orange
        case 'probably damaging':
        case 'probably_damaging':
        case 'probably-damaging':
            return '#FB8C00'; // Dark Orange
        case 'likely pathogenic':
        case 'likely_pathogenic':
        case 'likely-pathogenic':
            return '#EF5350'; // Light Red
        case 'damaging':
        case 'disease':
        case 'deleterious':
        case 'pathogenic':
            return '#D32F2F'; // Red
        case 'high impact':
        case 'high-impact':
        case 'high_impact':
        case 'high':
            return '#B71C1C'; // Dark Red
        case 'medium impact':
        case 'medium-impact':
        case 'medium_impact':
        case 'medium':
            return '#FFC107'; // Amber
        case 'low impact':
        case 'low-impact':
        case 'low_impact':
        case 'low':
            return '#FFEB3B'; // Yellow
        default:
            return '#000000'; // Default to black for any undefined values
    }
}


        // Sidebar toggle functionality
        document.getElementById('sidebarToggle').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            sidebar.classList.toggle('hide');
            mainContent.classList.toggle('collapsed');
        });

       \$(document).ready(function() {
        // Initialize the DataTable and set it as the default view
        const table = new DataTable('#example', {
            pageLength: 30,
            dom: 'Bfrtip',
            buttons: ['copy', 'excel', 'pdf', 'print', 'colvis'],
            language: {
                search: 'Search:',
                searchPlaceholder: 'Search variants'
            }
        });

       // Default view: Show the DataTable when the page loads
    \$('#example').show();

\$(document).on('click', '.references-btn', async function(e) {
    e.preventDefault();
    const refsRaw = \$(this).data('refs');
    if (refsRaw !== undefined && refsRaw !== null) {
        const refsString = String(refsRaw);
        // Store all potential references globally for this modal session
        allReferencesData = refsString.split(';').map(ref => ref.trim()).filter(ref => ref && /^\d+$/.test(ref));
        currentPage = 1; // Reset to first page

        \$('#referencesModalLabel').text(\`References (Total: \${allReferencesData.length})\`);
        \$('#referencesModal').modal('show');
        await displayReferencesPage(currentPage); // Load the first page
    }
});

async function displayReferencesPage(page) {
    currentPage = page;
    const startIndex = (page - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const pageReferences = allReferencesData.slice(startIndex, endIndex);

    \$('#references-table-body').html('<tr><td colspan="7" class="text-center">Loading references...</td></tr>'); // Adjusted colspan

    if (pageReferences.length === 0 && allReferencesData.length > 0) {
         \$('#references-table-body').html('<tr><td colspan="7" class="text-center">No more references on this page.</td></tr>'); // Adjusted colspan
         updatePaginationControls();
         return;
    }
    if (pageReferences.length === 0 && allReferencesData.length === 0) {
        \$('#references-table-body').html('<tr><td colspan="7" class="text-center">No references to display.</td></tr>'); // Adjusted colspan
        updatePaginationControls();
        return;
    }


    const batchSize = 5; // Can be same as itemsPerPage or different if needed for fetching
    const delayBetweenBatches = 1000;

    const fetchPubMedDetails = (trimmedRef) => {
        const backendUrl = '/php_backend/fetch_pubmed.php?id=' + encodeURIComponent(trimmedRef);
        return fetch(backendUrl)
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        let errorMsg = 'Network response was not ok: ' + response.status;
                        try {
                            const jsonError = JSON.parse(text);
                            if (jsonError && jsonError.error) {
                                errorMsg += ' - ' + jsonError.error;
                            } else if (text) {
                                errorMsg += ' - Server: ' + text.substring(0, 150);
                            }
                        } catch (parseError) {
                            if (text) {
                                errorMsg += ' - Server: ' + text.substring(0, 150);
                            }
                        }
                        throw new Error(errorMsg);
                    });
                }
                return response.json();
            })
            .then(responseData => {
                if (responseData.error) {
                    throw new Error(responseData.error);
                }
                const pubmedEntry = responseData.data && responseData.data.result ? responseData.data.result[trimmedRef] : null;
                const metadata = responseData.metadata || {};
                let title = 'Title not available';
                let year = 'N/A';
                let authorsList = 'Authors not available';
                let journalName = 'Journal not available';

                if (pubmedEntry) {
                    title = pubmedEntry.title || 'Title not available';
                    if (pubmedEntry.pubdate) {
                        const yearMatch = pubmedEntry.pubdate.match(/^(\d{4})/);
                        year = yearMatch ? yearMatch[1] : (pubmedEntry.epubdate ? pubmedEntry.epubdate.match(/^(\d{4})/)?.[1] || 'N/A' : 'N/A');
                    } else if (pubmedEntry.epubdate) {
                        const yearMatch = pubmedEntry.epubdate.match(/^(\d{4})/);
                        year = yearMatch ? yearMatch[1] : 'N/A';
                    }
                    if (pubmedEntry.authors && Array.isArray(pubmedEntry.authors) && pubmedEntry.authors.length > 0) {
                        authorsList = pubmedEntry.authors.map(author => author.name).join(', ');
                    }
                    journalName = pubmedEntry.fulljournalname || pubmedEntry.source || 'Journal not available';
                }
                return {
                    id: trimmedRef,
                    title: title,
                    year: year,
                    authors: authorsList,
                    journal: journalName,
                    cached: metadata.cached || false
                };
            })
            .catch(error => {
                console.error('Error fetching details for ID:', trimmedRef, error);
                return {
                    id: trimmedRef,
                    title: 'Unable to fetch details: ' + error.message,
                    year: 'N/A',
                    authors: 'N/A',
                    journal: 'N/A',
                    cached: false
                };
            });
    };

     try {
        const results = await processInBatches(pageReferences, batchSize, delayBetweenBatches, fetchPubMedDetails);
        
        let tableContent = '';
        if (results.length === 0) {
            tableContent = '<tr><td colspan="7" class="text-center">No references to display for this page.</td></tr>'; // Adjusted colspan
        } else {
            results.forEach((result, index) => { // Added index parameter
                if (result) {
                    const rowNumber = startIndex + index + 1; // Calculate continuous row number
                    const cacheIndicator = result.cached ? ' <small class="text-muted">(cached)</small>' : '';
                    tableContent += '<tr>' +
                        '<td>' + rowNumber + '</td>' + // Added this cell for No.
                        '<td>' + result.id + '</td>' +
                        '<td>' + result.title + cacheIndicator + '</td>' +
                        '<td>' + (result.authors || 'N/A') + '</td>' +
                        '<td>' + (result.journal || 'N/A') + '</td>' +
                        '<td>' + (result.year || 'N/A') + '</td>' +
                        '<td>' +
                        '<a href="https://pubmed.ncbi.nlm.nih.gov/' + result.id + '/" ' +
                        'target="_blank" ' +
                        'class="btn btn-sm btn-outline-primary">' +
                        'View on PubMed</a>' +
                        '</td>' +
                        '</tr>';
                }
            });
        }
        \$('#references-table-body').html(tableContent);
    } catch (error) {
        console.error('[displayReferencesPage] Error processing references in batches for page:', page, error);
        \$('#references-table-body').html('<tr><td colspan="7" class="text-center text-danger">Error loading references: ' + error.message + '</td></tr>'); // Adjusted colspan
    }
    updatePaginationControls();
}

// Helper function to add a pagination item (number or ellipsis)
function addPaginationItem(pageList, options) {
    const { pageNumber, text, isActive = false, isDisabled = false, isEllipsis = false } = options;
    const li = \$('<li>').addClass('page-item');
    if (isActive) li.addClass('active');
    if (isDisabled || isEllipsis) li.addClass('disabled');

    let itemElement;
    if (isEllipsis) {
        itemElement = \$('<span>').addClass('page-link').text('...');
    } else {
        itemElement = \$('<a>').addClass('page-link').attr('href', '#').text(text || pageNumber);
        if (!isDisabled) {
            itemElement.data('page', pageNumber);
        }
    }
    li.append(itemElement);
    pageList.append(li);
}

function updatePaginationControls() {
    const pageList = \$('#references-page-list');
    pageList.empty(); // Clear previous pagination items

    const totalPages = Math.ceil(allReferencesData.length / itemsPerPage);

    if (totalPages <= 1) {
        \$('#references-pagination-container').hide(); // Hide pagination if not needed
        return;
    }
    \$('#references-pagination-container').show();

    const pagesToDisplay = [];
    const sideBuffer = 1; // Number of pages to show on each side of the current page (e.g., C-1, C, C+1)
    const maxVisibleButtons = 7; // Approximate max items in pagination (e.g., 1 ... C-1 C C+1 ... N)

    // Always add the first page
    pagesToDisplay.push(1);

    if (totalPages <= maxVisibleButtons) {
        // If total pages are few, show all of them
        for (let i = 2; i <= totalPages; i++) {
            pagesToDisplay.push(i);
        }
    } else {
        // Determine if left ellipsis is needed
        // Show ellipsis if current page is far enough from the start (e.g., after page 1 and before current window)
        if (currentPage > sideBuffer + 2) { // e.g. 1 ... C-1, C, C+1. Current > 1(first) + 1(buffer for ellipsis) + sideBuffer
            pagesToDisplay.push('...');
        }

        // Window around current page
        const windowStart = Math.max(2, currentPage - sideBuffer);
        const windowEnd = Math.min(totalPages - 1, currentPage + sideBuffer);

        for (let i = windowStart; i <= windowEnd; i++) {
            if (!pagesToDisplay.includes(i)) {
                 pagesToDisplay.push(i);
            }
        }

        // Determine if right ellipsis is needed
        // Show ellipsis if current page is far enough from the end
        if (currentPage < totalPages - (sideBuffer + 1)) {
            if (pagesToDisplay[pagesToDisplay.length -1] !== '...') { // Avoid double ellipsis
                 pagesToDisplay.push('...');
            }
        }
        
        // Always add the last page (if not already included)
        if (!pagesToDisplay.includes(totalPages)) {
            pagesToDisplay.push(totalPages);
        }
    }
    
    // Render the page items
    let lastPushed = null;
    for (const p of pagesToDisplay) {
        if (p === '...' && lastPushed === '...') continue; // Avoid consecutive ellipses

        if (p === '...') {
            addPaginationItem(pageList, { isEllipsis: true });
        } else {
            addPaginationItem(pageList, { pageNumber: p, isActive: currentPage === p });
        }
        lastPushed = p;
    }
}

// Add new click handler for page number links
\$(document).on('click', '#references-page-list .page-link', function(e) {
    e.preventDefault();
    if (\$(this).parent().hasClass('disabled') || \$(this).parent().hasClass('active')) {
        return; // Do nothing if the item is disabled or already active
    }
    const pageToLoad = parseInt(\$(this).data('page'));
    if (!isNaN(pageToLoad) && pageToLoad !== currentPage) {
        displayReferencesPage(pageToLoad);
    }
});


// When the modal is hidden, clear the table and reset pagination (optional, but good practice)
\$('#referencesModal').on('hidden.bs.modal', function () {
    \$('#references-table-body').html('<tr><td colspan="6" class="text-center">Loading references...</td></tr>');
    allReferencesData = [];
    currentPage = 1;
    updatePaginationControls();
    \$('#referencesModalLabel').text('References');
});


    // Load HTML into iframe when clicking load-file
\$('.load-file').on('click', function (e) {
    e.preventDefault();
    const fileToLoad = \$(this).data('file');
    const isVariants = \$(this).data('type') === 'variants'; // Check if Variants is clicked by using data-type
    if (isVariants) {
        // Show the DataTable and clear any iframe content
        \$('#example').show();
        \$('#mainContent iframe').remove();  // Remove any iframe if it exists
        // Force redraw of DataTable
        if ($.fn.DataTable.isDataTable('#example')) {
            \$('#example').DataTable().columns.adjust().draw();
        } else {
        console.error('DataTable not initialized');
        \$('#example').html('<p>Error loading variants. Please try refreshing the page.</p>');
    }
    } else {
        // For other links, load the content into the iframe
        \$('#mainContent').html('<iframe src="' + fileToLoad + '" width="100%" height="100%" frameborder="0" style="min-height: 90vh;"></iframe>');
        
        // Hide the DataTable when the iframe is being shown
        \$('#example').hide();
    }
});

    });

// Function to capitalize the first letter
const capitalizeFirstLetter = (value) => {
    if (typeof value === 'undefined' || value === null || value === '') {
        return "N/A";  // Return "N/A" if the value is undefined, null, or empty
    }
    const str = value.toString();
    return str.charAt(0).toUpperCase() + str.slice(1);
}

\$('#example').on('click', '.variant-details-btn', function() {
    const variantData = {
    Start: capitalizeFirstLetter(\$(this).data('position') === "." ? "N/A" : \$(this).data('position')),
    End: capitalizeFirstLetter(\$(this).data('end') === "." ? "N/A" : \$(this).data('end')),
    Ref: capitalizeFirstLetter(\$(this).data('ref') === "." ? "N/A" : \$(this).data('ref')),
    Alt: capitalizeFirstLetter(\$(this).data('alt') === "." ? "N/A" : \$(this).data('alt')),
    Molecule_type: capitalizeFirstLetter(\$(this).data('molecule') === "." ? "N/A" : \$(this).data('molecule')),
    Gene_symbol: \$(this).data('gene') === "." ? "N/A" : \$(this).data('gene'),
    Extended_annotation: capitalizeFirstLetter(\$(this).data('annotation') === "." ? "N/A" : \$(this).data('annotation')),
    polyphen2: capitalizeFirstLetter(\$(this).data('polyphen2') === "." ? "N/A" : \$(this).data('polyphen2')),
    sift: capitalizeFirstLetter(\$(this).data('sift') === "." ? "N/A" : \$(this).data('sift')),
    siftfour: capitalizeFirstLetter(\$(this).data('siftfour') === "." ? "N/A" : \$(this).data('siftfour')),
    vest: capitalizeFirstLetter(\$(this).data('vest') === "." ? "N/A" : \$(this).data('vest')),
    mitoclass: capitalizeFirstLetter(\$(this).data('mitoclass') === "." ? "N/A" : \$(this).data('mitoclass')),
    snpdryad: capitalizeFirstLetter(\$(this).data('snpdryad') === "." ? "N/A" : \$(this).data('snpdryad')),
    mutationtaster: capitalizeFirstLetter(\$(this).data('mutationtaster') === "." ? "N/A" : \$(this).data('mutationtaster')),
    fathmm: capitalizeFirstLetter(\$(this).data('fathmm') === "." ? "N/A" : \$(this).data('fathmm')),
    alphamissense: capitalizeFirstLetter(\$(this).data('alphamissense') === "." ? "N/A" : \$(this).data('alphamissense')),
    mutationassessor: capitalizeFirstLetter(\$(this).data('mutationassessor') === "." ? "N/A" : \$(this).data('mutationassessor')),
    efinsp: capitalizeFirstLetter(\$(this).data('efinsp') === "." ? "N/A" : \$(this).data('efinsp')),
    efinhd: capitalizeFirstLetter(\$(this).data('efinhd') === "." ? "N/A" : \$(this).data('efinhd')),
    mlc: capitalizeFirstLetter(\$(this).data('mlc') === "." ? "N/A" : \$(this).data('mlc')),
    apogee2: capitalizeFirstLetter(\$(this).data('apogee2') === "." ? "N/A" : \$(this).data('apogee2')),
    condel: capitalizeFirstLetter(\$(this).data('condel') === "." ? "N/A" : \$(this).data('condel')),
    covecwmv: capitalizeFirstLetter(\$(this).data('covecwmv') === "." ? "N/A" : \$(this).data('covecwmv')),
    mtoolbox: capitalizeFirstLetter(\$(this).data('mtoolbox') === "." ? "N/A" : \$(this).data('mtoolbox')),
    mitomapdisease: capitalizeFirstLetter(\$(this).data('mitomapdisease') === "." ? "N/A" : \$(this).data('mitomapdisease')),
    chasm: capitalizeFirstLetter(\$(this).data('chasm') === "." ? "N/A" : \$(this).data('chasm')),
    panther: capitalizeFirstLetter(\$(this).data('panther') === "." ? "N/A" : \$(this).data('panther')),
    phdsnp: capitalizeFirstLetter(\$(this).data('phdsnp') === "." ? "N/A" : \$(this).data('phdsnp')),
    cadd: capitalizeFirstLetter(\$(this).data('cadd') === "." ? "N/A" : \$(this).data('cadd')),
    provean: capitalizeFirstLetter(\$(this).data('provean') === "." ? "N/A" : \$(this).data('provean')),
    apogee1: capitalizeFirstLetter(\$(this).data('apogee1') === "." ? "N/A" : \$(this).data('apogee1')),
    carol: capitalizeFirstLetter(\$(this).data('carol') === "." ? "N/A" : \$(this).data('carol')),
    deogen2: capitalizeFirstLetter(\$(this).data('deogen2') === "." ? "N/A" : \$(this).data('deogen2')),
    metasnp: capitalizeFirstLetter(\$(this).data('metasnp') === "." ? "N/A" : \$(this).data('metasnp')),
    polyphen2transf: capitalizeFirstLetter(\$(this).data('polyphen2transf') === "." ? "N/A" : \$(this).data('polyphen2transf')),
    siftTransf: capitalizeFirstLetter(\$(this).data('sifttransf') === "." ? "N/A" : \$(this).data('sifttransf'))
};


                // Populate the modal with data and apply color
            \$('#modal-Start').text(variantData.Start || 'N/A').css('color', getSeverityColor(variantData.Start || ''));
            \$('#modal-End').text(variantData.End || 'N/A').css('color', getSeverityColor(variantData.End || ''));
            \$('#modal-Ref').text(variantData.Ref || 'N/A').css('color', getSeverityColor(variantData.Ref || ''));
            \$('#modal-Alt').text(variantData.Alt || 'N/A').css('color', getSeverityColor(variantData.Alt || ''));
            \$('#modal-Molecule_type').text(variantData.Molecule_type || 'N/A').css('color', getSeverityColor(variantData.Molecule_type || ''));
            \$('#modal-Gene_symbol').text(variantData.Gene_symbol || 'N/A').css('color', getSeverityColor(variantData.Gene_symbol || ''));
            \$('#modal-Extended_annotation').text(variantData.Extended_annotation || 'N/A').css('color', getSeverityColor(variantData.Extended_annotation || ''));
            \$('#modal-polyphen2').text(variantData.polyphen2 || 'N/A').css('color', getSeverityColor(variantData.polyphen2 || ''));
            \$('#modal-sift').text(variantData.sift || 'N/A').css('color', getSeverityColor(variantData.sift || ''));
            \$('#modal-siftfour').text(variantData.siftfour || 'N/A').css('color', getSeverityColor(variantData.siftfour || ''));
            \$('#modal-vest').text(variantData.vest || 'N/A').css('color', getSeverityColor(variantData.vest || ''));
            \$('#modal-mitoclass').text(variantData.mitoclass || 'N/A').css('color', getSeverityColor(variantData.mitoclass || ''));
            \$('#modal-snpdryad').text(variantData.snpdryad || 'N/A').css('color', getSeverityColor(variantData.snpdryad || ''));
            \$('#modal-mutationtaster').text(variantData.mutationtaster || 'N/A').css('color', getSeverityColor(variantData.mutationtaster || ''));
            \$('#modal-fathmm').text(variantData.fathmm || 'N/A').css('color', getSeverityColor(variantData.fathmm || ''));
            \$('#modal-alphamissense').text(variantData.alphamissense || 'N/A').css('color', getSeverityColor(variantData.alphamissense || ''));
            \$('#modal-mutationassessor').text(variantData.mutationassessor || 'N/A').css('color', getSeverityColor(variantData.mutationassessor || ''));
            \$('#modal-efinsp').text(variantData.efinsp || 'N/A').css('color', getSeverityColor(variantData.efinsp || ''));
            \$('#modal-efinhd').text(variantData.efinhd || 'N/A').css('color', getSeverityColor(variantData.efinhd || ''));
            \$('#modal-mlc').text(variantData.mlc || 'N/A').css('color', getSeverityColor(variantData.mlc || ''));
            \$('#modal-apogee2').text(variantData.apogee2 || 'N/A').css('color', getSeverityColor(variantData.apogee2 || ''));
            \$('#modal-condel').text(variantData.condel || 'N/A').css('color', getSeverityColor(variantData.condel || ''));
            \$('#modal-covecwmv').text(variantData.covecwmv || 'N/A').css('color', getSeverityColor(variantData.covecwmv || ''));
            \$('#modal-mtoolbox').text(variantData.mtoolbox || 'N/A').css('color', getSeverityColor(variantData.mtoolbox || ''));
            \$('#modal-mitomapdisease').text(variantData.mitomapdisease || 'N/A').css('color', getSeverityColor(variantData.mitomapdisease || ''));
            \$('#modal-chasm').text(variantData.chasm || 'N/A').css('color', getSeverityColor(variantData.chasm || ''));
            \$('#modal-panther').text(variantData.panther || 'N/A').css('color', getSeverityColor(variantData.panther || ''));
            \$('#modal-phdsnp').text(variantData.phdsnp || 'N/A').css('color', getSeverityColor(variantData.phdsnp || ''));
            \$('#modal-cadd').text(variantData.cadd || 'N/A').css('color', getSeverityColor(variantData.cadd || ''));
            \$('#modal-provean').text(variantData.provean || 'N/A').css('color', getSeverityColor(variantData.provean || ''));
            \$('#modal-apogee1').text(variantData.apogee1 || 'N/A').css('color', getSeverityColor(variantData.apogee1 || ''));
            \$('#modal-carol').text(variantData.carol || 'N/A').css('color', getSeverityColor(variantData.carol || ''));
            \$('#modal-deogen2').text(variantData.deogen2 || 'N/A').css('color', getSeverityColor(variantData.deogen2 || ''));
            \$('#modal-metasnp').text(variantData.metasnp || 'N/A').css('color', getSeverityColor(variantData.metasnp || ''));
            \$('#modal-polyphen2transf').text(variantData.polyphen2transf || 'N/A').css('color', getSeverityColor(variantData.polyphen2transf || ''));
            \$('#modal-sifttransf').text(variantData.sifttransf || 'N/A').css('color', getSeverityColor(variantData.sifttransf || ''));

                // Show the modal
                \$('#variantModal').modal('show');
            });
    </script>
</body>
</html>
EOL
