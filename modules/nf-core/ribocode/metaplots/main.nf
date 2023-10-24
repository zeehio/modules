process RIBOCODE_METAPLOTS {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::ribocode=1.2.15"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ribocode:1.2.15--pyhfa5458b_0':
        'biocontainers/ribocode:1.2.15--pyhfa5458b_0' }"

    input:
    tuple val(meta), path(bam)
    path annotation

    output:
    tuple val(meta), path("*config.txt")             , emit: config
    tuple val(meta), path("*.pdf")                  , emit: pdf
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    metaplots \\
        -a $annotation \\
        -r $bam \\
        -o report \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RiboCode: \$(RiboCode --version 2>&1)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch config.txt
    touch report.pdf
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RiboCode: \$(RiboCode --version 2>&1)
    END_VERSIONS
    """
}
