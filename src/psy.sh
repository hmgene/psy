

cluster(){
usage="
$FUNCNAME <tag>:<cleavage.bed> [<tag>:<cleavage.bed>] [options]
 [options] :
	d=<int> : minimum distance 
"
perl -e 'use strict;
	sub getv{ my ($x)=@_; return defined $x ? $x : 0;}
	my $d=1; map{ if($_=~/d=(\d+)/){ $d=$1;}} @ARGV;
	my %res=();
	my %res_tot=();
	my %col=();
	foreach my $tag_file (@ARGV){ my ($tag,$file) = split/:/,$tag_file;
		next unless -e $file;
		open(my $fh,"<",$file) or die "$file not exits: $!";
		while(<$fh>){ chomp; my @a=split/\t/,$_; next if($#a < 5);
			$res{$a[5]}{$a[0]}{$a[1]}{$tag} += $a[4];
			$res_tot{$a[5]}{$a[0]}{$a[1]} += $a[4];
			$col{$tag} ++;
		}
		close($fh);
	}
	my @cols=sort keys %col;
	print "chrom\tstart\tend\tx\ty\tstrand\t",join("\t",map{ "y.$_"} @cols),"\n";
	foreach my $strand (keys %res){
	foreach my $chrom (keys %{$res{$strand}}){
		my @ss=sort {$a<=>$b} keys %{$res{$strand}{$chrom}};
		push @ss,$ss[$#ss] + $d + 1; ## padding 
		my $i=0; for(my $j=1; $j <= $#ss; $j++){
			if($ss[$j] - $ss[$j-1] > $d){
				my @x=@ss[$i..($j-1)]; 
				print $chrom,"\t",$x[0],"\t",$x[$#x]+1;
				print "\t",join(",",map{ $_ - $x[0] } @x);
				print "\t",join(",",map{ $res_tot{$strand}{$chrom}{$_} } @x);
				print "\t$strand";
				foreach my $cl (@cols){ 
					my @y=map { getv( $res{$strand}{$chrom}{$_}{$cl} ) } @x;
					print "\t",join(",",@y);
				}
				print "\n";
				$i=$j;
			}	
		}
	}}

' $@
}

cluster__test(){
echo \
"chr1	1	2	a	1	+
chr1	2	3	a	2	+
chr1	3	4	b	11	+
chr1	6	7	a	3	+
chr1	8	9	a	3	+
chr1	9	10	b	12	+" > tmp.a

echo \
"chr1	1	2	a	1	+
chr1	2	3	a	2	+
chr1	8	9	a	3	+
chr1	9	10	b	12	+" > tmp.b
cluster a:tmp.a b:tmp.b d=2 
}

