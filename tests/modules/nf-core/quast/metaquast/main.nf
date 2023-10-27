#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { QUAST_METAQUAST } from '../../../../../modules/nf-core/quast/metaquast/main.nf'

workflow test_quast_metaquast {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    QUAST_METAQUAST ( input )
}
