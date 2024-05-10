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

--top_basys3.vhd

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    Port (
        i_clk     : in  std_logic;  -- Clock input
        i_btnU    : in  std_logic;  -- Master reset button (btnU)
        i_btnC    : in  std_logic;  -- Center button to step through states
        i_switch  : in  std_logic_vector(7 downto 0);  -- Switches for input operands
        o_LED     : out std_logic_vector(15 downto 0); -- LEDs for status and flags
        o_sevenseg: out std_logic_vector(6 downto 0)   -- Seven-segment display output
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
    -- Declare components and signals
    signal r_A, r_B, r_result : signed(7 downto 0);
    signal r_op               : std_logic_vector(2 downto 0);
    signal r_state            : std_logic_vector(3 downto 0) := "0000"; -- State register
    signal r_hex_for_display  : unsigned(3 downto 0);  -- Store the value for display

    component ALU
        Port (
            i_A      : in  signed(7 downto 0);
            i_B      : in  signed(7 downto 0);
            i_op     : in  std_logic_vector(2 downto 0);
            o_result : out signed(7 downto 0);
            o_zero   : out std_logic;
            o_sign   : out std_logic
        );
    end component;
    
    component hex_to_sevenseg
        Port(
            i_hex      : in  unsigned(3 downto 0);
            o_sevenseg : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    -- PORT MAPS ----------------------------------------
    ALU_instance : ALU
        port map (
            i_A      => r_A,
            i_B      => r_B,
            i_op     => r_op,
            o_result => r_result,
            o_zero   => o_LED(14),
            o_sign   => o_LED(15)
        );

    -- Seven segment display driver for the result
    Disp_instance : hex_to_sevenseg
        port map (
            i_hex      => r_hex_for_display,
            o_sevenseg => o_sevenseg
        );

    -- CONCURRENT STATEMENTS ----------------------------
    -- FSM for handling the input and calculation logic
    process(i_clk, i_btnU)
    begin
        if i_btnU = '1' then
            r_state <= "0000";
            r_A <= (others => '0');
            r_B <= (others => '0');
            r_result <= (others => '0');
            r_hex_for_display <= (others => '0');
        elsif rising_edge(i_clk) then
            if i_btnC = '1' then
                case r_state is
                    when "0000" =>
                        r_A <= signed(i_switch); -- Load first operand
                        r_state <= "0001";
                    when "0001" =>
                        r_B <= signed(i_switch); -- Load second operand
                        r_state <= "0010";
                    when "0010" =>
                        r_op <= i_switch(2 downto 0); -- Set operation
                        r_state <= "0011";
                    when "0011" =>
                        r_state <= "0000"; -- Perform operation and display
                    when others =>
                        r_state <= "0000"; -- Reset to initial state
                end case;
            end if;
        end if;
    end process;

    -- Assign result to display
    r_hex_for_display <= unsigned(r_result(3 downto 0));

    -- Output LED indicators
    o_LED(0 downto 3) <= std_logic_vector(r_state);
    o_LED(13) <= '0'; -- Not used

end top_basys3_arch;