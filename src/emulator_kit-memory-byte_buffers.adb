-- Copyright 2015 Hadrien Grasland
--
-- This file is part of EmulatorKit.
--
-- EmulatorKit is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- EmulatorKit is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with EmulatorKit.  If not, see <http://www.gnu.org/licenses/>.

with Emulator_Kit.Debug.Test;
with System.Machine_Code;

package body Emulator_Kit.Memory.Byte_Buffers is

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Word) is
      type Byte_Access is access all Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movw %0, (%1)",
                               Inputs => (Data_Types.Word'Asm_Input ("r", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory",
                               Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Double_Word) is
      type Byte_Access is access all Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movl %0, (%1)",
                               Inputs => (Data_Types.Double_Word'Asm_Input ("r", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory",
                               Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Quad_Word) is
      type Byte_Access is access all Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movq %0, (%1)",
                               Inputs => (Data_Types.Quad_Word'Asm_Input ("r", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory",
                               Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Two_Quad_Words_Access_Const) is
      type Byte_Access is access all Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movdqa (%0), %%xmm0;" &
                                           "movdqu %%xmm0, (%1)",
                               Inputs => (Data_Types.Two_Quad_Words_Access_Const'Asm_Input ("r", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory xmm0",
                               Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Four_Quad_Words_Access_Const) is
      type Byte_Access is access all Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "vmovdqa (%0), %%ymm0;" &
                                           "vmovdqu %%ymm0, (%1)",
                               Inputs => (Data_Types.Four_Quad_Words_Access_Const'Asm_Input ("r", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory ymm0",
                               Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Float_Single) is
      type Byte_Access is access all Data_Types.Byte;
      St0_Contents : Data_Types.Float_Single; -- See below
   begin
      -- DEBUG : This asm statement is needlessly inefficient. It is made necessary by GNAT's apparent lack of support for x87 clobbers
      System.Machine_Code.Asm (Template => "fstps (%2);",
                               Outputs => Data_Types.Float_Single'Asm_Output ("=t", St0_Contents),
                               Inputs => (Data_Types.Float_Single'Asm_Input ("0", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory",
                               Volatile => True);
      -- DEBUG : This is the asm statement that would best match my intent, if it were legal
--        System.Machine_Code.Asm (Template => "fstps (%1)",
--                                 Inputs => (Data_Types.Float_Single'Asm_Input ("t", Input),
--                                            Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
--                                 Clobber => "memory st(0)",
--                                 Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Float_Double) is
      type Byte_Access is access all Data_Types.Byte;
      St0_Contents : Data_Types.Float_Double; -- See below
   begin
      -- DEBUG : This asm statement is needlessly inefficient. It is made necessary by GNAT's apparent lack of support for x87 clobbers
      System.Machine_Code.Asm (Template => "fstpl (%2);",
                               Outputs => Data_Types.Float_Double'Asm_Output ("=t", St0_Contents),
                               Inputs => (Data_Types.Float_Double'Asm_Input ("0", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory",
                               Volatile => True);
      -- DEBUG : This is the asm statement that would best match my intent, if it were legal
--        System.Machine_Code.Asm (Template => "fstpl (%1)",
--                                 Inputs => (Data_Types.Float_Double'Asm_Input ("t", Input),
--                                            Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
--                                 Clobber => "memory st(0)",
--                                 Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Float_Extended_Access_Const) is
      type Byte_Access is access all Data_Types.Byte;
      St0_Contents : Data_Types.Float_Double; -- See below
   begin
      -- DEBUG : This asm statement is needlessly inefficient. It is made necessary by GNAT's apparent lack of support for x87 clobbers
      System.Machine_Code.Asm (Template => "fldt (%1);" &
                                           "fstpt (%2)",
                               Outputs => Data_Types.Float_Double'Asm_Output ("=t", St0_Contents),
                               Inputs => (Data_Types.Float_Extended_Access_Const'Asm_Input ("r", Input),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory",
                               Volatile => True);
      -- DEBUG : This is the asm statement that would best match my intent, if it were legal
--        System.Machine_Code.Asm (Template => "fldt (%0);" &
--                                             "fstpt (%1)",
--                                 Inputs => (Data_Types.Float_Extended_Access_Const'Asm_Input ("r", Input),
--                                            Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
--                                 Clobber => "memory st(0)",
--                                 Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Word) is
      type Byte_Access_Const is access constant Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movw (%1), %0",
                               Outputs => Data_Types.Word'Asm_Output ("=r", Output),
                               Inputs => Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access));
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Double_Word) is
      type Byte_Access_Const is access constant Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movl (%1), %0",
                               Outputs => Data_Types.Double_Word'Asm_Output ("=r", Output),
                               Inputs => Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access));
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Quad_Word) is
      type Byte_Access_Const is access constant Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movq (%1), %0",
                               Outputs => Data_Types.Quad_Word'Asm_Output ("=r", Output),
                               Inputs => Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access));
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : Data_Types.Two_Quad_Words_Access) is
      type Byte_Access_Const is access constant Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "movdqu (%1), %%xmm0;" &
                                           "movdqa %%xmm0, (%0)",
                               Inputs => (Data_Types.Two_Quad_Words_Access'Asm_Input ("r", Output),
                                          Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory xmm0",
                               Volatile => True);
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : Data_Types.Four_Quad_Words_Access) is
      type Byte_Access_Const is access constant Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "vmovdqu (%1), %%ymm0;" &
                                           "vmovdqa %%ymm0, (%0)",
                               Inputs => (Data_Types.Four_Quad_Words_Access'Asm_Input ("r", Output),
                                          Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory ymm0",
                               Volatile => True);
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Float_Single) is
      type Byte_Access_Const is access constant Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "flds (%1)",
                               Outputs => Data_Types.Float_Single'Asm_Output ("=t", Output),
                               Inputs => Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access));
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Float_Double) is
      type Byte_Access_Const is access constant Data_Types.Byte;
   begin
      System.Machine_Code.Asm (Template => "fldl (%1)",
                               Outputs => Data_Types.Float_Double'Asm_Output ("=t", Output),
                               Inputs => Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access));
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : Data_Types.Float_Extended_Access) is
      type Byte_Access_Const is access constant Data_Types.Byte;
      St0_Contents : Data_Types.Float_Double; -- See below
   begin
      -- DEBUG : This asm statement is needlessly inefficient. It is made necessary by GNAT's apparent lack of support for x87 clobbers
      System.Machine_Code.Asm (Template => "fldt (%2);" &
                                           "fstpt (%1)",
                               Outputs => Data_Types.Float_Double'Asm_Output ("=t", St0_Contents),
                               Inputs => (Data_Types.Float_Extended_Access'Asm_Input ("r", Output),
                                          Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory",
                               Volatile => True);
      -- DEBUG : This is the asm statement that would best match my intent, if it were legal
--        System.Machine_Code.Asm (Template => "fldt (%1);" &
--                                             "fstpt (%0)",
--                                 Inputs => (Data_Types.Float_Extended_Access'Asm_Input ("r", Output),
--                                            Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access)),
--                                 Clobber => "memory st(0)",
--                                 Volatile => True);
   end Unchecked_Read;

   procedure Test is
      use Emulator_Kit.Debug.Test;

      procedure Test_Byte_Buffer is
      begin
         -- Test word I/O
         declare
            subtype Word is Emulator_Kit.Data_Types.Word;
            use type Word;
            Buffer : Byte_Buffer (5 .. 8) := (others => 42);
            Output : Word;
         begin
            -- At the beginning of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 1) := (33, 255);
               Input : constant Word :=
                 (2 ** (0 * 8)) * Word (Bytes (0)) +
                   (2 ** (1 * 8)) * Word (Bytes (1));
            begin
               Unchecked_Write (Buffer, 5, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing words at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 5, Output);
               Test_Element_Property (Output = Input, "Reading words from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 1) := (63, 145);
               Input : constant Word :=
                 (2 ** (0 * 8)) * Word (Bytes (0)) +
                   (2 ** (1 * 8)) * Word (Bytes (1));
            begin
               Unchecked_Write (Buffer, 7, Input);
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing words at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 7, Output);
               Test_Element_Property (Output = Input, "Reading words from the beginning of byte buffers should work");
            end;
         end;

         -- Test doubleword I/O
         declare
            subtype Double_Word is Emulator_Kit.Data_Types.Double_Word;
            use type Double_Word;
            Buffer : Byte_Buffer (53 .. 58) := (others => 42);
            Output : Double_Word;
         begin
            -- At the beginning of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 3) := (12, 67, 255, 133);
               Input : constant Double_Word :=
                 (2 ** (0 * 8)) * Double_Word (Bytes (0)) +
                   (2 ** (1 * 8)) * Double_Word (Bytes (1)) +
                     (2 ** (2 * 8)) * Double_Word (Bytes (2)) +
                       (2 ** (3 * 8)) * Double_Word (Bytes (3));
            begin
               Unchecked_Write (Buffer, 53, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing doublewords at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 53, Output);
               Test_Element_Property (Output = Input, "Reading doublewords from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 3) := (56, 118, 34, 28);
               Input : constant Double_Word :=
                 (2 ** (0 * 8)) * Double_Word (Bytes (0)) +
                   (2 ** (1 * 8)) * Double_Word (Bytes (1)) +
                     (2 ** (2 * 8)) * Double_Word (Bytes (2)) +
                       (2 ** (3 * 8)) * Double_Word (Bytes (3));
            begin
               Unchecked_Write (Buffer, 55, Input);
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing doublewords at the end of byte buffers should work");
               Unchecked_Read (Buffer, 55, Output);
               Test_Element_Property (Output = Input, "Reading doublewords from the end of byte buffers should work");
            end;
         end;

         -- Test quadword I/O
         declare
            subtype Quad_Word is Emulator_Kit.Data_Types.Quad_Word;
            use type Quad_Word;
            Buffer : Byte_Buffer (127 .. 136) := (others => 42);
            Output : Quad_Word;
         begin
            -- At the beginning of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 7) := (63, 87, 2, 6, 98, 123, 25, 44);
               Input : constant Quad_Word :=
                 (2 ** (0 * 8)) * Quad_Word (Bytes (0)) +
                   (2 ** (1 * 8)) * Quad_Word (Bytes (1)) +
                     (2 ** (2 * 8)) * Quad_Word (Bytes (2)) +
                       (2 ** (3 * 8)) * Quad_Word (Bytes (3)) +
                         (2 ** (4 * 8)) * Quad_Word (Bytes (4)) +
                           (2 ** (5 * 8)) * Quad_Word (Bytes (5)) +
                             (2 ** (6 * 8)) * Quad_Word (Bytes (6)) +
                               (2 ** (7 * 8)) * Quad_Word (Bytes (7));
            begin
               Unchecked_Write (Buffer, 127, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing quadwords at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 127, Output);
               Test_Element_Property (Output = Input, "Reading quadwords from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 7) := (127, 0, 0, 1, 192, 168, 1, 1);
               Input : constant Quad_Word :=
                 (2 ** (0 * 8)) * Quad_Word (Bytes (0)) +
                   (2 ** (1 * 8)) * Quad_Word (Bytes (1)) +
                     (2 ** (2 * 8)) * Quad_Word (Bytes (2)) +
                       (2 ** (3 * 8)) * Quad_Word (Bytes (3)) +
                         (2 ** (4 * 8)) * Quad_Word (Bytes (4)) +
                           (2 ** (5 * 8)) * Quad_Word (Bytes (5)) +
                             (2 ** (6 * 8)) * Quad_Word (Bytes (6)) +
                               (2 ** (7 * 8)) * Quad_Word (Bytes (7));
            begin
               Unchecked_Write (Buffer, 129, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing quadwords at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 129, Output);
               Test_Element_Property (Output = Input, "Reading quadwords from the beginning of byte buffers should work");
            end;
         end;

         -- Test 128-bit SIMD I/O
         declare
            subtype Quad_Word is Emulator_Kit.Data_Types.Quad_Word;
            subtype Two_Quad_Words is Emulator_Kit.Data_Types.Two_Quad_Words;
            use type Quad_Word, Two_Quad_Words;
            Buffer : Byte_Buffer (117 .. 134) := (others => 42);
            Output : aliased Two_Quad_Words;
         begin
            -- At the beginning of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 15) := (2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32);
               Input : aliased constant Two_Quad_Words :=
                 (1 => (2 ** (0 * 8)) * Quad_Word (Bytes (0)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (1)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (2)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (3)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (4)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (5)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (6)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (7)),
                  2 => (2 ** (0 * 8)) * Quad_Word (Bytes (8)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (9)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (10)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (11)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (12)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (13)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (14)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (15)));
            begin
               Unchecked_Write (Buffer, 117, Input'Access);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing quadwords at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 117, Output'Access);
               Test_Element_Property (Output = Input, "Reading quadwords from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 15) := (3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33);
               Input : aliased constant Two_Quad_Words :=
                 (1 => (2 ** (0 * 8)) * Quad_Word (Bytes (0)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (1)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (2)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (3)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (4)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (5)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (6)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (7)),
                  2 => (2 ** (0 * 8)) * Quad_Word (Bytes (8)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (9)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (10)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (11)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (12)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (13)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (14)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (15)));
            begin
               Unchecked_Write (Buffer, 119, Input'Access);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing quadwords at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 119, Output'Access);
               Test_Element_Property (Output = Input, "Reading quadwords from the beginning of byte buffers should work");
            end;
         end;
         -- TODO : Test dqword, fqword, sfloat, dfloat, tfloat
      end Test_Byte_Buffer;

      procedure Test_Byte_Buffers_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Byte_Buffer"), Test_Byte_Buffer'Access);
         -- TODO : Test_Package_Element (To_Entity_Name ("Shared_Byte_Buffers"), Test_Shared_Byte_Buffers'Access);
      end Test_Byte_Buffers_Package;
   begin
      Test_Package (To_Entity_Name ("Memory.Byte_Buffers"), Test_Byte_Buffers_Package'Access);
   end Test;

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Test'Access);

end Emulator_Kit.Memory.Byte_Buffers;
