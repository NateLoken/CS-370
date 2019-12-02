int x;
int y;

func( int a, char* b, char* s )
{
   puts("Hello World\n");
   x = 2;
   printf("x = %d\n", x);
}

main( int argc, char* argv )
{
   func(42 , "adios", "extra");
   printf("goodbye %s %d\n", "second", 42+4+x+1 );
   puts("Second Hello World!\n");
}
