



nextflow.enable.dsl = 2

// Module imports
include { PROFILE_DISTS } from "./modules/local/profile_dists.nf"
include { GAS_CALL } from "./modules/local/gas_call.nf"

// nf-core modules
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/nf-core/dumpsoftwareversions/main'

// Plugin imports
include { validateParameters; paramsHelp; fromSamplesheet } from 'plugin/nf-validation'

if (params.help) {
    log.info paramsHelp("nextflow run my_pipeline --input input_file.csv")
    exit 0
}


if (params.validate_params) {
    validateParameters()
}

def validateFilePath(String filep){
    if(filep){
        file_in = file(filep)
        if(file_in.exists()){
            return file_in
        }else{
            exit 1, "${filep} does not exist but was passed to the pipeline. Exiting now."
        }
    }
    return [] // empty value if file argument is null
}


workflow CALL {

    versions = Channel.empty()

    input_profiles = Channel.fromSamplesheet('input', 
                            parameters_schema: 'nextflow_schema.json') // from the input get meta, path(query), path(ref profile), clusters

    input_dists = input_profiles.multiMap{
        meta, path_query, path_reference, clusters ->     
            queries: tuple(meta, validateFilePath(path_query), validateFilePath(path_reference))
            clusters: tuple(meta, validateFilePath(clusters))
    }

    // optional files to be passed in
    mapping_file = validateFilePath(params.pd_mapping_file)
    columns_file = validateFilePath(params.pd_columns)
    // options related to output to be passed into profile idsts
    mapping_format = Channel.value(params.pd_outfmt)

    dist_data = PROFILE_DISTS(input_dists.queries, mapping_format, mapping_file, columns_file)
    versions = versions.mix(dist_data.versions)

    to_call = input_dists.clusters.join(dist_data.results)
    called_data = GAS_CALL(to_call)

    versions = versions.mix(called_data.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS(versions.unique().collectFile(name: 'collated_versions.yml'))

}


workflow {
    CALL()
}