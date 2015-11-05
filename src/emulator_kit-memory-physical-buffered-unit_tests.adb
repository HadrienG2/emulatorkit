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
            Output_Bytes : Byte_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Test_Bytes : constant Byte_Buffer (1 .. 2) := (42, 24);
            begin
               Buffer_Mem.Write (Test_Bytes (1), 0);
               Buffer_Mem.Write (Test_Bytes (2), 1);
               Buffer_Mem.Read (0, Output_Bytes (1));
               Buffer_Mem.Read (1, Output_Bytes (2));
               Test_Element_Property (Test_Bytes = Output_Bytes, "Writing bytes at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Test_Bytes : constant Byte_Buffer (1 .. 2) := (64, 46);
            begin
               Buffer_Mem.Write (Test_Bytes (1), Universal_Address (Buffer_Mem.Buffer_Size - 1));
               Buffer_Mem.Write (Test_Bytes (2), Universal_Address (Buffer_Mem.Buffer_Size - 2));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 1), Output_Bytes (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 2), Output_Bytes (2));
               Test_Element_Property (Test_Bytes = Output_Bytes, "Writing bytes at the end of memory should work");

               begin
                  Buffer_Mem.Write (Test_Bytes (1), Universal_Address (Buffer_Mem.Buffer_Size));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size), Output_Bytes (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test word I/O
         declare
            type Word_Buffer is array (Positive range <>) of Data_Types.Word;
            Output_Words : Word_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Test_Words : constant Word_Buffer (1 .. 2) := (42424, 24242);
            begin
               Buffer_Mem.Write (Test_Words (1), 0);
               Buffer_Mem.Write (Test_Words (2), 2);
               Buffer_Mem.Read (0, Output_Words (1));
               Buffer_Mem.Read (2, Output_Words (2));
               Test_Element_Property (Test_Words = Output_Words, "Writing words at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Test_Words : constant Word_Buffer (1 .. 2) := (64646, 46464);
            begin
               Buffer_Mem.Write (Test_Words (1), Universal_Address (Buffer_Mem.Buffer_Size - 2));
               Buffer_Mem.Write (Test_Words (2), Universal_Address (Buffer_Mem.Buffer_Size - 4));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 2), Output_Words (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 4), Output_Words (2));
               Test_Element_Property (Test_Words = Output_Words, "Writing words at the end of memory should work");

               begin
                  Buffer_Mem.Write (Test_Words (1), Universal_Address (Buffer_Mem.Buffer_Size - 1));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 1), Output_Words (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test doubleword I/O
         declare
            type Double_Word_Buffer is array (Positive range <>) of Data_Types.Double_Word;
            Output_Double_Words : Double_Word_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Test_Double_Words : constant Double_Word_Buffer (1 .. 2) := (123456789, 246813579);
            begin
               Buffer_Mem.Write (Test_Double_Words (1), 0);
               Buffer_Mem.Write (Test_Double_Words (2), 4);
               Buffer_Mem.Read (0, Output_Double_Words (1));
               Buffer_Mem.Read (4, Output_Double_Words (2));
               Test_Element_Property (Test_Double_Words = Output_Double_Words, "Writing doublewords at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Test_Double_Words : constant Double_Word_Buffer (1 .. 2) := (321987654, 129834765);
            begin
               Buffer_Mem.Write (Test_Double_Words (1), Universal_Address (Buffer_Mem.Buffer_Size - 4));
               Buffer_Mem.Write (Test_Double_Words (2), Universal_Address (Buffer_Mem.Buffer_Size - 8));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 4), Output_Double_Words (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 8), Output_Double_Words (2));
               Test_Element_Property (Test_Double_Words = Output_Double_Words, "Writing doublewords at the end of memory should work");

               begin
                  Buffer_Mem.Write (Test_Double_Words (1), Universal_Address (Buffer_Mem.Buffer_Size - 3));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 3), Output_Double_Words (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- Test quadword I/O
         declare
            type Quad_Word_Buffer is array (Positive range <>) of Data_Types.Quad_Word;
            Output_Quad_Words : Quad_Word_Buffer (1 .. 2);
         begin
            -- At the beginning of memory
            declare
               Test_Quad_Words : constant Quad_Word_Buffer (1 .. 2) := (16#FEDC_BA98_7654_3210#, 16#1357_9BDF_0246_8ACE#);
            begin
               Buffer_Mem.Write (Test_Quad_Words (1), 0);
               Buffer_Mem.Write (Test_Quad_Words (2), 8);
               Buffer_Mem.Read (0, Output_Quad_Words (1));
               Buffer_Mem.Read (8, Output_Quad_Words (2));
               Test_Element_Property (Test_Quad_Words = Output_Quad_Words, "Writing quadwords at the beginning of memory should work");
            end;

            -- At the end of memory (including out of bounds)
            declare
               Test_Quad_Words : constant Quad_Word_Buffer (1 .. 2) := (16#2468_ACE0_1357_9BDF#, 16#DEAD_BEEF_BADB_0053#);
            begin
               Buffer_Mem.Write (Test_Quad_Words (1), Universal_Address (Buffer_Mem.Buffer_Size - 8));
               Buffer_Mem.Write (Test_Quad_Words (2), Universal_Address (Buffer_Mem.Buffer_Size - 16));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 8), Output_Quad_Words (1));
               Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 16), Output_Quad_Words (2));
               Test_Element_Property (Test_Quad_Words = Output_Quad_Words, "Writing doublewords at the end of memory should work");

               begin
                  Buffer_Mem.Write (Test_Quad_Words (1), Universal_Address (Buffer_Mem.Buffer_Size - 7));
                  Fail_Test ("Writing beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;

               begin
                  Buffer_Mem.Read (Universal_Address (Buffer_Mem.Buffer_Size - 7), Output_Quad_Words (1));
                  Fail_Test ("Reading beyond the end of memory should raise an exception");
               exception
                  when Illegal_Address => null;
               end;
            end;
         end;

         -- TODO : Test 128-bit I/O
         -- TODO : Test 256-bit I/O
         -- TODO : Test single precision float I/O
         -- TODO : Test double precision float I/O
         -- TODO : Test extended precision float I/O

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
