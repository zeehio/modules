#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RIBOCODE_PREPARE } from '../../../../../modules/nf-core/ribocode/prepare/main.nf'

workflow test_ribocode_prepare {
    
    genome_fasta = file(params.test_data['homo_sapiens']['genome']['genome_fasta'], checkIfExists: true)
    genome_gtf = file(params.test_data['homo_sapiens']['genome']['genome_gtf'], checkIfExists: true)

    RIBOCODE_PREPARE ( genome_fasta, genome_gtf )
}
