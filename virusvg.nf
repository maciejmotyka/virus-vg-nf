params.virusvg_env = '/opt/anaconda2/envs/virusvg'
params.virusvg_path = '/home/lejno/Desktop/virus-vg/scripts'
params.num_threads = 8
//params.reads_dir = '/home/lejno/Desktop/savage-nf'
params.reads_dir = './data'
params.vg_path = '/home/lejno/Desktop/virus-vg/vg-v1.7.0'

dirs_ch = Channel.fromPath("$params.reads_dir/*.fastq", type: 'dir')

process buildGraph {
    conda params.virusvg_env
    input:
    val dir from dirs_ch

    script:
    """
    python $params.virusvg_path/build_graph_msga.py \
    -f ${dir}/*_R1_clean.fastq \
    -r ${dir}/*_R2_clean.fastq \
    -c ${dir}/contigs_stage_c.fasta \
    -vg vg-v1.7.0 -t 8
    """
}
