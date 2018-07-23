filename=$1
output=${filename:7:6}
echo $output
outputFIle=$output".txt"
echo $filename
echo $outputFIle
touch $outputFIle
echo "-----------------" > $outputFIle
awk -v oFile="$outputFIle" 'BEGIN{print oFile;}
{
i=index($7,"UDLR");
j=index($1,"check");
if(i>0)
	{		
		print $0 >> oFile;
	}
if(j>0)
	{		
		print $0 >> oFile;
		print "\n" >> oFile;
	}
}
END{}' $filename
