library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity KaratsubaOfman is
    Generic(
	Size: natural := 64
    );
    Port ( 
        i_X  : in STD_LOGIC_VECTOR(Size-1 downto 0);
        i_Y  : in STD_LOGIC_VECTOR(Size-1 downto 0);
        o_XY : out STD_LOGIC_VECTOR(2*Size-1 downto 0)
    );
end KaratsubaOfman;

architecture RecursiveArchitecture of KaratsubaOfman is
  -- ADD1 e ADD2
  -- OK

  -- The two one-bit carryin of these additions are represented in by CX and CY respectively
  signal w_CIX : STD_LOGIC := '0';
  signal w_CIY : STD_LOGIC := '0';

  -- The two one-bit carryout of these additions are represented in by CX and CY respectively
  -- OK
  signal w_CX  : STD_LOGIC;
  signal w_CY  : STD_LOGIC;
  -- OK

  -- High X and High Y
  -- OK
  signal w_HX  : STD_LOGIC_VECTOR(Size/2-1 downto 0);
  signal w_HY  : STD_LOGIC_VECTOR(Size/2-1 downto 0);
  -- OK

  -- Low X and Low Y
  -- OK
  signal w_LX  : STD_LOGIC_VECTOR(Size/2-1 downto 0);
  signal w_LY  : STD_LOGIC_VECTOR(Size/2-1 downto 0);
  -- OK

  -- PRODUCTS
  signal w_P1  : STD_LOGIC_VECTOR(Size-1 downto 0);
  signal w_P2  : STD_LOGIC_VECTOR(Size-1 downto 0);
  signal w_P3  : STD_LOGIC_VECTOR(Size-1 downto 0);
  signal w_PRODUCT3 : STD_LOGIC_VECTOR(Size+1 downto 0);


  -- ADDER
  signal w_ADD1_X : STD_LOGIC_VECTOR(Size/2-1 downto 0);
  signal w_ADD2_Y : STD_LOGIC_VECTOR(Size/2-1 downto 0);


  BEGIN 
    -- High X and High Y

		  w_HX <= i_X(Size-1 downto Size/2);
        w_HY <= i_Y(Size-1 downto Size/2);
        w_LX <= i_X(Size/2-1 downto 0);
        w_LY <= i_Y(Size/2-1 downto 0);

    Termination: if Size <= 4 generate
    o_XY <= i_X * i_Y;
    --  TCell: entity work.FourBitsMultiplier
    --    generic map ( 
    --      p_K => Size
    --    )
    --   port map(
    --     i_X  => i_X,
    --     i_Y  => i_Y,
    --     o_XY => o_XY
    --    );
    end generate Termination;

    Recursion: if Size > 4 generate
      ADDl: entity work.Adder
        generic map ( 
          p_K => Size/2
        )
        port map(
          i_X1    => i_X(Size/2-1 downto 0),
          i_X2    => i_X(Size-1 downto Size/2),
          i_CARRY => w_CIX,
          o_XX    => w_ADD1_X, 
	       o_CARRY => w_CX
        );

       ADD2: entity work.Adder
        generic map ( 
          p_K => Size/2
        )
        port map(
          i_X1    => i_Y(Size/2-1 downto 0),
          i_X2    => i_Y(Size-1 downto Size/2),
          i_CARRY => w_CIY,
          o_XX    => w_ADD2_Y, 
	       o_CARRY => w_CY
        );

       KO1: entity work.KaratsubaOfman
         generic map (
           Size => Size/2
         )
         port map (
          i_X    => w_HX,
          i_Y    => w_HY,
          o_XY   => w_P1
        );

       KO2: entity work.KaratsubaOfman
         generic map (
           Size => Size/2
         )
         port map (
          i_X    => w_LX,
          i_Y    => w_LY,
          o_XY   => w_P2
        );

       KO3: entity work.KaratsubaOfman
         generic map (
           Size => Size/2
         )
         port map (
          i_X    => w_ADD1_X,
          i_Y    => w_ADD2_Y,
          o_XY   => w_P3
        );

       SA: entity work.ShiftnAdder
         generic map (
           p_K => Size/2
         )
         port map (
          i_SXL      => w_ADD1_X,
          i_SYL      => w_ADD2_Y,
	       i_CX       => w_CX,
          i_CY       => w_CY,
	       i_P        => w_P3,
          o_PRODUCT3 => w_PRODUCT3
        );

       SSA: entity work.ShifterSubnAdder
         generic map (
           p_K => Size/2
         )
         port map (
          i_PRODUCT1 => w_P1,
          i_PRODUCT2 => w_P2,
	       i_PRODUCT3 => w_PRODUCT3,
          o_XY       => o_XY
        );


    end generate Recursion;

end RecursiveArchitecture;