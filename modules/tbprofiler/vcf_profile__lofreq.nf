process TBPROFILER_VCF_PROFILE__LOFREQ {
    tag "${sampleName}"
    publishDir params.results_dir, mode: params.save_mode, enabled: params.should_publish
    stageInMode 'copy'

    input:
        tuple val(sampleName), path(lofreqVcf)
        path(resistanceDb)

    output:
        tuple val(sampleName), path("results/*")
        path("results/*"), emit: resistance_json


    script:
        def optionalDb  = resistanceDb ? "--db ${resistanceDb.name}" : ""

        def optionallyLoadLibraryForContainers = workflow.container ? "cd ${resistanceDb}; ${params.tbprofiler_path} load_library ${resistanceDb.name}; cd ../" : ""

        """

        ${optionallyLoadLibraryForContainers}

        ${params.tbprofiler_path} vcf_profile \\
            --lofreq_sample_name ${sampleName} \\
            ${optionalDb} \\
            ${lofreqVcf}
        """

    stub:
        """
        mkdir results
        touch results/${sampleName}.results.json
        """

}
