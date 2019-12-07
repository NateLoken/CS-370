int x;
int y;

func(int a, char* b, char* s)
{
   if(42>21) {
      puts("if works!");
   }
   
   x = 0;
   
   while( x < 10 ) {
      printf( "%d ", x );
      x = x + 1;
   }
   
}

main()
{

   func();
   puts("");
   if(21!=42) {
      puts("not-equals works!");
   }
   
   if (21==21) {
      puts("equals-equals works!");
   }
   
   if(21>42) {
      puts("if shouldn't work...");
   } else {
      puts ("else works!");
   }
   
   printf("goodbye %s %d\n","second",42+4+x+2);
   puts("Hello World!\n");
}
