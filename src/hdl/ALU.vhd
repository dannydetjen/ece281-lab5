--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|     SUB     001
--|     see resct in architecture
--|
--|
--+----------------------------------------------------------------------------
-- ALU.vhd
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
-- TODO
    Port (
        i_A      : in  unsigned(7 downto 0);
        i_B      : in  unsigned(7 downto 0);
        i_op     : in  std_logic_vector(2 downto 0);
        o_result : buffer unsigned(7 downto 0);
        o_zero   : out std_logic;
        o_sign   : out std_logic
    );
end ALU;

architecture behavioral of ALU is 
	-- declare components and signals
	--already declared? I think so.
	--if anyone is ever reading this, hi!
begin
        process(i_A, i_B, i_op)
        begin
            case i_op is
                when "000" =>  -- Addition
                    o_result <= i_A + i_B;
                when "001" =>  -- Subtraction
                    o_result <= i_A - i_B;
                when "010" =>  -- Bit-wise OR
                    o_result <= i_A or i_B;
                when "011" =>  -- Bit-wise AND
                    o_result <= i_A and i_B;
                when "100" =>  -- Left Logical Shift
                    o_result <= i_A sll to_integer(unsigned(i_B(2 downto 0)));
                when "101" =>  -- Right Logical Shift
                    o_result <= i_A srl to_integer(unsigned(i_B(2 downto 0)));
                when others =>
                    o_result <= (others => '0'); -- Default or invalid opcode
            end case;
            -- Set zero and sign flags
            if o_result = 0 then
                        o_zero <= '1';
                    else
                        o_zero <= '0';
                    end if;
            
                    if o_result(7) = '1' then  -- Check MSB for sign
                        o_sign <= '1';
                    else
                        o_sign <= '0';
                    end if;
        end process;
	-- PORT MAPS ----------------------------------------

	--no.
	
	-- CONCURRENT STATEMENTS ----------------------------
end behavioral;
