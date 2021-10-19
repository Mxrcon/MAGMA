process FASTQC {
    tag "${sampleName}"
    publishDir params.results_dir, mode: params.save_mode, enabled: params.should_publish

    input:
    tuple val(sampleName), path(sampleReads)

    output:
    tuple path('*.html'), path('*.zip')


    script:

    """
    ${params.fastqc_path} \\
        ${sampleReads} \\
        -t ${task.cpus}
    """

    stub:
    """
    echo "${params.fastqc_path} \\
              ${sampleReads} \\
              -t ${task.cpus}"

    touch ${sampleName}.html

    touch ${sampleName}.zip
    """
}
