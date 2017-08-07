all:
	ca65 -t nes --feature force_range src\_object_test.asm -o object_test.o
	ld65 -C object_test.cfg object_test.o -o object_test.nes
