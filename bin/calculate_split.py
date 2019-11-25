#!/usr/bin/env python

from argparse import ArgumentParser
import sys
import pdb

usage = """
'Calculate optimal -c and -m parameters for virus-vg second stage'
"""

def main():
    parser = ArgumentParser(description = usage)
    parser.add_argument('--ref_len', dest='ref_len', type=int, help='length in bp of the sequenced genome to calculate --split parameter for savage')
    parser.add_argument('-s', dest='input_s', type=str, help='path to input fastq containing single-end reads')
    parser.add_argument('-p1', dest='input_p1', type=str, help='path to input fastq containing paired-end reads (/1)')
    parser.add_argument('-p2', dest='input_p2', type=str, help='path to input fastq containing paired-end reads (/2)')

    if len(sys.argv[1:])==0:
#        print usage
#        parser.print_usage()
        parser.print_help()
        parser.exit()
    args = parser.parse_args()

    # analyze single-end input reads
    if args.input_s:
        [s_total_len] = analyze_fastq(args.input_s)
    else:
        s_total_len = 0

    # analyze paired-end input reads
    if args.input_p1:
        [p1_total_len] = analyze_fastq(args.input_p1)
        [p2_total_len] = analyze_fastq(args.input_p2)
        p_total_len = p1_total_len + p2_total_len

    total_seq_len = s_total_len + p_total_len
    assert total_seq_len > 0, "Total length of input sequences is zero."

    split_into = calculate_split(total_seq_len, args.ref_len)
    filename = args.input_p1
    print split_into
#    outfile = open("split_into.txt", "a+")
#    outfile.write("%s\t%s\n" % (filename, split_into))
#    outfile.close()

def calculate_c(num_of_bases, ref_len):
    c = 1
    while (num_of_bases / ref_len / split_into > 1000):
        split_into += 1
    return c

def calculate_m(num_of_bases, ref_len):
    split_into = 1
    while (num_of_bases / ref_len / split_into > 1000):
        split_into += 1
    return m

def analyze_fastq(filename):
    total_len = 0
    i = 0
    with open(filename) as f:
        for line in f:
            if i%4 == 1: # sequence line in fastq
                l = len(line.strip('\n'))
                total_len += l
            i += 1
        assert i % 4 == 0, "%s is not a valid fastq file" % filename
    return [total_len]

if __name__ == '__main__':
    sys.exit(main())
