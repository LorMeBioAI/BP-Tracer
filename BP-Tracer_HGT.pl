#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Cwd qw(getcwd);
use File::Basename;

# 添加参数模块
my $file;
my $pwd = "./";
my $threads = 40;
GetOptions(
    'file=s' => \$file,
    'pwd=s' => \$pwd,
    'threads=i' => \$threads
);

# 软件的路径
my ($abs_path,$abs_file) = fileparse($file);
my $abs = $abs_path || ".";
my $abs_db = "$abs/DB_HGT";

print "The PWD of workplace is: $abs\n";
print "The PWD of otu file is: $abs_file\n";

# 创建文件夹，定义输出路径
mkdir($pwd);
chdir($pwd) or die "Cannot change to directory: $pwd\n";
mkdir("BP-Tracer_HGT");
mkdir("shell");

# 读取文件
open(my $fh,"<",$file) or die "Cannot open file: $file\n";
my @raw_fq_list = <$fh>;
close($fh);

# 生成 shell 文件
foreach my $line (@raw_fq_list){
    chomp($line);
    my ($ID, $contig) = split("\t", $line);
    my $mode = "S01.1.$ID{}";
    open(my $f, ">", "shell/$mode.HGT.sh") or die "Cannot create file: shell/$mode.HGT.sh\n";
    my $content = "
cd $pwd
cd BP-Tracer_HGT
waafle_search --threads $threads $contig $abs_db/UnigeneSet-waafledb.v1.fa --out $ID.blastout;
waafle_genecaller $ID.blastout;
# 自动生成$ID.gff
waafle_orgscorer $contig $ID.blastout $ID.gff $abs_db/UnigeneSet-waafledb.v1.taxonomy
";
    print $f $content;
    close($f);
}

sub mkdir{
    my ($path) = @_;
    unless(-d $path){
        mkdir($path) or die "Cannot create directory: $path\n";
        print "---  new folder...  ---\n";
    }
    else{
        print "---  There is this folder!  ---\n";
    }
}

