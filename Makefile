STD_CELLS = /afs/umich.edu/class/eecs627/ibm13/artisan/2005q3v1/aci/sc-x/verilog/ibm13_neg.v
# TESTBENCH = ../testbench/aes_engine_tb.sv
# TESTBENCH = conde_provo_testbench.sv
TESTBENCH = conde_prode_testbench.sv
# SIM_FILES = consumer_de.sv producer_vo.sv vo_if.svh
SIM_FILES = consumer_de.sv producer_de.sv vo_vo_fifo.sv cdvd_if.svh 

SIM_MN_FILES = consumer_multi_vo.sv producer_multi_vo.sv inf_temp.svh m_n_arbiter.sv ../verilog/psel_gen.sv ../verilog/onehot_translater.sv
MN_TESTBENCH = testbench.sv
# subBytes.sv subWords.sv key_expansion_stage.sv \
# inv_subBytes.sv inv_shiftRows.sv inv_mixColumns.sv inv_sbox.sv \
# sysdef.svh decryptRound.sv decryptLastRound.sv \
# aesRound.sv aesLastRound.sv \
# aes_engine.sv encryptLastRound.sv
# SIM_SYNTH_FILES = standard.vh ../syn/mult.syn.v

VV         = vcs
VVOPTS     = -o $@ +v2k +vc -sverilog -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays                    \
	       	+neg_tchk +incdir+$(VERIF) +plusarg_save +overlap +warn=noSDFCOM_UHICD,noSDFCOM_IWSBA,noSDFCOM_IANE,noSDFCOM_PONF -full64 -cc gcc +libext+.v+.vlib+.vh 

ifdef WAVES
VVOPTS += +define+DUMP_VCD=1 +memcbk +vcs+dumparrays +sdfverbose
endif

ifdef GUI
VVOPTS += -gui
endif

all: clean c_compile sim synth sim_synth

clean:
	rm -f verilog/ucli.key
	rm -f verilog/sim
	rm -f verilog/sim_synth
	rm -fr verilog/sim.daidir
	rm -fr verilog/sim_synth.daidir
	rm -f verilog/*.log
	rm -fr verilog/csrc
	rm -f verilog/goldenbrick.txt
	rm -f verilog/testbench.txt
	rm -f verilog/testbench_functional.txt
	rm -f verilog/testbench_structural.txt
	rm -f verilog/inter.*
	rm -f verilog/inter.fsdb.field
	rm -f verilog/novas.*
	rm -f verilog/verdi* -r
	rm -f goldenbrick/goldenbrick
	rm -f goldenbrick/goldenbrick.txt
	rm -f -r syn/dwsvf_*
	rm -f -r run/*

.PHONY: goldenbrick
goldenbrick:
	cd goldenbrick; python3 aes_gentb.py

behavioral_check: goldenbrick sim
	diff run/aes_out.txt run/encrypt_goldenbrick_out.txt | tee run/diff_functional.txt

sim:
	cd verilog; $(VV) $(VVOPTS) $(SIM_FILES) $(TESTBENCH); ./$@; cd ..

sim_interface:
	cd basejump_stl; $(VV) $(VVOPTS) $(SIM_FILES) $(TESTBENCH); ./$@; cd ..

sim_m_n_int:
	cd m_n_communication; $(VV) $(VVOPTS) $(SIM_MN_FILES) $(MN_TESTBENCH); ./$@; cd..

verdi: 
	cd verilog; $(VV) $(VVOPTS) -debug_access+r -kdb $(SIM_FILES) $(TESTBENCH); ./$@ -gui=verdi -verdi_opts "-ultra"

slack:
	grep --color=auto "slack" syn/*.rpt
	# grep --color=auto "Path Group: " syn/*.rpt
.PHONY: slack

syn_one_hot_rec:
	cd syn; dc_shell -tcl_mode -xg_mode -f onehot_translator.syn.tcl | tee output.txt 

syn_one_hot:
	cd syn; dc_shell -tcl_mode -xg_mode -f onehot_translater.syn.tcl | tee output.txt 

sim_synth:
	cp goldenbrick/goldenbrick.txt verilog/goldenbrick.txt
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_SYNTH_FILES) $(TESTBENCH); ./$@
	diff verilog/goldenbrick.txt verilog/testbench.txt | tee verilog/diff_structural.txt
	cp verilog/testbench.txt verilog/testbench_structural.txt
