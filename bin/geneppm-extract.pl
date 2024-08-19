die "perl $0 species.txt gene.list taxonomy.table.S ppm.gene.txt1 ppm.gene.txt2\n" unless (@ARGV == 5);
my ($line,@inf,%species,$tempnull,%gene);

#read taxonomy(species) info
open IS,"$ARGV[2]" or die "can not open $ARGV[2]\n";
$line=<IS>;chomp $line;@inf=split /\t/,$line;
$tempnull="0";
for(my $i=2;$i<=$#inf;$i++){
	$tempnull.="\t0";
}
open IN,"$ARGV[0]" or die "can not open $ARGV[0]\n";
while($line=<IN>){
	chomp $line;
	$species{$line}=$tempnull;
}
close IN;
while($line=<IS>){
	chomp $line;
	@inf=split /\t/,$line;
	$inf[0]=~s/ /-/g;
	if(defined $species{$inf[0]}){
		$species{$inf[0]}=join("\t",@inf[1..$#inf]);
		#print "$inf[0]\t$species{$inf[0]}\n";
	}
}
close IS;

#read gene list
open IN,"$ARGV[1]" or die "can not open $ARGV[1]\n";
while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	my %temp=();
	for(my $i=0;$i<=$#inf;$i++){
		my @ele=split /_/,$inf[$i];
		$temp{$ele[0]}=0;
	}
	foreach my $i (sort keys %temp){
		$gene{$inf[0]}.=$i."\t";
	}
	#print "$inf[0]\t$gene{$inf[0]}\n";
}
close IN;

#add taxonomy abd to gene list
open IN,"$ARGV[3]" or die "can not open $ARGV[3]\n";
open OA,">$ARGV[4]" or die "can not open $ARGV[4]\n";
$line=<IN>;chomp $line;@inf=split /\t/,$line;
$line=join("\t",@inf[3..$#inf]);
print OA "Gene\tSubtype\tType\tSpecies\t$line\n";
while($line=<IN>){
	chomp $line;
	@inf=split /\t/,$line;
	my @genename=split /\t/,$gene{$inf[0]};
	for(my $i=0;$i<=$#genename;$i++){
		print OA "$inf[0]\t$inf[1]\t$inf[2]\t$genename[$i]";
		for(my $j=3;$j<=$#inf;$j++){
			my ($sum,$target)=(0,0);
			my @taxlist=split /\t/,$species{$genename[$i]};
			$target=$taxlist[$j-3];
			for(my $k=0;$k<=$#genename;$k++){
				@taxlist=split /\t/,$species{$genename[$k]};
				$sum+=$taxlist[$j-3];
			}
			if($sum>0){
				printf OA "\t%.8f",$target/$sum*$inf[$j];
			}
			else{
				printf OA "\t%.8f",$inf[$j]/(1+$#genename);
			}
		}
		print OA "\n";
	}
}
close IN;
close OA;
