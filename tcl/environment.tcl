set g_vivado_version 2020.1 
set g_current_vivado_version [version -short] 
set g_fpga_part xcu280-fsvh2892-2L-e 
set g_project_name aurora_dma_ip           
set g_root_dir    [pwd]                     
set g_project_dir ${g_root_dir}/project    
set g_design_name ${g_project_name}          
set g_rtl_ext vhd 	  				  
set g_top_module  ${g_root_dir}/src/${g_project_name}_top.$g_rtl_ext
set g_useBlockDesign n 	  
