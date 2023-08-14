ROOT_DIR  = $(PWD)
IP_DIR    = $(ROOT_DIR)/ip/aurora_dma_ip
# taking default Xilinx install path if not propagated from environment var
VIVADO_VER    ?= 2021.2
XILINX_VIVADO ?= /opt/Xilinx/Vivado/$(VIVADO_VER)/
VIVADO_XLNX   := $(XILINX_VIVADO)/bin/vivado
VIVADO_OPT  := -mode batch -nolog -nojournal -notrace -source


#Generate the Aurora DMA IP

generate_ip:
		echo "Generate Aurora DMA IP"
		$(VIVADO_XLNX) $(VIVADO_OPT)  ./tcl/gen_project.tcl


clean:
	git clean -fdx
