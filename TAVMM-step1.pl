use File::Basename;
use Getopt::Long;
use FindBin qw($Bin);

# 修改Diamond的$Bin/bin/
# 统一Diamond的版本
# $Bin/bin/kraken2/kraken2-Kraken2
sub usage{
	print STDERR <<USAGE;
	Version 1.0 2022-02-02 by TaoYe
	TAVMM pipeline step1

	Options 
		-input  <s> : Required (Absolute Dir), Four Columns:
			ID clean.1.fq.gz clean.2.fq.gz 
		-thread <n> : Thread number, default:20
			please lefe enough disk space for this pipeline
			10G cleandata need 50G disk space!
USAGE
}

my ($input,$thread,$outdir);
GetOptions(
	"input:s"=>\$input,
	"thread:n"=>\$thread,
);
$thread||=20;
$outdir=`pwd`;chomp $outdir;

if(!defined($input)){
	usage;
	exit;
}

`mkdir -p $outdir/temp/01.ARG`;
`mkdir -p $outdir/shell`;
`mkdir -p $outdir/TAVMM_results`;
`mkdir -p $outdir/temp/00.Taxonomy`;

my ($line,@inf,@sam);
open IA, "$input" or die "can not open file: $input\n";
open O1, ">$outdir/temp/01.ARG/ARG.extract.list" or die "can not open file: extract.list\n";
open O2, ">$outdir/temp/01.ARG/ARG.meta.list" or die "can not open file: meta.list\n";
open O3, ">$outdir/temp/input.list" or die "can not open file: $outdir/temp/input.list\n";
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	print O1 "$inf[0]\t$outdir/temp/01.ARG/$inf[0]/extracted.fa\n";
	print O2 "$inf[0]\t$outdir/temp/01.ARG/$inf[0]/meta_data_online.txt\n";

	`mkdir -p $outdir/temp/01.ARG/$inf[0]`;
	open OA,">$outdir/temp/01.ARG/$inf[0]/meta-data.txt";
	print OA "SampleID\tName\tCategory\tLibrarySize\n";
	print OA "1\t$inf[0]\t$inf[0]\t300\n";
	close OA;

	open OA,">$outdir/shell/S1.ARG.$inf[0].sh";
	print OA "cd $outdir/temp/01.ARG/$inf[0]\n";
	print OA "ln -s $inf[1] $inf[0].clean.1.fq.gz\n";
	print OA "ln -s $inf[2] $inf[0].clean.2.fq.gz\n";
	print OA "$Bin/argoap_pipeline_stageone_version2.3 -i ./ -m meta-data.txt -o ./ -n $thread -f fq -z\n";
	close OA;
	print O3 "$inf[0]\t$outdir/temp/01.ARG/$inf[0]/$inf[0]_1.fa\t$outdir/temp/01.ARG/$inf[0]/$inf[0]_2.fa\t$outdir/temp/01.ARG/$inf[0]/$inf[0].uscmg.blastx.txt\t$outdir/temp/01.ARG/$inf[0]/$inf[0].sam\t$outdir/temp/01.ARG/$inf[0]/meta-data.txt\n";

	open OA, ">$outdir/shell/S0.1.Tax.$inf[0].sh";
	print OA "cd $outdir/temp/00.Taxonomy\n";
	print OA "Kraken2 --db $Bin/RefSeqPanDB2022 --threads $thread --quick --report-zero-counts --gzip-compressed --paired --output $inf[0].readinfo --report $inf[0].report $inf[1] $inf[2]\n";
	print OA "python2 $Bin/bin/kraken2/kreport2mpa.py -r $inf[0].report -o $inf[0].mpa\n";
	print OA "python2 $Bin/bin/kraken2/est_abundance.py -t 1 -k $Bin/RefSeqPanDB2022/database150mers.kmer_distrib -i $inf[0].report -o $inf[0].report.D -l D\n";
	print OA "python2 $Bin/bin/kraken2/est_abundance.py -t 1 -k $Bin/RefSeqPanDB2022/database150mers.kmer_distrib -i $inf[0].report -o $inf[0].report.P -l P\n";
	print OA "python2 $Bin/bin/kraken2/est_abundance.py -t 1 -k $Bin/RefSeqPanDB2022/database150mers.kmer_distrib -i $inf[0].report -o $inf[0].report.C -l C\n";
	print OA "python2 $Bin/bin/kraken2/est_abundance.py -t 1 -k $Bin/RefSeqPanDB2022/database150mers.kmer_distrib -i $inf[0].report -o $inf[0].report.O -l O\n";
	print OA "python2 $Bin/bin/kraken2/est_abundance.py -t 1 -k $Bin/RefSeqPanDB2022/database150mers.kmer_distrib -i $inf[0].report -o $inf[0].report.F -l F\n";
	print OA "python2 $Bin/bin/kraken2/est_abundance.py -t 1 -k $Bin/RefSeqPanDB2022/database150mers.kmer_distrib -i $inf[0].report -o $inf[0].report.G -l G\n";
	print OA "python2 $Bin/bin/kraken2/est_abundance.py -t 1 -k $Bin/RefSeqPanDB2022/database150mers.kmer_distrib -i $inf[0].report -o $inf[0].report.S -l S\n";
	print OA "rm $inf[0].readinfo\n";
	close OA;
	push @sam,$inf[0];
}
close IA;
close O1;
close O2;
close O3;

#bracken output
open OA, ">$outdir/shell/S0.2.tax.sh" or die "can not open file: $outdir/shell/S4-tax.sh\n";
print OA "cd $outdir/temp/00.Taxonomy\n";
my $report=join(".report.D ",@sam);
my $names=join(",",@sam);
print OA "python2 $Bin/bin/kraken2/combine_bracken_outputs.py --files $report.report.D --names $names -o taxonomy.D\n";
$report=join(".report.P ",@sam);
print OA "python2 $Bin/bin/kraken2/combine_bracken_outputs.py --files $report.report.P --names $names -o taxonomy.P\n";
$report=join(".report.C ",@sam);
print OA "python2 $Bin/bin/kraken2/combine_bracken_outputs.py --files $report.report.C --names $names -o taxonomy.C\n";
$report=join(".report.O ",@sam);
print OA "python2 $Bin/bin/kraken2/combine_bracken_outputs.py --files $report.report.O --names $names -o taxonomy.O\n";
$report=join(".report.F ",@sam);
print OA "python2 $Bin/bin/kraken2/combine_bracken_outputs.py --files $report.report.F --names $names -o taxonomy.F\n";
$report=join(".report.G ",@sam);
print OA "python2 $Bin/bin/kraken2/combine_bracken_outputs.py --files $report.report.G --names $names -o taxonomy.G\n";
$report=join(".report.S ",@sam);
print OA "python2 $Bin/bin/kraken2/combine_bracken_outputs.py --files $report.report.S --names $names -o taxonomy.S\n";
print OA "perl $Bin/bin/kraken2-mergeStat.pl -prefix taxonomy -out taxonomy -outdir $outdir\n";
print OA "cp taxonomy.table\* $outdir/TAVMM_results\n";
close OA;

`mkdir -p $outdir/temp/02.MGE`;
`mkdir -p $outdir/temp/03.MRG`;
`mkdir -p $outdir/temp/04.VFDB`;
open IN, "$outdir/temp/input.list" or die "can not open file: $outdir/temp/input.list\n";
open O1, ">$outdir/temp/02.MGE/MGE.extract.list" or die "can not open file: extract.list\n";
open O2, ">$outdir/temp/02.MGE/MGE.meta.list" or die "can not open file: meta.list\n";
open O3, ">$outdir/temp/03.MRG/MRG.extract.list" or die "can not open file: extract.list\n";
open O4, ">$outdir/temp/03.MRG/MRG.meta.list" or die "can not open file: meta.list\n";
open O5, ">$outdir/temp/04.VFDB/VFDB.extract.list" or die "can not open file: extract.list\n";
open O6, ">$outdir/temp/04.VFDB/VFDB.meta.list" or die "can not open file: meta.list\n";

while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	print O1 "$inf[0]\t$outdir/temp/02.MGE/$inf[0]/extracted.fa\n";
	print O2 "$inf[0]\t$outdir/temp/02.MGE/$inf[0]/meta_data_online.txt\n";
	print O3 "$inf[0]\t$outdir/temp/03.MRG/$inf[0]/extracted.fa\n";
	print O4 "$inf[0]\t$outdir/temp/03.MRG/$inf[0]/meta_data_online.txt\n";
	print O5 "$inf[0]\t$outdir/temp/04.VFDB/$inf[0]/extracted.fa\n";
	print O6 "$inf[0]\t$outdir/temp/04.VFDB/$inf[0]/meta_data_online.txt\n";

	`mkdir -p $outdir/temp/02.MGE/$inf[0]`;
	`mkdir -p $outdir/temp/03.MRG/$inf[0]`;
	`mkdir -p $outdir/temp/04.VFDB/$inf[0]`;

	open OA,">$outdir/shell/S2.MGE.$inf[0].sh";
	print OA "cd $outdir/temp/02.MGE/$inf[0]\n";
	for(my $i=1;$i<=$#inf;$i++){
		print OA "ln -s $inf[$i]\n";
	}
	print OA "diamond blastx -d $Bin/DB/MGE.dmnd -q $inf[1] -o $inf[0]_1.us -e 10 -p $thread -k 1 --id 60 --query-cover 15\n";
	print OA "diamond blastx -d $Bin/DB/MGE.dmnd -q $inf[2] -o $inf[0]_2.us -e 10 -p $thread -k 1 --id 60 --query-cover 15\n";
	print OA "$Bin/bin/extract_usearch_reads.pl $inf[0]_1.us $inf[1] $inf[0].extract_1.fa\n";
	print OA "$Bin/bin/extract_usearch_reads.pl $inf[0]_2.us $inf[2] $inf[0].extract_2.fa\n";
	print OA "$Bin/bin/merge_extracted_fa_update_metadate.v2.3.pl ./ ./ meta-data.txt meta_data_online.txt extracted.fa U $Bin/DB/all_KO30_name.list\n";
	close OA;

	open OA,">$outdir/shell/S2.MRG.$inf[0].sh";
	print OA "cd $outdir/temp/03.MRG/$inf[0]\n";
	for(my $i=1;$i<=$#inf;$i++){
		print OA "ln -s $inf[$i]\n";
	}
	print OA "diamond blastx -d $Bin/DB/MRG.dmnd -q $inf[1] -o $inf[0]_1.us -e 10 -p $thread -k 1 --id 60 --query-cover 15\n";
	print OA "diamond blastx -d $Bin/DB/MRG.dmnd -q $inf[2] -o $inf[0]_2.us -e 10 -p $thread -k 1 --id 60 --query-cover 15\n";
	print OA "$Bin/bin/extract_usearch_reads.pl $inf[0]_1.us $inf[1] $inf[0].extract_1.fa\n";
	print OA "$Bin/bin/extract_usearch_reads.pl $inf[0]_2.us $inf[2] $inf[0].extract_2.fa\n";
	print OA "$Bin/bin/merge_extracted_fa_update_metadate.v2.3.pl ./ ./ meta-data.txt meta_data_online.txt extracted.fa U $Bin/DB/all_KO30_name.list\n";
	close OA;

	open OA,">$outdir/shell/S2.VFDB.$inf[0].sh";
	print OA "cd $outdir/temp/04.VFDB/$inf[0]\n";
	for(my $i=1;$i<=$#inf;$i++){
		print OA "ln -s $inf[$i]\n";
	}
	print OA "diamond blastx -d $Bin/DB/VFDB.dmnd -q $inf[1] -o $inf[0]_1.us -e 10 -p $thread -k 1 --id 60 --query-cover 15\n";
	print OA "diamond blastx -d $Bin/DB/VFDB.dmnd -q $inf[2] -o $inf[0]_2.us -e 10 -p $thread -k 1 --id 60 --query-cover 15\n";
	print OA "$Bin/bin/extract_usearch_reads.pl $inf[0]_1.us $inf[1] $inf[0].extract_1.fa\n";
	print OA "$Bin/bin/extract_usearch_reads.pl $inf[0]_2.us $inf[2] $inf[0].extract_2.fa\n";
	print OA "$Bin/bin/merge_extracted_fa_update_metadate.v2.3.pl ./ ./ meta-data.txt meta_data_online.txt extracted.fa U $Bin/DB/all_KO30_name.list\n";
	close OA;
}
close IA;
close (O1,O2,O3,O4,O5,O6);
close IN;
