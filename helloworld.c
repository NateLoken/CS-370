int x;
int y;
int arr[5];

func(int a, char* b, char* s)
{
   int local;
   a = 10;

   arr[1] = 2+3;
   arr[2] = 8+10;
   arr[3] = 1;
   arr[4] = 4;
   arr[5] = 5;
   
   
   printf("a = %d\n",a);
   
   local = 42+12;
   printf("local=%d\n",local);
   
    if (20>10) { puts("if works!\n"); }
   else { puts("else works!\n"); }
   if (20<10) { puts("if works!\n"); }
   else { puts("else works!\n"); }
}

main(int argc, char* argv)
{
    x = 0;
    while(x < 5) {
       puts("Spin me right round\n");
       x = x + 1;
    }
   func(42, "goodbye","third arg");
   printf("goodbye %s %d\n","second",42+4+x+2);
   puts("Hello World!\n");
   puts("Spin me right round\n");
   puts("Spin me right round\n");
   puts("Spin me right round\n");
   puts("Spin me right round\n");

 

}

localTest (int one, int two, int three, int four)
{
    int hey;
    int look;
    int variables;
}
