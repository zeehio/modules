process BOWTIE_BUILD {
    tag "${meta.id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "nf-core/modules/bowtie:bowtie_build--df26d88a69745299"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path('bowtie') , emit: index
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p bowtie
    bowtie-build --threads $task.cpus $fasta bowtie/${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie: \$(echo \$(bowtie --version 2>&1) | sed 's/^.*bowtie-align-s version //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p bowtie
    touch bowtie/${prefix}.1.ebwt
    touch bowtie/${prefix}.2.ebwt
    touch bowtie/${prefix}.3.ebwt
    touch bowtie/${prefix}.4.ebwt
    touch bowtie/${prefix}.rev.1.ebwt
    touch bowtie/${prefix}.rev.2.ebwt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie: \$(echo \$(bowtie --version 2>&1) | sed 's/^.*bowtie-align-s version //; s/ .*\$//')
    END_VERSIONS
    """

}
