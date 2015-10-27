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

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Two_Quad_Words) is
      type Byte_Access is access all Data_Types.Byte;
      type Qword_Access_Const is access constant Data_Types.Quad_Word;
   begin
      System.Machine_Code.Asm (Template => "movdqa (%0), %%xmm0;" &
                                           "movdqu %%xmm0, (%1)",
                               Inputs => (Qword_Access_Const'Asm_Input ("r", Input (Input'First)'Access),
                                          Byte_Access'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory xmm0",
                               Volatile => True);
   end Unchecked_Write;

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : Data_Types.Four_Quad_Words) is
      type Byte_Access is access all Data_Types.Byte;
      type Qword_Access_Const is access constant Data_Types.Quad_Word;
   begin
      System.Machine_Code.Asm (Template => "vmovdqa (%0), %%ymm0;" &
                                           "vmovdqu %%ymm0, (%1)",
                               Inputs => (Qword_Access_Const'Asm_Input ("r", Input (Input'First)'Access),
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

   procedure Unchecked_Write (Buffer : in out Byte_Buffer; Location : Byte_Buffer_Index; Input : aliased Data_Types.Float_Extended) is
      type Byte_Access is access all Data_Types.Byte;
      type Float_Extended_Access_Const is access constant Data_Types.Float_Extended;
      St0_Contents : Data_Types.Float_Double; -- See below
   begin
      -- DEBUG : This asm statement is needlessly inefficient. It is made necessary by GNAT's apparent lack of support for x87 clobbers
      System.Machine_Code.Asm (Template => "fldt (%1);" &
                                           "fstpt (%2)",
                               Outputs => Data_Types.Float_Double'Asm_Output ("=t", St0_Contents),
                               Inputs => (Float_Extended_Access_Const'Asm_Input ("r", Input'Access),
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

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Two_Quad_Words) is
      type Byte_Access_Const is access constant Data_Types.Byte;
      type Qword_Access is access all Data_Types.Quad_Word;
   begin
      System.Machine_Code.Asm (Template => "movdqu (%1), %%xmm0;" &
                                           "movdqa %%xmm0, (%0)",
                               Inputs => (Qword_Access'Asm_Input ("r", Output (Output'First)'Access),
                                          Byte_Access_Const'Asm_Input ("r", Buffer (Location)'Access)),
                               Clobber => "memory xmm0",
                               Volatile => True);
   end Unchecked_Read;

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : out Data_Types.Four_Quad_Words) is
      type Byte_Access_Const is access constant Data_Types.Byte;
      type Qword_Access is access all Data_Types.Quad_Word;
   begin
      System.Machine_Code.Asm (Template => "vmovdqu (%1), %%ymm0;" &
                                           "vmovdqa %%ymm0, (%0)",
                               Inputs => (Qword_Access'Asm_Input ("r", Output (Output'First)'Access),
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

   procedure Unchecked_Read (Buffer : Byte_Buffer; Location : Byte_Buffer_Index; Output : aliased out Data_Types.Float_Extended) is
      type Byte_Access_Const is access constant Data_Types.Byte;
      type Float_Extended_Access is access all Data_Types.Float_Extended;
      St0_Contents : Data_Types.Float_Double; -- See below
   begin
      -- DEBUG : This asm statement is needlessly inefficient. It is made necessary by GNAT's apparent lack of support for x87 clobbers
      System.Machine_Code.Asm (Template => "fldt (%2);" &
                                           "fstpt (%1)",
                               Outputs => Data_Types.Float_Double'Asm_Output ("=t", St0_Contents),
                               Inputs => (Float_Extended_Access'Asm_Input ("r", Output'Access),
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
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing quadwords at the end of byte buffers should work");
               Unchecked_Read (Buffer, 129, Output);
               Test_Element_Property (Output = Input, "Reading quadwords from the end of byte buffers should work");
            end;
         end;

         -- Test 128-bit SIMD I/O
         declare
            subtype Quad_Word is Emulator_Kit.Data_Types.Quad_Word;
            subtype Two_Quad_Words is Emulator_Kit.Data_Types.Two_Quad_Words;
            use type Quad_Word, Two_Quad_Words;
            Buffer : Byte_Buffer (117 .. 134) := (others => 42);
            Output : Two_Quad_Words;
         begin
            -- At the beginning of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 15) := (2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32);
               Input : constant Two_Quad_Words :=
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
               Unchecked_Write (Buffer, 117, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing two quadwords at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 117, Output);
               Test_Element_Property (Output = Input, "Reading two quadwords from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 15) := (3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33);
               Input : constant Two_Quad_Words :=
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
               Unchecked_Write (Buffer, 119, Input);
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing two quadwords at the end of byte buffers should work");
               Unchecked_Read (Buffer, 119, Output);
               Test_Element_Property (Output = Input, "Reading two quadwords from the end of byte buffers should work");
            end;
         end;

         -- Test 256-bit SIMD I/O
         declare
            subtype Quad_Word is Emulator_Kit.Data_Types.Quad_Word;
            subtype Four_Quad_Words is Emulator_Kit.Data_Types.Four_Quad_Words;
            use type Quad_Word, Four_Quad_Words;
            Buffer : Byte_Buffer (110 .. 143) := (others => 42);
            Output : Four_Quad_Words;
         begin
            -- At the beginning of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 31) := (1, 3, 5, 7, 9, 11, 13, 15,
                                                          17, 19, 21, 23, 25, 27, 29, 31,
                                                          33, 35, 37, 39, 41, 43, 45, 47,
                                                          49, 51, 53, 55, 57, 59, 61, 63);
               Input : constant Four_Quad_Words :=
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
                  (2 ** (7 * 8)) * Quad_Word (Bytes (15)),
                 3 => (2 ** (0 * 8)) * Quad_Word (Bytes (16)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (17)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (18)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (19)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (20)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (21)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (22)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (23)),
                 4 => (2 ** (0 * 8)) * Quad_Word (Bytes (24)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (25)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (26)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (27)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (28)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (29)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (30)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (31)));
            begin
               Unchecked_Write (Buffer, 110, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing four quadwords at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 110, Output);
               Test_Element_Property (Output = Input, "Reading four quadwords from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Bytes : constant Byte_Buffer (0 .. 31) := (4, 8, 12, 16, 20, 24, 28, 32,
                                                          36, 40, 44, 48, 52, 56, 60, 64,
                                                          68, 72, 76, 80, 84, 88, 92, 96,
                                                          100, 104, 108, 112, 116, 120, 124, 128);
               Input : constant Four_Quad_Words :=
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
                  (2 ** (7 * 8)) * Quad_Word (Bytes (15)),
                 3 => (2 ** (0 * 8)) * Quad_Word (Bytes (16)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (17)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (18)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (19)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (20)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (21)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (22)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (23)),
                 4 => (2 ** (0 * 8)) * Quad_Word (Bytes (24)) +
                  (2 ** (1 * 8)) * Quad_Word (Bytes (25)) +
                  (2 ** (2 * 8)) * Quad_Word (Bytes (26)) +
                  (2 ** (3 * 8)) * Quad_Word (Bytes (27)) +
                  (2 ** (4 * 8)) * Quad_Word (Bytes (28)) +
                  (2 ** (5 * 8)) * Quad_Word (Bytes (29)) +
                  (2 ** (6 * 8)) * Quad_Word (Bytes (30)) +
                  (2 ** (7 * 8)) * Quad_Word (Bytes (31)));
            begin
               Unchecked_Write (Buffer, 112, Input);
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing four quadwords at the end of byte buffers should work");
               Unchecked_Read (Buffer, 112, Output);
               Test_Element_Property (Output = Input, "Reading four quadwords from the end of byte buffers should work");
            end;
         end;

         -- Test single-precision float I/O
         declare
            subtype Float_Single is Emulator_Kit.Data_Types.Float_Single;
            use type Float_Single;
            Buffer : Byte_Buffer (63 .. 68) := (others => 42);
            Output : Float_Single;
         begin
            -- At the beginning of a buffer
            declare
               Input : constant Float_Single := 0.3;
               Bytes : constant Byte_Buffer (0 .. 3) := (2#10011010#, 2#10011001#, 2#10011001#, 2#00111110#);
            begin
               Unchecked_Write (Buffer, 63, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing single-precision floats at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 63, Output);
               Test_Element_Property (Output = Input, "Reading single-precision floats from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Input : constant Float_Single := -0.33;
               Bytes : constant Byte_Buffer (0 .. 3) := (2#11000011#, 2#11110101#, 2#10101000#, 2#10111110#);
            begin
               Unchecked_Write (Buffer, 65, Input);
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing single-precision floats at the end of byte buffers should work");
               Unchecked_Read (Buffer, 65, Output);
               Test_Element_Property (Output = Input, "Reading single-precision floats from the end of byte buffers should work");
            end;
         end;

         -- Test double precision float I/O
         declare
            subtype Float_Double is Emulator_Kit.Data_Types.Float_Double;
            use type Float_Double;
            Buffer : Byte_Buffer (83 .. 92) := (others => 42);
            Output : Float_Double;
         begin
            -- At the beginning of a buffer
            declare
               Input : constant Float_Double := 0.333;
               Bytes : constant Byte_Buffer (0 .. 7) := (16#1D#, 16#5A#, 16#64#, 16#3B#, 16#DF#, 16#4F#, 16#D5#, 16#3F#);
            begin
               Unchecked_Write (Buffer, 83, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing double-precision floats at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 83, Output);
               Test_Element_Property (Output = Input, "Reading double-precision floats from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Input : constant Float_Double := -0.3333; -- 69 6F F0 85 C9 54 D5 BF
               Bytes : constant Byte_Buffer (0 .. 7) := (16#69#, 16#6F#, 16#F0#, 16#85#, 16#C9#, 16#54#, 16#D5#, 16#BF#);
            begin
               Unchecked_Write (Buffer, 85, Input);
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing double-precision floats at the end of byte buffers should work");
               Unchecked_Read (Buffer, 85, Output);
               Test_Element_Property (Output = Input, "Reading double-precision floats from the end of byte buffers should work");
            end;
         end;

         -- Test extended-precision float I/O
         declare
            subtype Float_Extended is Emulator_Kit.Data_Types.Float_Extended;
            use type Float_Extended;
            Buffer : Byte_Buffer (117 .. 128) := (others => 42);
            Output : aliased Float_Extended;
         begin
            -- At the beginning of a buffer
            declare
               Input : aliased constant Float_Extended := (Fraction => 2#0101101_11001011_00111100_11011111_11011101_11101110_10100110_10101101#,
                                                           Integer_Bit => False,
                                                           Exponent => 2#1101101_00110101#,
                                                           Sign_Bit => True);
               Bytes : constant Byte_Buffer (0 .. 9) := (2#10101101#, -- Fraction least significant byte
                                                         2#10100110#,
                                                         2#11101110#,
                                                         2#11011101#,
                                                         2#11011111#,
                                                         2#00111100#,
                                                         2#11001011#,
                                                         2#0_0101101#, -- Integer bit + last 7 bits of fraction
                                                         2#00110101#, -- First exponent byte
                                                         2#1_1101101#); -- Sign bit + last 7 bits of exponent
            begin
               Unchecked_Write (Buffer, 117, Input);
               Test_Element_Property (Buffer = Bytes & (42, 42), "Writing extended-precision floats at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 117, Output);
               Test_Element_Property (Output = Input, "Reading extended-precision floats from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               Input : aliased constant Float_Extended := (Fraction => 2#1010101_00101110_11011100_00111010_10011110_11101101_01010101_10101010#,
                                                           Integer_Bit => False,
                                                           Exponent => 2#1111001_01010101#,
                                                           Sign_Bit => False);
               Bytes : constant Byte_Buffer (0 .. 9) := (2#10101010#, -- Fraction least significant byte
                                                         2#01010101#,
                                                         2#11101101#,
                                                         2#10011110#,
                                                         2#00111010#,
                                                         2#11011100#,
                                                         2#00101110#,
                                                         2#0_1010101#, -- Integer bit + last 7 bits of fraction
                                                         2#01010101#, -- First exponent byte
                                                         2#0_1111001#); -- Sign bit + last 7 bits of exponent
            begin
               Unchecked_Write (Buffer, 119, Input);
               Test_Element_Property (Buffer = (42, 42) & Bytes, "Writing extended-precision floats at the end of byte buffers should work");
               Unchecked_Read (Buffer, 119, Output);
               Test_Element_Property (Output = Input, "Reading extended-precision floats from the end of byte buffers should work");
            end;
         end;
      end Test_Byte_Buffer;

      procedure Test_Byte_Buffers_Package is
      begin
         Test_Package_Element (To_Entity_Name ("Byte_Buffer"), Test_Byte_Buffer'Access);
         -- NOTE : Shared byte buffers are not tested here, because the relevant shared package is already tested in Emulator_Kit.Tasking.Processes.
      end Test_Byte_Buffers_Package;
   begin
      Test_Package (To_Entity_Name ("Memory.Byte_Buffers"), Test_Byte_Buffers_Package'Access);
   end Test;

begin

   -- Automatically test the package when it is included
   Debug.Test.Elaboration_Self_Test (Test'Access);

end Emulator_Kit.Memory.Byte_Buffers;
