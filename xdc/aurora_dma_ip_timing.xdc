# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
#
#     http://www.solderpad.org/licenses/SHL-2.1
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Francelly Cano, BSC-CNS
# Date: 22.02.2022
# Description:
create_clock -period 10.000 -name sysclk0  [get_ports SYS_CLK0_P]
#create_clock -period 10.000 -name sysclk1  [get_ports SYS_CLK1_P]
#create_clock -period 10.000 -name sysclk3  [get_ports SYS_CLK3_P]
