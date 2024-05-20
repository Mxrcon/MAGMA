nextflow.enable.dsl = 2

include { MULTIQC } from '../modules/multiqc/multiqc.nf' addParams (params.MULTIQC)
include { UTILS_SUMMARIZE_RESISTANCE_RESULTS } from '../modules/utils/summarize_resistance_results.nf' addParams (params.UTILS_SUMMARIZE_RESISTANCE_RESULTS)

workflow REPORTS_WF {
    take:
         reports_fastqc_ch
         merged_cohort_stats_ch
         major_variants_results_ch
         minor_variants_results_ch
         structural_variants_results_ch

    main:
        MULTIQC(reports_fastqc_ch)

        UTILS_SUMMARIZE_RESISTANCE_RESULTS(
            merged_cohort_stats_ch,
            major_variants_results_ch,
            minor_variants_results_ch,
            structural_variants_results_ch
        )

}
