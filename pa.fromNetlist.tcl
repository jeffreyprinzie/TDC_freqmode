
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name demo_atlys -dir "/home/jeffrey/projects/work/planAhead_run_3" -part xc6slx45csg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/jeffrey/projects/work/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/jeffrey/projects/work} {ipcore_dir} {source/TDC/ipcore_dir} }
add_files [list {ipcore_dir/tri_mode_eth_mac_v5_4.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/mac_fifo_axi4.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {source/TDC/ipcore_dir/hitFIFO.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {source/TDC/ipcore_dir/hitRam.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "/home/jeffrey/projects/ipbus_2_0_v1/firmware/example_designs/ucf/atlys.ucf" [current_fileset -constrset]
add_files [list {/home/jeffrey/projects/ipbus_2_0_v1/firmware/example_designs/ucf/atlys.ucf}] -fileset [get_property constrset [current_run]]
link_design
