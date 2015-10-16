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

end Emulator_Kit.Memory.Byte_Buffers;