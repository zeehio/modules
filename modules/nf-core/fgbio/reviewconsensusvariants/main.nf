process FGBIO_REVIEWCONSENSUSVARIANTS {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/87/87626ef674e2f19366ae6214575a114fe80ce598e796894820550731706a84be/data' :
        'community.wave.seqera.io/library/fgbio:2.4.0--913bad9d47ff8ddc' }"

    input:
    tuple val(meta), path(consensus_bam), path(consensus_bam_index), path(grouped_bam), path(grouped_bam_index), path(position_list)
    tuple val(meta2), path(fasta)
    tuple val(meta3), path(fasta_fai)
    tuple val(meta4), path(dict)

    output:
    tuple val(meta), path("*.grouped.bam")  , path("*.grouped.bai")  , emit: grouped_bam
    tuple val(meta), path("*.consensus.bam"), path("*.consensus.bai"), emit: consensus_bam
    tuple val(meta), path("*.txt")                                   , emit: summary
    path "versions.yml"                                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def mem_gb = 8
    if (!task.memory) {
        log.info '[fgbio FilterConsensusReads] Available memory not known - defaulting to 8GB. Specify process memory requirements to change this.'
    } else if (mem_gb > task.memory.giga) {
        if (task.memory.giga < 2) {
            mem_gb = 1
        } else {
            mem_gb = task.memory.giga - 1
        }
    }

    if ("${consensus_bam}" == "${prefix}.consensus.bam") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    if ("${consensus_bam}" == "${prefix}.grouped.bam")   error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    if ("${grouped_bam}"   == "${prefix}.consensus.bam") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    if ("${grouped_bam}"   == "${prefix}.grouped.bam")   error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"

    """
    fgbio \\
        -Xmx${mem_gb}g \\
        --tmp-dir=. \\
        ReviewConsensusVariants \\
        --input ${position_list} \\
        --consensus-bam ${consensus_bam} \\
        --grouped-bam ${grouped_bam} \\
        --output ${prefix} \\
        --ref ${fasta} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio --version)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    touch ${prefix}.grouped.bam
    touch ${prefix}.grouped.bai
    touch ${prefix}.consensus.bam
    touch ${prefix}.consensus.bai
    touch ${prefix}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio --version)
    END_VERSIONS
    """
}
