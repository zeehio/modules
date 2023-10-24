#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RIBOCODE_METAPLOTS } from '../../../../../modules/nf-core/ribocode/metaplots/main.nf'
include { RIBOCODE_PREPARE } from '../../../../../modules/nf-core/ribocode/prepare/main.nf'
include { STAR_GENOMEGENERATE } from '../../../../../modules/nf-core/star/genomegenerate/main.nf'
include { STAR_ALIGN } from '../../../../../modules/nf-core/star/align/main.nf'



workflow test_ribocode_metaplots {
    
    input = [ [ id:'test', single_end:true ], // meta map
                [   file(params.test_data['homo_sapiens']['illumina']['test_rnaseq_1_fastq_gz'], checkIfExists: true),
            ]
    ]
    fasta = [
        [ id:'test_fasta' ], // meta map
        [ file(params.test_data['homo_sapiens']['genome']['genome_fasta'], checkIfExists: true) ]
    ]
    fai = [
        [ id:'test_fai' ], // meta map
        [ file(params.test_data['homo_sapiens']['genome']['genome_fasta_fai'], checkIfExists: true) ]
    ]
    gtf = [
        [ id:'test_fasta_gtf' ], // meta map
        [ file(params.test_data['homo_sapiens']['genome']['genome_gtf'], checkIfExists: true) ]
    ]
    star_ignore_sjdbgtf = false
    seq_platform = 'illumina'
    seq_center = false

    STAR_GENOMEGENERATE ( fasta, gtf )
    STAR_ALIGN ( input, STAR_GENOMEGENERATE.out.index, gtf, star_ignore_sjdbgtf, seq_platform, seq_center )
    // RIBOCODE_PREPARE( fasta[1], gtf[1] )
}
