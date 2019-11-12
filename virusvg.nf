params.virusvg_env = '/opt/anaconda2/envs/virusvg'
params.virusvg_path = '/home/lejno/Desktop/virus-vg-nf'
params.num_threads = 8
params.reads_dir = "/home/lejno/Desktop/WDV/reads_BBDukTrimmed/fastq"
//params.reads_dir = './data'
params.contigs_dir = '/home/lejno/Desktop/savage-nf/savage_ref_contigs'
params.vg_path = '/home/lejno/Desktop/virus-vg-nf/vg-v1.7.0'

reads_ch = Channel.fromFilePairs("$params.reads_dir/*_R{1,2}_clean.fastq")
contigs_ch = Channel.fromPath("$params.contigs_dir/*.fasta").map { file -> tuple(file.baseName, file) }
joint_ch = reads_ch.join(contigs_ch)

process buildGraph {
    echo true
    publishDir "./output$sampleId", mode: 'copy'
    conda params.virusvg_env
    input:
    //set sampleId, file(infiles) from joint_ch
    tuple sampleId, reads, contig from joint_ch

    script:
    """
    python $params.virusvg_path/scripts/build_graph_msga.py \
    -f ${reads[0]} \
    -r ${reads[1]} \
    -c ${contig} \
    -vg $params.vg_path \
    -t $params.num_threads
    """
}
