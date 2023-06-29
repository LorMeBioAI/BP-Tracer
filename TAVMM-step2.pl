use File::Basename;
use Getopt::Long;
use FindBin qw($Bin);

# 删除了blastx--blastx

sub usage{
	print STDERR <<USAGE;
	Version 1.0 2022-02-02 by TaoYe
	TAVMM pipeline step2
	It is better use HPS to submit shells to run faster.

	Options 
		-extract  <s> : NotRequired if step1 use default dir
		-meta   <s> : NotRequired if step1 use default dir
		-thread <n> : Thread number, default:20
		-outdir <s> : Output Dir, default: pwd
USAGE
}

my ($extract,$meta,$thread,$outdir);
GetOptions(
	"extract:s"=>\$extract,
	"meta:s"=>\$meta,
	"thread:n"=>\$thread,
	"outdir:s"=>\$outdir,
);
$thread||=20;
$outdir||=`pwd`;chomp $outdir;
my $pn=200000;
my ($line,@inf);
open IA, "$outdir/temp/01.ARG/ARG.extract.list" or die "can not open file: $outdir/temp/01.ARG/ARG.extract.list\n";
`rm -f $outdir/temp/01.ARG/extracted.fa`;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	`cat $inf[1] >> $outdir/temp/01.ARG/extracted.fa`;
}
close IA;
open IA,"$outdir/temp/01.ARG/ARG.meta.list" or die "can not open file: $outdir/temp/01.ARG/ARG.meta.list\n";
open OA,">$outdir/temp/01.ARG/meta_data_online.txt";
print OA "SampleID\tName\tCategory\tLibrarySize\t#ofReads\t#of16Sreads\tCellNumber\n";
my $n=0;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	$n++;
	open IB,"$inf[1]" or die "can not open file: $inf[1]\n";
	<IB>;
	my $temp=<IB>;chomp $temp;my @ele=split /\t/,$temp;
	$temp=join("\t",@ele[1..$#ele]);
	print OA "$n\t$temp\n";
	close IB;
}
close OA;
close IA;
open IA,"$outdir/temp/01.ARG/extracted.fa";
open OO,">$outdir/shell/S4.sh";
print OO "rm -f $outdir/temp/01.ARG/blastx.out\n";
$n=0;
while($line=<IA>){
	chomp $line;
	my $id=$line;
	$line=<IA>;chomp $line;
	if($n % $pn ==0){
		close OA;
		close OB;
		open OA, ">$outdir/temp/01.ARG/temp.$n.fa";
		open OB,">$outdir/shell/S3.ARG.$n.sh";
		print OB "blastx -query $outdir/temp/01.ARG/temp.$n.fa -out $outdir/temp/01.ARG/temp.$n.fa.m8 -db $Bin/DB/ARG-uniq.fa -evalue 1e-7  -num_threads 4 -outfmt 6 -max_target_seqs 1\n";
		close OB;
		print OO "cat $outdir/temp/01.ARG/temp.$n.fa.m8 >> $outdir/temp/01.ARG/blastx.out\n";
	}
	$n++;
	print OA "$id\n$line\n";
}
print OO "$Bin/argoap_pipeline_stagetwo_version2 -i $outdir/temp/01.ARG/extracted.fa -m $outdir/temp/01.ARG/meta_data_online.txt -n $thread -o $outdir/temp/01.ARG/ARG-OUT -b $outdir/temp/01.ARG/blastx.out\n";
print OO "cp $outdir/temp/01.ARG/ARG-OUT\*.txt $outdir/TAVMM_results\n";
print OO "cd $outdir/TAVMM_results\n";
print OO "perl $Bin/bin/geneppm-extract.pl $Bin/bin/species.txt $Bin/DB/ARG-uniq.list taxonomy.table.S ARG-OUT.ppm.gene.txt ARG-Tax.ppm.gene.txt\n";
close IA;
close OA;
close OO;



open IA, "$outdir/temp/02.MGE/MGE.extract.list" or die "can not open file: $outdir/temp/02.MGE/MGE.extract.list\n";
`rm -f $outdir/temp/02.MGE/extracted.fa`;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	`cat $inf[1] >> $outdir/temp/02.MGE/extracted.fa`;
}
close IA;
open IA,"$outdir/temp/02.MGE/MGE.meta.list" or die "can not open file: $outdir/temp/02.MGE/MGE.meta.list\n";
open OA,">$outdir/temp/02.MGE/meta_data_online.txt";
print OA "SampleID\tName\tCategory\tLibrarySize\t#ofReads\t#of16Sreads\tCellNumber\n";
my $n=0;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	$n++;
	open IB,"$inf[1]" or die "can not open file: $inf[1]\n";
	<IB>;
	my $temp=<IB>;chomp $temp;my @ele=split /\t/,$temp;
	$temp=join("\t",@ele[1..$#ele]);
	print OA "$n\t$temp\n";
	close IB;
}
close OA;
close IA;

open IA,"$outdir/temp/02.MGE/extracted.fa";
open OO,">>$outdir/shell/S4.sh";
print OO "rm -f $outdir/temp/02.MGE/blastx.out\n";
$n=0;
while($line=<IA>){
	chomp $line;
	my $id=$line;
	$line=<IA>;chomp $line;
	if($n % $pn ==0){
		close OA;
		close OB;
		open OA, ">$outdir/temp/02.MGE/temp.$n.fa";
		open OB,">$outdir/shell/S3.MGE.$n.sh";
		print OB "blastx -query $outdir/temp/02.MGE/temp.$n.fa -out $outdir/temp/02.MGE/temp.$n.fa.m8 -db $Bin/DB/MGE-uniq.fa -evalue 1e-7  -num_threads 4 -outfmt 6 -max_target_seqs 1\n";
		close OB;
		print OO "cat $outdir/temp/02.MGE/temp.$n.fa.m8 >> $outdir/temp/02.MGE/blastx.out\n";
	}
	$n++;
	print OA "$id\n$line\n";
}
print OO "$Bin/MGE_stagetwo -i $outdir/temp/02.MGE/extracted.fa -m $outdir/temp/02.MGE/meta_data_online.txt -n $thread -o $outdir/temp/02.MGE/MGE-OUT -b $outdir/temp/02.MGE/blastx.out\n";
print OO "cp $outdir/temp/02.MGE/MGE-OUT\*.txt $outdir/TAVMM_results\n";
print OO "cd $outdir/TAVMM_results\n";
print OO "perl $Bin/bin/geneppm-extract.pl $Bin/bin/species.txt $Bin/DB/MGE-uniq.list taxonomy.table.S MGE-OUT.ppm.gene.txt MGE-Tax.ppm.gene.txt\n";
close IA;
close OA;
close OO;


open IA, "$outdir/temp/03.MRG/MRG.extract.list" or die "can not open file: $outdir/temp/03.MRG/MRG.extract.list\n";
`rm -f $outdir/temp/03.MRG/extracted.fa`;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	`cat $inf[1] >> $outdir/temp/03.MRG/extracted.fa`;
}
close IA;
open IA,"$outdir/temp/03.MRG/MRG.meta.list" or die "can not open file: $outdir/temp/03.MRG/MRG.meta.list\n";
open OA,">$outdir/temp/03.MRG/meta_data_online.txt";
print OA "SampleID\tName\tCategory\tLibrarySize\t#ofReads\t#of16Sreads\tCellNumber\n";
my $n=0;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	$n++;
	open IB,"$inf[1]" or die "can not open file: $inf[1]\n";
	<IB>;
	my $temp=<IB>;chomp $temp;my @ele=split /\t/,$temp;
	$temp=join("\t",@ele[1..$#ele]);
	print OA "$n\t$temp\n";
	close IB;
}
close OA;
close IA;

open IA,"$outdir/temp/03.MRG/extracted.fa";
open OO,">>$outdir/shell/S4.sh";
print OO "rm -f $outdir/temp/03.MRG/blastx.out\n";
$n=0;
while($line=<IA>){
	chomp $line;
	my $id=$line;
	$line=<IA>;chomp $line;
	if($n % $pn ==0){
		close OA;
		close OB;
		open OA, ">$outdir/temp/03.MRG/temp.$n.fa";
		open OB,">$outdir/shell/S3.MRG.$n.sh";
		print OB "blastx -query $outdir/temp/03.MRG/temp.$n.fa -out $outdir/temp/03.MRG/temp.$n.fa.m8 -db $Bin/DB/MRG-uniq.fa -evalue 1e-7  -num_threads 4 -outfmt 6 -max_target_seqs 1\n";
		close OB;
		print OO "cat $outdir/temp/03.MRG/temp.$n.fa.m8 >> $outdir/temp/03.MRG/blastx.out\n";
	}
	$n++;
	print OA "$id\n$line\n";
}
print OO "$Bin/MRG_stagetwo -i $outdir/temp/03.MRG/extracted.fa -m $outdir/temp/03.MRG/meta_data_online.txt -n $thread -o $outdir/temp/03.MRG/MRG-OUT -b $outdir/temp/03.MRG/blastx.out\n";
print OO "cp $outdir/temp/03.MRG/MRG-OUT\*.txt $outdir/TAVMM_results\n";
print OO "cd $outdir/TAVMM_results\n";
print OO "perl $Bin/bin/geneppm-extract.pl $Bin/bin/species.txt $Bin/DB/MRG-uniq.list taxonomy.table.S MRG-OUT.ppm.gene.txt MRG-Tax.ppm.gene.txt\n";
close IA;
close OA;
close OO;


open IA, "$outdir/temp/04.VFDB/VFDB.extract.list" or die "can not open file: $outdir/temp/04.VFDB/VFDB.extract.list\n";
`rm -f $outdir/temp/04.VFDB/extracted.fa`;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	`cat $inf[1] >> $outdir/temp/04.VFDB/extracted.fa`;
}
close IA;
open IA,"$outdir/temp/04.VFDB/VFDB.meta.list" or die "can not open file: $outdir/temp/04.VFDB/VFDB.meta.list\n";
open OA,">$outdir/temp/04.VFDB/meta_data_online.txt";
print OA "SampleID\tName\tCategory\tLibrarySize\t#ofReads\t#of16Sreads\tCellNumber\n";
my $n=0;
while($line=<IA>){
	chomp $line;
	@inf=split /\t/,$line;
	$n++;
	open IB,"$inf[1]" or die "can not open file: $inf[1]\n";
	<IB>;
	my $temp=<IB>;chomp $temp;my @ele=split /\t/,$temp;
	$temp=join("\t",@ele[1..$#ele]);
	print OA "$n\t$temp\n";
	close IB;
}
close OA;
close IA;

open IA,"$outdir/temp/04.VFDB/extracted.fa";
open OO,">>$outdir/shell/S4.sh";
print OO "rm -f $outdir/temp/04.VFDB/blastx.out\n";
$n=0;
while($line=<IA>){
	chomp $line;
	my $id=$line;
	$line=<IA>;chomp $line;
	if($n % $pn ==0){
		close OA;
		close OB;
		open OA, ">$outdir/temp/04.VFDB/temp.$n.fa";
		open OB,">$outdir/shell/S3.VFDB.$n.sh";
		print OB "blastx -query $outdir/temp/04.VFDB/temp.$n.fa -out $outdir/temp/04.VFDB/temp.$n.fa.m8 -db $Bin/DB/VFDB-uniq.fa -evalue 1e-7  -num_threads 4 -outfmt 6 -max_target_seqs 1\n";
		close OB;
		print OO "cat $outdir/temp/04.VFDB/temp.$n.fa.m8 >> $outdir/temp/04.VFDB/blastx.out\n";
	}
	$n++;
	print OA "$id\n$line\n";
}
print OO "$Bin/VFDB_stagetwo -i $outdir/temp/04.VFDB/extracted.fa -m $outdir/temp/04.VFDB/meta_data_online.txt -n $thread -o $outdir/temp/04.VFDB/VFDB-OUT -b $outdir/temp/04.VFDB/blastx.out\n";
print OO "cp $outdir/temp/04.VFDB/VFDB-OUT\*.txt $outdir/TAVMM_results\n";
print OO "cd $outdir/TAVMM_results\n";
print OO "perl $Bin/bin/geneppm-extract.pl $Bin/bin/species.txt $Bin/DB/VFDB-uniq.list taxonomy.table.S VFDB-OUT.ppm.gene.txt VFDB-Tax.ppm.gene.txt\n";
close IA;
close OA;
close OO;

