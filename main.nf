#!usr/bin/env nextflow
nextflow.enable.dsl=2

params.reads = "s3://ns-bioinformatics/inputs/dataset.fastq"

process FASTQC {

    container 'biocontainers/fastqc:v0.11.9_cv8'

    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    path reads

    output:
    tuple path ("*.html"), path ("*_fastqc.zip")

    script:
    """
    echo "Executing FASTQC on ${reads}"
    fastqc ${reads}
    echo "FASTQC completed for ${reads}"
    """
}

process MULTIQC {
    container 'multiqc/multiqc:dev'

    publishDir "${params.outdir}/multiqc", mode: 'copy'
    
    input:
    path fastqc_reports

    output:
    path "multiqc_report.html"
    path "multiqc_data"

    script:
    """
    echo "Running MultiQC on FASTQC reports"
    multiqc .
    echo "MultiQC report generated"
    """
}

workflow {
    reads_ch            = Channel.fromPath(params.reads)
    fastqc_reports_ch   = FASTQC(reads_ch)
    MULTIQC(fastqc_reports_ch.collect())
}