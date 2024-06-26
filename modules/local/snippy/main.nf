process SNIPPY {
    tag "${meta.id}"
    label 'process_medium'

    conda (params.enable_conda ? 'snippy' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastp:0.23.2--h79da9fb_0' :
        'quay.io/biocontainers/fastp:0.23.2--h79da9fb_0' }"

    input:
    tuple val(meta), path(contigs)

    output:
    tuple val(meta), path("${prefix}")         ,  emit: main
    path("${prefix}/*report.txt")                       , emit: summary
    path "versions.yml"                       , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """

    snippy \
    --cpus ${task.cpus} \
    --report \
    --outdir ${prefix} \
    --reference ${params.reference_fasta} \
    --ctgs ${contigs}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snippy: \$(echo \$(snippy --version 2>&1) | sed 's/snippy //')
    END_VERSIONS
    """
}
