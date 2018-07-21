filename=$1
output=${filename:7:6}
echo $output
outputFIle="$output"".txt"
echo $filename
echo $outputFIle
touch $outputFIle
awk '
BEGIN{}
{
i=index($1,"TAVRagent");
j=index($1,"check");
if(i>0)
	{		
#		echo $0 >> $outputFIle;
	}
if(j>0)
	{		
#		print $0 >> $outputFIle;
#		print "\n" >> $outputFIle;
	}
}
END{echo "what are you doing" >> $outputFIle;}' $filename
