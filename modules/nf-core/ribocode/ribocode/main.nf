process RIBOCODE_RIBOCODE {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::ribocode=1.2.15" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ribocode:1.2.15--pyhfa5458b_0':
        'quay.io/biocontainers/ribocode:1.2.15--pyhfa5458b_0' }"

    input:
    tuple val(meta), path(bam)
    path annotation
    tuple val(meta3), path(config)

    output:
    path "annotation.txt"        , emit: orfs
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    RiboCode \\
        -a $annotation \\
        -c $config \\
        -o annotation \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RiboCode: \$(RiboCode --version 2>&1)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    
    """

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RiboCode: \$(RiboCode --version 2>&1)
    END_VERSIONS
    """
}
