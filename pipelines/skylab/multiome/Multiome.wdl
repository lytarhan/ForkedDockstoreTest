version 1.0

import "../../../pipelines/skylab/multiome/atac.wdl" as atac
import "../../../pipelines/skylab/optimus/Optimus.wdl" as optimus

workflow Multiome {
    String pipeline_version = "1.0.1"

    input {
        String input_id

        # Optimus Inputs
        String counting_mode = "sn_rna"
        Array[File] gex_r1_fastq
        Array[File] gex_r2_fastq
        Array[File]? gex_i1_fastq        
        File tar_star_reference
        File annotations_gtf
        File ref_genome_fasta
        File? mt_genes
        Int tenx_chemistry_version = 3
        Int emptydrops_lower = 100
        Boolean force_no_check = false
        Boolean ignore_r1_read_length = false
        String star_strand_mode = "Forward"
        Boolean count_exons = false
        File gex_whitelist = "gs://broad-gotc-test-storage/Multiome/input/737K-arc-v1_gex.txt"
        String? mt_sequence

        # ATAC inputs
        # Array of input fastq files
        Array[File] atac_r1_fastq
        Array[File] atac_r2_fastq
        Array[File] atac_r3_fastq
        # BWA input
        File tar_bwa_reference
        File chrom_sizes
        # Trimadapters input
        String adapter_seq_read1 = "GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG"
        String adapter_seq_read3 = "TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG"
        # Whitelist
        File atac_whitelist = "gs://broad-gotc-test-storage/Multiome/input/737K-arc-v1_atac.txt"

    }

    # Call the Optimus workflow
    call optimus.Optimus as Optimus {
        input:
            counting_mode = counting_mode,
            r1_fastq = gex_r1_fastq,
            r2_fastq = gex_r2_fastq,
            i1_fastq = gex_i1_fastq,
            input_id = input_id + "_gex",
            output_bam_basename = input_id + "_gex",
            tar_star_reference = tar_star_reference,
            annotations_gtf = annotations_gtf,
            ref_genome_fasta = ref_genome_fasta,
            mt_genes = mt_genes,
            tenx_chemistry_version = tenx_chemistry_version,
            whitelist = gex_whitelist,
            emptydrops_lower = emptydrops_lower,
            force_no_check = force_no_check,
            ignore_r1_read_length = ignore_r1_read_length,
            star_strand_mode = star_strand_mode,
            count_exons = count_exons,
            mt_sequence = mt_sequence
    }

    # Call the ATAC workflow
    call atac.ATAC as Atac {
        input:
            read1_fastq_gzipped = atac_r1_fastq,
            read2_fastq_gzipped = atac_r2_fastq,
            read3_fastq_gzipped = atac_r3_fastq,
            input_id = input_id + "_atac",
            tar_bwa_reference = tar_bwa_reference,
            annotations_gtf = annotations_gtf,
            chrom_sizes = chrom_sizes,
            whitelist = atac_whitelist,
            adapter_seq_read1 = adapter_seq_read1,
            adapter_seq_read3 = adapter_seq_read3
    }
    meta {
        allowNestedInputs: true
    }

    output {
        
        String multiome_pipeline_version_out = pipeline_version

        # atac outputs
        File bam_aligned_output_atac = Atac.bam_aligned_output
        File fragment_file_atac = Atac.fragment_file
        File snap_metrics_atac = Atac.snap_metrics

        # optimus outputs
        File genomic_reference_version_gex = Optimus.genomic_reference_version
        File bam_gex = Optimus.bam
        File matrix_gex = Optimus.matrix
        File matrix_row_index_gex = Optimus.matrix_row_index
        File matrix_col_index_gex = Optimus.matrix_col_index
        File cell_metrics_gex = Optimus.cell_metrics
        File gene_metrics_gex = Optimus.gene_metrics
        File? cell_calls_gex = Optimus.cell_calls
        File? picard_metrics_gex = Optimus.picard_metrics
        File h5ad_output_file_gex = Optimus.h5ad_output_file
    }
}
