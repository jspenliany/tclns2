
awk '
BEGIN{}

{
i=index($0,"vehicle=53");
if(i>0)
	{		

		print  >> "Routinecheck.txt";
	}
}

END{}' dataTMP070201.txt
