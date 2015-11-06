with Emulator_Kit.Debug.Test;
with Emulator_Kit.Memory.Physical.Buffered; pragma Elaborate (Emulator_Kit.Memory.Physical.Buffered); -- DEBUG : GNAT currently cannot figure this out on its own

package body Emulator_Kit.Memory.Physical.Buffered.Unit_Tests is

   procedure Run_Tests is
      use Emulator_Kit.Debug.Test;

      procedure Test_Buffer_Memory is
         Buffer_Mem : Buffer_Memory (256); -- This amount of memory makes for nice test patterns
         subtype Byte_Buffer_Index is Byte_Buffers.Byte_Buffer_Index;
         use type Byte_Buffer_Index;
      begin
         -- Test byte I/O
         declare
            subtype Byte_Buffer is Byte_Buffers.Byte_Buffer;
            use type Byte_Buffer;
            Output : Byte_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant Byte_Buffer (1 .. 2) := (42, 24);
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 1);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (1, Output (2));
               Test_Element_Property (Input = Output, "Writing bytes at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant Byte_Buffer (1 .. 2) := (64, 46);
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 1));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 2));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 1), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 2), Output (2));
               Test_Element_Property (Input = Output, "Writing bytes at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test word I/O
         declare
            type Word_Buffer is array (Positive range <>) of Data_Types.Word;
            Output : Word_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant Word_Buffer (1 .. 2) := (42424, 24242);
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 2);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (2, Output (2));
               Test_Element_Property (Input = Output, "Writing words at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant Word_Buffer (1 .. 2) := (64646, 46464);
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 2));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 4));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 2), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 4), Output (2));
               Test_Element_Property (Input = Output, "Writing words at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 1));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 1), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test doubleword I/O
         declare
            type Double_Word_Buffer is array (Positive range <>) of Data_Types.Double_Word;
            Output : Double_Word_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant Double_Word_Buffer (1 .. 2) := (123456789, 246813579);
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 4);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (4, Output (2));
               Test_Element_Property (Input = Output, "Writing doublewords at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant Double_Word_Buffer (1 .. 2) := (321987654, 129834765);
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 4));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 8));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 4), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 8), Output (2));
               Test_Element_Property (Input = Output, "Writing doublewords at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 3));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 3), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test quadword I/O
         declare
            type Quad_Word_Buffer is array (Positive range <>) of Data_Types.Quad_Word;
            Output : Quad_Word_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant Quad_Word_Buffer (1 .. 2) := (16#FEDC_BA98_7654_3210#, 16#1357_9BDF_0246_8ACE#);
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 8);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (8, Output (2));
               Test_Element_Property (Input = Output, "Writing quadwords at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant Quad_Word_Buffer (1 .. 2) := (16#2468_ACE0_1357_9BDF#, 16#DEAD_BEEF_BADB_0053#);
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 8));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 16));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 8), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 16), Output (2));
               Test_Element_Property (Input = Output, "Writing quadwords at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 7));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 7), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test 128-bit I/O
         declare
            subtype SIMD128 is Data_Types.Two_Quad_Words;
            type SIMD128_Buffer is array (Positive range <>) of SIMD128;
            Output : SIMD128_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant SIMD128_Buffer (1 .. 2) := ((16#9841_1651_6987_3689#, 16#9473_3489_3646_9473#),
                                                            (16#3469_7463_4639_1026#, 16#0426_3644_1296_0017#));
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 16);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (16, Output (2));
               Test_Element_Property (Input = Output, "Writing two-quadwords at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant SIMD128_Buffer (1 .. 2) := ((16#7996_6423_9847_1234#, 16#9745_5494_1664_ABCD#),
                                                            (16#ABCD_EF94_2161_0633#, 16#9461_BC66_1664_6412#));
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 16));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 32));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 16), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 32), Output (2));
               Test_Element_Property (Input = Output, "Writing two-quadwords at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 15));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 15), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test 256-bit I/O
         declare
            subtype SIMD256 is Data_Types.Four_Quad_Words;
            type SIMD256_Buffer is array (Positive range <>) of SIMD256;
            Output : SIMD256_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant SIMD256_Buffer (1 .. 2) := ((16#ABCD_EF94_2161_0633#, 16#9461_BC66_1664_6412#, 16#7996_6423_9847_1234#, 16#9745_5494_1664_EF01#),
                                                            (16#3469_7463_4639_1026#, 16#0426_3644_1296_0017#, 16#9841_1651_6987_3689#, 16#9473_3489_3646_9473#));
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 32);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (32, Output (2));
               Test_Element_Property (Input = Output, "Writing four-quadwords at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant SIMD256_Buffer (1 .. 2) := ((16#6894_1967_A261_CD26#, 16#1494_FB16_5649_0644#, 16#ACD1_2644_0694_1144#, 16#6649_6265_1669_46FD#),
                                                            (16#1611_8218_4648_DDFA#, 16#9751_3140_9751_BCDF#, 16#6746_1721_9865_4216#, 16#5496_4658_4651_654E#));
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 32));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 64));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 32), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 64), Output (2));
               Test_Element_Property (Input = Output, "Writing four-quadwords at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 31));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 31), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test single precision float I/O
         declare
            type Float_Single_Buffer is array (Positive range <>) of Data_Types.Float_Single;
            Output : Float_Single_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant Float_Single_Buffer (1 .. 2) := (42.42, 12.34);
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 4);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (4, Output (2));
               Test_Element_Property (Input = Output, "Writing single-precision floats at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant Float_Single_Buffer (1 .. 2) := (76.54, 32.18);
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 4));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 8));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 4), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 8), Output (2));
               Test_Element_Property (Input = Output, "Writing single-precision floats at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 3));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 3), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- TODO : Test double precision float I/O
         declare
            type Float_Double_Buffer is array (Positive range <>) of Data_Types.Float_Double;
            Output : Float_Double_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant Float_Double_Buffer (1 .. 2) := (123.4567, 890.1234);
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 8);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (8, Output (2));
               Test_Element_Property (Input = Output, "Writing double-precision floats at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant Float_Double_Buffer (1 .. 2) := (567.8901, 234.5678);
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 8));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 16));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 8), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 16), Output (2));
               Test_Element_Property (Input = Output, "Writing double-precision floats at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 7));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 7), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test extended precision float I/O (with 128-bit alignment)
         declare
            type Float_Extended_Buffer is array (Positive range <>) of Data_Types.Float_Extended;
            Output : Float_Extended_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Input : constant Float_Extended_Buffer (1 .. 2) := ((Fraction => 16#1691_6533_ABC2_6513#, Integer_Bit => False, Exponent => 16#2568#, Sign_Bit => True),
                                                                   (Fraction => 16#7615_6161_6135_2137#, Integer_Bit => False, Exponent => 16#5313#, Sign_Bit => False));
            begin
               Buffer_Mem.Write (Input (1), 0);
               Buffer_Mem.Write (Input (2), 16);
               Buffer_Mem.Read (0, Output (1));
               Buffer_Mem.Read (16, Output (2));
               Test_Element_Property (Input = Output, "Writing extended-precision floats at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Input : constant Float_Extended_Buffer (1 .. 2) := ((Fraction => 16#7496_1616_1312_4163#, Integer_Bit => False, Exponent => 16#6414#, Sign_Bit => True),
                                                                   (Fraction => 16#3156_3161_4651_6514#, Integer_Bit => False, Exponent => 16#3541#, Sign_Bit => False));
            begin
               Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 16));
               Buffer_Mem.Write (Input (2), Universal_Address (Buffer_Mem.Buffer_Size - 32));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 16), Output (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 32), Output (2));
               Test_Element_Property (Input = Output, "Writing extended-precision floats at the end of memory should work");

               begin
                  Buffer_Mem.Write (Input (1), Universal_Address (Buffer_Mem.Buffer_Size - 15));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 15), Output (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- TODO : Test asynchronous byte transfers
         -- TODO : Test asynchronous byte streams
         Fail_Test ("This test suite is not extensive enough yet");
      end Test_Buffer_Memory;

      procedure Test_Buffered_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Buffer_Memory"), Test_Buffer_Memory'Access);
      end Test_Buffered_Package;
   begin
      Test_Package (To_Entity_Name ("Memory.Physical.Buffered"), Test_Buffered_Package'Access);
   end Run_Tests;

end Emulator_Kit.Memory.Physical.Buffered.Unit_Tests;
