nextflow.enable.dsl = 2


//================================================================================
// Include sub-workflows/modules and (soft) override workflow-level parameters
//================================================================================

include { CALL_WF } from './workflows/call_wf.nf'
include { VALIDATE_FASTQS_WF } from './workflows/validate_fastqs_wf.nf'
include { MAP_WF } from './workflows/map_wf.nf'
include { MERGE_WF } from './workflows/merge_wf.nf'
include { MINOR_VARIANT_ANALYSIS_WF } from './workflows/minor_variant_analysis_wf.nf'
include { QUALITY_CHECK_WF } from './workflows/quality_check_wf.nf'
include { REPORTS_WF } from './workflows/reports_wf.nf'


//================================================================================
// Main workflow
//================================================================================

workflow {

    if (params.only_validate_fastqs) {

        VALIDATE_FASTQS_WF(params.input_samplesheet)

    } else {

        validated_reads_ch = VALIDATE_FASTQS_WF( params.input_samplesheet )

        QUALITY_CHECK_WF( validated_reads_ch )

        MAP_WF( validated_reads_ch )

        CALL_WF( MAP_WF.out.sorted_reads_ch )

        MINOR_VARIANT_ANALYSIS_WF(CALL_WF.out.reformatted_lofreq_vcfs_tuple_ch)


        //---------------------------------------------------------------------------------
        // Filter the approved samples

        //FIXME Take the results of MINOR_VARIANT_ANALYSIS_WF analysis for the samples which are approved 
        //and combine with existing filtering process.
        //Combine the results with those of cohort stats and then do the filtering
        //---------------------------------------------------------------------------------

        //NOTE: Read the approved_samples tsv file and isolate the names of the approved samples
        approved_samples_minor_variants_ch = MINOR_VARIANT_ANALYSIS_WF.out.approved_samples_ch
                                .splitCsv(header: false, skip: 1, sep: '\t' )
                                .map { row -> [ row.first() ] }
                                .collect()
                                .view {"\n\n XBS-NF-LOG approved_samples_minor_variants_ch : $it \n\n"}

        //NOTE: Reshape the flattened output of gvch_ch into the tuples of [sampleName, gvcf, gvcf.tbi]
        collated_gvcfs_ch = CALL_WF.out.gvcf_ch
                                .flatten()
                                .collate(3)
                                .view {"\n\n XBS-NF-LOG collated_gvcfs_ch : $it \n\n"}
                                //.collectFile(name: "$params.outdir/collated_gvcfs_ch.txt")



        //FIXME: Refactor this to emit two different files and use only the approved samples
        //NOTE: Use the stats file for the entire cohort (from CALL_WF)
        // and filter out the samples which pass all thresholds
        approved_call_wf_samples_ch = CALL_WF.out.cohort_stats_tsv
                                .splitCsv(header: false, skip: 1, sep: '\t' )
                                .map { row -> [
                                        row.first(),           // SAMPLE
                                        row.last().toInteger() // ALL_THRESHOLDS_MET
                                        ]
                                    }
                                .filter { it[1] == 1} // Filter out samples which meet all the thresholds
                                .map { [ it[0] ] }

        approved_call_wf_samples_ch.collect().view {"\n\n XBS-NF-LOG approved_call_wf_samples_ch.collect() : $it \n\n"}

        //NOTE: Join the approved samples from MINOR_VARIANT_ANALYSIS_WF and CALL_WF
        fully_approved_samples_ch = approved_samples_minor_variants_ch
                                        .join(approved_call_wf_samples_ch)
                                        .flatten()
                                        .dump(tag:'fully_approved_samples_ch')
                                        .view {"\n\n XBS-NF-LOG fully_approved_samples_ch : $it \n\n"}
                                        //.collect()
                                        //.collectFile(name: "$params.outdir/approved_samples_ch.txt") 


        //NOTE: Join the fully approved samples with the gvcf channel to select files for MERGE_WF
        selected_gvcfs_ch = collated_gvcfs_ch
                                .join(fully_approved_samples_ch)
                                .flatten()
                                .filter { it.class  == sun.nio.fs.UnixPath }
                                .collect()
                                .view {"\n\n XBS-NF-LOG selected_gvcfs_ch : $it \n\n"} 
                                //.collectFile(name: "$params.outdir/selected_gvcfs_ch")

        //---------------------------------------------------------------------------------

/*
        MERGE_WF(selected_gvcfs_ch, CALL_WF.out.reformatted_lofreq_vcf_ch)

        REPORTS_WF(QUALITY_CHECK_WF.out.reports_fastqc_ch)
*/
    }

}

