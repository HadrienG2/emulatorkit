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
            use type Emulator_Kit.Data_Types.Word;
            Buffer : Byte_Buffer (5 .. 7) := (others => 42);
            Output : Data_Types.Word;
         begin
            -- At the beginning of a buffer
            declare
               LSB : constant := 33;
               MSB : constant := 255;
               Input : constant Data_Types.Word := LSB + 256 * MSB;
            begin
               Unchecked_Write (Buffer, 5, Data_Types.Word'(Input));
               Test_Element_Property (Buffer = (LSB, MSB, 42), "Writing words at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 5, Output);
               Test_Element_Property (Output = Input, "Reading words from the beginning of byte buffers should work");
            end;
            Buffer := (others => 42);

            -- At the end of a buffer
            declare
               LSB : constant := 63;
               MSB : constant := 145;
               Input : constant Data_Types.Word := LSB + 256 * MSB;
            begin
               Unchecked_Write (Buffer, 6, Data_Types.Word'(Input));
               Test_Element_Property (Buffer = (42, LSB, MSB), "Writing words at the beginning of byte buffers should work");
               Unchecked_Read (Buffer, 6, Output);
               Test_Element_Property (Output = Input, "Reading words from the beginning of byte buffers should work");
            end;
         end;

         declare
         -- TODO : Test dword, qword, dqword, fqword, sfloat, dfloat, tfloat
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
