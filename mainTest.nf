#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SOMALIER_EXTRACT } from './somalierextract-module.nf'
include { SOMALIER_RELATE } from './somalierrelate-module.nf'

input_sample_ch = Channel
.fromPath( params.inputCsv )
.splitCsv( header:true )
.map { row -> tuple( [id: row.patient], file(row.bam), file(row.bai) ) }
//.view ()

fasta       = file(params.test_data['homo_sapiens']['genome']['genome_21_fasta'], checkIfExists: true)

fasta_fai   = file(params.test_data['homo_sapiens']['genome']['genome_21_fasta_fai'], checkIfExists: true)

sites       = file(params.sites, checkIfExists: true)

cohort      = "all"

workflow SOMALIER {

    take:
        input_sample_ch
        fasta
        fasta_fai
        sites
        
    /*input = [
        [ id:'test2', single_end:false ], // meta map
        file(params.test_data['homo_sapiens']['illumina']['test2_paired_end_markduplicates_sorted_bam'], checkIfExists: true),
        file(params.test_data['homo_sapiens']['illumina']['test2_paired_end_markduplicates_sorted_bam_bai'], checkIfExists: true)
    ]*/
    
    main:
        SOMALIER_EXTRACT ( input_sample_ch, fasta, fasta_fai, sites )
        //SOMALIER_RELATE ( SOMALIER_EXTRACT.extract[1].collect(), cohort )

    emit:
        extract = SOMALIER_EXTRACT.out[0]

}

workflow {
    SOMALIER( input_sample_ch, fasta, fasta_fai, sites )
    SOMALIER_RELATE (SOMALIER.extract[1].collect(), cohort)
}