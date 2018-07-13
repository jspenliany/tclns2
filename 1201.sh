
awk '
BEGIN{}

{
i=index($1,"TAVRagent");
j=index($1,"check");
if(i>0)
	{		
		print $0 >> "071306.txt";
	}
if(j>0)
	{		
		print $0 >> "071306.txt";
		print "\n" >> "071306.txt";
	}
}

END{}' dataTMP071306.txt
