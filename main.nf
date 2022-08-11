#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SOMALIER_EXTRACT } from './somalierextract-module.nf'
include { SOMALIER_RELATE } from './somalierrelate-module.nf'

input_sample = Channel
.fromPath( params.inputCsv )
.splitCsv( header:true )
.map { row -> tuple( [id: row.patient], file(row.bam), file(row.bai) ) }
//.view ()


fasta       = file(params.test_data['homo_sapiens']['genome']['genome_21_fasta'], checkIfExists: true)

fasta_fai   = file(params.test_data['homo_sapiens']['genome']['genome_21_fasta_fai'], checkIfExists: true)

sites       = file(params.sites, checkIfExists: true)

cohort      = "all"

workflow  {
    
    /*input = [
        [ id:'test2', single_end:false ], // meta map
        file(params.test_data['homo_sapiens']['illumina']['test2_paired_end_markduplicates_sorted_bam'], checkIfExists: true),
        file(params.test_data['homo_sapiens']['illumina']['test2_paired_end_markduplicates_sorted_bam_bai'], checkIfExists: true)
    ]*/

    SOMALIER_EXTRACT ( input_sample, fasta, fasta_fai, sites )
    //SOMALIER_RELATE (SOMALIER_EXTRACT.out[0].collect { it[1] }, cohort)
    SOMALIER_RELATE (SOMALIER_EXTRACT.out.extract.collect { it[1] }, cohort)
}
