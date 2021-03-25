#!/usr/bin/make -f

# https://rosettacode.org/wiki/Topological_sort

# facultatives options
MAKEFLAGS += --no-builtin-rules --no-builtin-variables --warn-undefined-variables

# flag un-orderable dependencies when when CYCLE is defined

des_system_lib :=  std synopsys std_cell_lib des_system_lib dw02 dw01 ramlib ieee
dw01 :=            ieee dw01 dware gtech $(if $(CYCLE), dw04)
dw02 :=            ieee dw02 dware
dw03 :=            std synopsys dware dw03 dw02 dw01 ieee gtech
dw04 :=            dw04 ieee dw01 dware gtech
dw05 :=            dw05 ieee dware
dw06 :=            dw06 ieee dware
dw07 :=            ieee dware
dware :=           ieee dware
gtech :=           ieee gtech
ramlib :=          std ieee
std_cell_lib :=    ieee std_cell_lib
synopsys :=

# extract lib list via introspection
U := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
libs := $(sort $(filter-out $(foreach _, $U, %$_), $(subst .file,,$(filter %.file, $(foreach _, $(.VARIABLES), $_.$(origin $_))))))

# not all deps are in lib list
deps := $(filter-out $(libs), $(sort $(foreach _, $(libs), $($_))))

# use make to order dependencies
main: $(libs)

# ignore self dependencies
$(foreach _, $(libs), $(eval $_: $(filter-out $_, $($_))))

# echo lib or dep when reached
$(libs) $(deps):; @echo $@

# avoid Makefile self dependency (help when using -d)
$(MAKEFILE_LIST):;
