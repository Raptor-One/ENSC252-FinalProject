LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

package systolic_package is
CONSTANT N : INTEGER := 8;
CONSTANT MATRIX_SIZE : UNSIGNED := "011"; -- not fully implemented as "generic"
TYPE bus_type IS ARRAY (0 to 2) OF UNSIGNED(N-1 DOWNTO 0);
end package systolic_package;

package body systolic_package is
--blank, include any implementations here, if necessary

end package body systolic_package;