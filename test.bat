java -jar Mars.jar nc mc LargeText 100000 a dump .text HexText code.txt mips1.asm
java -jar Mars.jar db nc mc LargeText a dump 0x4180-0x6ffc HexText handler.txt mips1.asm
java -jar Mars.jar nc db lg ex mc LargeText 100000 mips1.asm > MARSOut.txt
cp mips_tb.v .\P7Source\
cd .\P7Source\
iverilog *.v
rm mips_tb.v
cd ..
rm a.out
move .\P7Source\a.out .
vvp a.out > CPUOut.txt