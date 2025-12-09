#!/bin/bash

# Get the sample parameter
SAMPLE="$2"
BASE_DIR="$1"
TARGET_DIR="$BASE_DIR/Results/ANNOVAR"
LOGO_DIR="$BASE_DIR/Software/scripts/Web"
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
        
        .content {
            padding: 20px;
        }
        
    </style>
</head>
<body>

EOL

cat <<EOL
    <!-- Main Container -->
    <div class="container-fluid">
        <div class="row">
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
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
EOL

counter=1
 # Read the input file for the sample and generate table rows
if [[ -f "$INPUT_FILE" ]]; then
    tail -n +2 "$INPUT_FILE" | while IFS=$'\t' read -r Chr Start End Ref Alt Molecule_type Gene_symbol Extended_annotation Gene_position Gene_start Gene_end Gene_strand Codon_substitution AA_ref AA_alt AA_pos Functional_effect_general Functional_effect_detailed OMIM_id HGVS HGNC_id Respiratory_Chain_complex Ensembl_protein_id Ensembl_transcript_id Ensembl_gene_id Uniprot_id Uniprot_name NCBI_gene_id NCBI_protein_id PolyPhen2 PolyPhen2_score SIFT SIFT_score SIFT4G SIFT4G_score VEST_pvalue VEST VEST_FDR Mitoclass1 SNPDryad_score SNPDryad MitoTip_count MutationTaster_score MutationTaster_converted_rankscore MutationTaster MutationTaster_model MutationTaster_AAE FATHMM_score FATHMM_converted_rankscore FATHMM AlphaMissense_score AlphaMissense CADD_score CADD_phred_score CADD PROVEAN_score PROVEAN MutationAssessor MutationAssessor_score EFIN_SP_score EFIN_SP EFIN_HD_score EFIN_HD MLC MLC_score PANTHER PANTHER_score PhD_SNP PhD_SNP_score APOGEE1_score APOGEE1 APOGEE2_score APOGEE2_probability APOGEE2 CAROL_score CAROL Condel_score Condel COVEC_WMV_score COVEC_WMV MtoolBox_DS MtoolBox DEOGEN2_score DEOGEN2_rankscore DEOGEN2 Meta_SNP Meta_SNP_score PhastCons_100V PhyloP_100V PhyloP_470Way PhastCons_470Way Clinvar_id Clinvar_ALLELEID Clinvar_CLNDISDB Clinvar_CLNDN Clinvar_CLNSIG MITOMAP_Disease_Hom_Het MITOMAP_Disease_Clinical_info MITOMAP_Disease_Status MITOMAP_General_GenBank_Freq MITOMAP_General_GenBank_Seqs MITOMAP_General_GenBank_Curated_refs MITOMAP_Variant_Class HelixMTdb_AC_hom HelixMTdb_AF_hom HelixMTdb_AC_het HelixMTdb_AF_het HelixMTdb_mean_ARF HelixMTdb_max_ARF ToMMo_54KJPN_AC ToMMo_54KJPN_AF ToMMo_54KJPN_AN Gnomad_AN Gnomad_AC_hom Gnomad_AC_het Gnomad_AF_hom Gnomad_AF_het Gnomad_filter GenBank_freq hpl_cnt_tot_frq Dloop_genbank_haplogroup_count COSMIC_90_id dbSNP_156 SIFT_transf_score SIFT_transf PolyPhen2_transf_score PolyPhen2_transf MutationAssessor_transf_score MutationAssessor_transf CHASM_pvalue CHASM_FDR CHASM CPD_Frequency CPD_AA_ref CPD_AA_alt CPD_Aln_pos CPD_RefSeq_protein_id CPD_Species_name CPD_Ncbi_taxon_id EVmutation Site_A_InterP Site_B_InterP Covariation_score_InterP Site_A_IntraP Site_B_IntraP Covariation_score_IntraP DDG_intra DDG_intra_interface DDG_inter homoplasmy heteroplasmy; do
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
                                <td id="modal-mitomapdisease"></td>
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
        // Function to get the severity color based on the value
        function getSeverityColor(value) {
            const stringValue = (value || '').toString().replace('.', 'N/A').toLowerCase();

            switch (stringValue) {
                case 'benign': return '#8BC34A';
                case 'likely benign':
                case 'likely-benign':
                case 'likely_benign': return '#A5D6A7';
                case 'neutral': return '#DCE775';
                case 'tolerated': return '#C8E6C9';
                case 'unknown':
                case 'n/a': return '#BDBDBD';
                case 'vus-':
                case 'vus':
                case 'vus+': return '#FFEB3B';
                case 'uncertain significance':
                case 'ambiguous': return '#FFF176';
                case 'polymorphism': return '#C8E6C9';
                case 'possibly damaging':
                case 'possibly_damaging':
                case 'possibly-damaging': return '#FFA726';
                case 'probably damaging':
                case 'probably_damaging':
                case 'probably-damaging': return '#FB8C00';
                case 'likely pathogenic':
                case 'likely_pathogenic':
                case 'likely-pathogenic': return '#EF5350';
                case 'damaging':
                case 'disease':
                case 'deleterious':
                case 'pathogenic': return '#D32F2F';
                case 'high impact':
                case 'high-impact':
                case 'high_impact':
                case 'high': return '#B71C1C';
                case 'medium impact':
                case 'medium-impact':
                case 'medium_impact':
                case 'medium': return '#FFC107';
                case 'low impact':
                case 'low-impact':
                case 'low_impact':
                case 'low': return '#FFEB3B';
                default: return '#000000';
            }
        }

\$(document).ready(function() {
        // Initialize the DataTable and set it as the default view
        const table = new DataTable('#example', {
            pageLength: 30,
            dom: 'Bfrtip',
            buttons: ['copy'],
            language: {
                search: 'Search:',
                searchPlaceholder: 'Search variants'
            }
        });
});
       // Default view: Show the DataTable when the page loads
    \$('#example').show();
    
        // Function to capitalize the first letter
        const capitalizeFirstLetter = (value) => {
            if (typeof value === 'undefined' || value === null || value === '') {
                return "N/A";
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
