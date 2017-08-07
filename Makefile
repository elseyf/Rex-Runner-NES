NAME = rex_runner

AS = ca65
LN = cl65

CFG_FILE= $(wildcard *.cfg)

ASM_FLAGS= -g --feature force_range
LN_FLAGS= -C $(CFG_FILE)

SRC_ASM=  $(wildcard src/_$(NAME).asm)
OBJ= $(SRC_ASM:%.asm=%.o)
OBJ_LIST= $(wildcard *.o)

#Clean Files, Build Project:
all: compile link

#Build Project:
compile:
	make $(OBJ)

#Link Files:
link:
	$(LN) $(LN_FLAGS) $(OBJ_LIST) -o $(NAME).nes nes.lib
#File Creation:
%.o: %.asm
	$(AS) -t nes $(ASM_FLAGS) $< -o $(@F)
