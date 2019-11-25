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
    publishDir "./output$sampleId", mode: 'copy'
    conda params.virusvg_env
    input:
    tuple sampleId, reads, contig from joint_ch
    output:
    file node_abundance.txt contig_graph.final.gfa into stage1_out_ch

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
process optimizeStrains {
    publishDir "./output/$sampleId", mode: 'copy'
    conda params.virusvg_env
    input:
    tuple m, c from stage2_params_ch
    tuple node_abundance, contig_graph from stage1_out_ch
    output:
    file "*"

    script:
    """
    SEQ_DEPTH="\$(calculate_depth.py \
    --ref_len $params.ref_len \
    -p1 ${reads[0]} \
    -p2 ${reads[1]})";
    python $params.virusvg_path/scripts/optimize_strains.py \
    -m ${m} \
    -c ${c} \
    ${node_abundance} \
    ${contig_graph}
    """
}
