//+
//Ввести с клавиатуры строку символов. Программа должна определить длину введенной 
//строки, и, если длина L = 10, то удаляются все A..Z
//97-122

#include <stdio.h>
#include <string.h>
 
void main(void)
{
    char myString[100];
    char toDel[100];
    char Letters[26];
    char let, flag, count_l;
 
    printf( "Enter your string: " );
 
    fgets( myString, 100, stdin ); 
 
    char count;
    for ( count = 0; count < 100; count++ )
    {
        if ( myString[count] == '\n' )
        {
            myString[count] = '\0';
            break;
        }
    }

    printf( "\nThe length of your string: %d", strlen(myString));

	if (strlen(myString) % 10 == 0)
	    {
			let = 64;
		    for (count_l = 0; count_l <= 25; count_l++)
		    {
				Letters[count_l] = let;
		    	let++;
		    }

		    flag = 0;
			for (count = 0; count < (strlen(myString)-1); count++) 
	    		for (count_l = 0; count_l <= 25; count_l++)
				{	
					if (myString[count] == Letters[count_l])
					{	
						toDel[flag] = count;
						flag++;
						break;
					}
				}	
			
			printf("\nElements: ");
			for (count = 0; count < flag; count++)	
				printf(" %d ", toDel[count] + 1);

			printf("\nYour new line : ");	
			for (count = 0; count < strlen(myString); count++)
				if (myString[count] >= 97 && myString[count] <= 122)
					printf("%c", myString[count]);
		}
}   	