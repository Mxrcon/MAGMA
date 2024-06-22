process FASTQ_VALIDATOR {
    tag "${sampleName}"
    publishDir params.results_dir, mode: params.save_mode, enabled: params.should_publish

    stageInMode 'copy'
    maxRetries 3
    errorStrategy { task.attempt < 3 ? 'retry' : 'ignore' }


    input:
        tuple val(sampleName), path(sampleRead)
        val ready

    output:
        tuple val(sampleName), path("*.check.*tsv")
        path("*.check.*tsv")                          , emit: check_result
        tuple val(sampleName), path(sampleRead)      , emit: reads

    shell:

        '''
        seqkit stats -a -T  !{sampleRead}  > !{sampleRead.baseName}.seqkit_out.txt
        cat *seqkit_out.txt | csvtk space2tab | csvtk tab2csv > !{sampleName}.seqkit_stats.csv

        md5sum !{sampleRead} > !{sampleRead.baseName}.md5sum_out.txt
        cat *md5sum_out.txt | csvtk space2tab | csvtk tab2csv | csvtk add-header -n md5sum,file > !{sampleRead.baseName}.md5sum_stats.csv

        du -shL !{sampleRead} > !{sampleRead.baseName}.du_out.txt
        cat *du_out.txt | csvtk tab2csv | csvtk add-header -n size,file > !{sampleRead.baseName}.du_stats.csv



        csvtk join -f file \\
        !{sampleRead.baseName}.seqkit_stats.csv \\
        !{sampleRead.baseName}.md5sum_stats.csv \\
        !{sampleRead.baseName.baseName}.du_stats.csv \\
        > !{sampleName}.fastq_statistics.csv


        rm *_out.txt *_stats.csv


        !{params.fastq_validator_path} !{sampleRead} \\
        2>!{sampleName}.command.log || true

        cp !{sampleName}.command.log .command.log



        TEMP=$(tail -n 1 !{sampleName}.command.log)


        if [ "$(echo "$TEMP")" == "OK" ]; then
            VALIDATED=1
            STATUS="passed"
            echo -e "!{sampleName}\t${VALIDATED}" > !{sampleName}.check.${STATUS}.tsv
            exit 0

        else
            VALIDATED=0
            STATUS="failed"
            echo -e "!{sampleName}\t${VALIDATED}" > !{sampleName}.check.${STATUS}.tsv
            exit 1
        fi


        '''

    stub:

        """
        touch ${sampleName}.check.tsv
        """

}
