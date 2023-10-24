process RIBOCODE_PREPARE {
    tag "$fasta"
    label 'process_single'

    conda "bioconda::ribocode=1.2.15"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ribocode:1.2.15--pyhfa5458b_0':
        'biocontainers/ribocode:1.2.15--pyhfa5458b_0' }"

    input:
    path fasta
    path gtf

    output:
    path "annotation"             , emit: annotation
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    """
    GTFupdate \\
        $gtf  \\
        > updated.gtf

    prepare_transcripts \\
        -g updated.gtf \\
        -f $fasta \\
        -o annotation

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RiboCode: \$(RiboCode --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    
    """
    mkdir  annotation

    touch annotaiton/transcripts_cds.txt
    touch annotaiton/transcripts_sequence.fa
    touch annotaiton/transcripts.pickle

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        RiboCode: \$(RiboCode --version 2>&1)
    END_VERSIONS
    """
}
