use File::Basename;
use Getopt::Long;
use FindBin qw($Bin);

my $Tax="$Bin/tax.list";

sub usage{
	print STDERR <<USAGE;
	Version 1.0 2018-07-12 by YaoYe
	Taxonmy Abundance Merge Table and Stat Pipeline. 

	Options 
		-prefix <s> : Required, the output prefix from step1
		-out    <s> : output prefix
		-outdir <s> : Output Directory. Must be absolute path!!!
		-help       : show this help
USAGE
}

my ($prefix,$outdir,$out,$help);
GetOptions(
	"prefix:s"=>\$prefix,
	"outdir:s"=>\$outdir,
	"out:s"=>\$out,
	"help"=>\$help,
);

if(!defined($prefix)||!defined ($out)){
	usage;
	exit;
}
$outdir||=`pwd`;chomp $outdir;

my ($line,@inf,%sample,%reads,%id,@tax);
open IB, "$prefix.D" or die "can not open file: $prefix.D\n";
$line=<IB>;chomp $line;@inf=split /\t/,$line;
for(my $i=3;$i<$#inf;$i+=2){
	$inf[$i]=~s/_num//;
	$id{$i}=$inf[$i];
}
close IB;

open IN, "$Tax" or die "can not open $Tax\n";
open OA, ">$out.table" or die "can not open $out.table\n";
my (%all,@item);
while($line=<IN>){
	chomp $line;
	push @item,$line;
	foreach my $i (keys %id){
		$all{$line}{$i}=0;
	}
}
close IN;

open IN, "$prefix.C" or die "can not open file $prefix.C\n";
<IN>;
while($line=<IN>){
	chomp $line;@inf=split /\t/,$line;
	my $temptax="";
	for(my $i=0;$i<=$#item;$i++){
		if($item[$i]=~/c__$inf[0]$/){
			$temptax=$item[$i];
			last;
		}
	}
	for(my $i=3;$i<$#inf;$i+=2){
		$all{$temptax}{$i}=$inf[$i];
	}
}
close IN;

open IN, "$prefix.D" or die "can not open file $prefix.D\n";
<IN>;
while($line=<IN>){
	chomp $line;@inf=split /\t/,$line;
	my $temptax="";
	for(my $i=0;$i<=$#item;$i++){
		if($item[$i]=~/d__$inf[0]$/){
			$temptax=$item[$i];
			last;
		}
	}
	for(my $i=3;$i<$#inf;$i+=2){
		$all{$temptax}{$i}=$inf[$i];
	}
}
close IN;

open IN, "$prefix.F" or die "can not open file $prefix.F\n";
<IN>;
while($line=<IN>){
	chomp $line;@inf=split /\t/,$line;
	my $temptax="";
	for(my $i=0;$i<=$#item;$i++){
		if($item[$i]=~/f__$inf[0]$/){
			$temptax=$item[$i];
			last;
		}
	}
	for(my $i=3;$i<$#inf;$i+=2){
		$all{$temptax}{$i}=$inf[$i];
	}
}
close IN;

open IN, "$prefix.G" or die "can not open file $prefix.G\n";
<IN>;
while($line=<IN>){
	chomp $line;@inf=split /\t/,$line;
	my $temptax="";
	for(my $i=0;$i<=$#item;$i++){
		if($item[$i]=~/g__$inf[0]$/){
			$temptax=$item[$i];
			last;
		}
	}
	for(my $i=3;$i<$#inf;$i+=2){
		$all{$temptax}{$i}=$inf[$i];
	}
}
close IN;

open IN, "$prefix.O" or die "can not open file $prefix.O\n";
<IN>;
while($line=<IN>){
	chomp $line;@inf=split /\t/,$line;
	my $temptax="";
	for(my $i=0;$i<=$#item;$i++){
		if($item[$i]=~/o__$inf[0]$/){
			$temptax=$item[$i];
			last;
		}
	}
	for(my $i=3;$i<$#inf;$i+=2){
		$all{$temptax}{$i}=$inf[$i];
	}
}
close IN;

open IN, "$prefix.P" or die "can not open file $prefix.P\n";
<IN>;
while($line=<IN>){
	chomp $line;@inf=split /\t/,$line;
	my $temptax="";
	for(my $i=0;$i<=$#item;$i++){
		if($item[$i]=~/p__$inf[0]$/){
			$temptax=$item[$i];
			last;
		}
	}
	for(my $i=3;$i<$#inf;$i+=2){
		$all{$temptax}{$i}=$inf[$i];
	}
}
close IN;

open IN, "$prefix.S" or die "can not open file $prefix.S\n";
<IN>;
while($line=<IN>){
	chomp $line;@inf=split /\t/,$line;
	my $temptax="";
	for(my $i=0;$i<=$#item;$i++){
		if($item[$i]=~/s__$inf[0]$/){
			$temptax=$item[$i];
			last;
		}
	}
	for(my $i=3;$i<$#inf;$i+=2){
		$all{$temptax}{$i}=$inf[$i];
	}
}
close IN;

print OA "ID";
foreach my $i (sort {$a<=>$b} keys %id){
	print OA "\t$id{$i}";
}
print OA "\tTaxonomy\n";
for(my $i=0;$i<$#item;$i++){
	print OA "Tax_$i";
	foreach my $j (sort {$a<=>$b} keys %id){
		print OA "\t$all{$item[$i]}{$j}";
	}
	print OA "\t$item[$i]\n";
}
close OA;

open IN, "$out.table" or "can not open $out.table\n";
open OD, ">$out.table.D" or "can not open $out.table.D\n";
open OP, ">$out.table.P" or "can not open $out.table.P\n";
open OC, ">$out.table.C" or "can not open $out.table.C\n";
open OO, ">$out.table.O" or "can not open $out.table.O\n";
open OF, ">$out.table.F" or "can not open $out.table.F\n";
open OG, ">$out.table.G" or "can not open $out.table.G\n";
open OS, ">$out.table.S" or "can not open $out.table.S\n";
$line=<IN>;chomp $line;@inf=split /\t/,$line;
$line=join("\t",@inf[1..$#inf-1]);
print OD "ID\t$line\n";
print OP "ID\t$line\n";
print OC "ID\t$line\n";
print OO "ID\t$line\n";
print OF "ID\t$line\n";
print OG "ID\t$line\n";
print OS "ID\t$line\n";
while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	my $temp=0;
	for(my $i=1;$i<=$#inf;$i++){
		$temp+=$inf[$i];
	}
	next if ($temp==0);
	$temp=join("\t",@inf[1..$#inf-1]);
	my @ele=split /; /,$inf[-1];
	if($ele[$#ele]=~/s__/){
		$ele[$#ele]=~s/s__//g;
		print OS "$ele[$#ele]\t$temp\n";
	}
	elsif($ele[$#ele]=~/g__/){
		$ele[$#ele]=~s/g__//g;
		print OG "$ele[$#ele]\t$temp\n";
	}
	elsif($ele[$#ele]=~/f__/){
		$ele[$#ele]=~s/f__//g;
		print OF "$ele[$#ele]\t$temp\n";
	}
	elsif($ele[$#ele]=~/o__/){
		$ele[$#ele]=~s/o__//g;
		print OO "$ele[$#ele]\t$temp\n";
	}
	elsif($ele[$#ele]=~/c__/){
		$ele[$#ele]=~s/c__//g;
		print OC "$ele[$#ele]\t$temp\n";
	}
	elsif($ele[$#ele]=~/p__/){
		$ele[$#ele]=~s/p__//g;
		print OP "$ele[$#ele]\t$temp\n";
	}
	elsif($ele[$#ele]=~/d__/){
		$ele[$#ele]=~s/d__//g;
		print OD "$ele[$#ele]\t$temp\n";
	}
}
close (IN,OD,OP,OC,OO,OF,OG,OS);

